import os
from datetime import datetime, timedelta
from ortools.sat.python import cp_model
from databse import supabase

# =====================================================================
# PHASE 1: SYSTEM SETUP & DATA INGESTION
# =====================================================================

def fetch_optiflow_data(job_id: str):
    """
    Pulls the current physical reality of the print shop out of PostgreSQL 
    and translates it into Python lists and dictionaries.
    """
    # 1. Get every step required to complete this specific order
    tasks = supabase.table("tasks").select("*").eq("job_id", job_id).execute().data
    
    # 2. Extract IDs for dependency lookups
    task_ids = [t['id'] for t in tasks]
    
    # 3. Get the DAG (Directed Acyclic Graph) rules
    dependencies = supabase.table("task_dependencies").select("*").in_("successor_task_id", task_ids).execute().data
    
    # 4. Get the Skills Matrix (Speeds and Costs)
    capabilities = supabase.table("resource_capabilities").select("*").execute().data
    
    return tasks, dependencies, capabilities

# =====================================================================
# PHASE 2: THE MATHEMATICAL BRAIN (CP-SAT)
# =====================================================================

def run_optimization_engine(job_id: str, project_start_time: datetime, alpha: int = 70, beta: int = 30):
    """
    Executes the Constraint Programming solver.
    alpha: The weight given to completing the job quickly (Time).
    beta: The weight given to minimizing operational expenses (Cost).
    """
    # Bring the database information into the engine's memory
    tasks, dependencies, capabilities = fetch_optiflow_data(job_id)
    
    # Instantiate the blank canvas
    model = cp_model.CpModel()
      
    # Horizon: The absolute maximum time the factory could theoretically run (in minutes)
    horizon = 100000 

    # --- TRACKING DICTIONARIES ---
    task_vars = {}          # Tracks the global start/end time of a task
    machine_intervals = {}  # Groups time blocks by machine (prevents overlap)
    presence_trackers = {}  # Tracks the boolean (0 or 1) of WHO was assigned to WHAT
    cost_expressions = []   # Tracks the financial cost of the solver's choices

    # -----------------------------------------------------------------
    # STEP 2: CREATING THE QUANTUM TIMELINE
    # -----------------------------------------------------------------
    for task in tasks:
        t_id = task['id']
        op_type = task['operation_type_id'] 
        qty = task['quantity_to_process']   
        
        # Absolute start and end time variables for the task
        task_start = model.NewIntVar(0, horizon, f'start_{t_id}')
        task_end = model.NewIntVar(0, horizon, f'end_{t_id}')
        task_vars[t_id] = {'start': task_start, 'end': task_end}
        
        # Find capable machines
        capable_resources = [c for c in capabilities if c['operation_type_id'] == op_type]
        presence_literals = []

        for cap in capable_resources:
            r_id = cap['resource_id']
            
            if r_id not in machine_intervals:
                machine_intervals[r_id] = []
            
            # MATH: Calculate Duration
            duration_minutes = int((qty / cap['processing_rate_per_hr']) * 60 + cap['setup_time_minutes'])
            
            # MATH: Calculate Integer Cost (CP-SAT cannot handle decimals)
            # Cost = (Duration in Hours) * (Hourly Rate)
            task_cost = int((duration_minutes / 60.0) * float(cap['cost_per_hour']))
            
            # THE SWITCH: Did the solver pick this machine? (1 or 0)
            is_present = model.NewBoolVar(f'presence_{t_id}_{r_id}')
            presence_literals.append(is_present)
            presence_trackers[(t_id, r_id)] = is_present 
            
            # Add the cost to our ledger ONLY if this machine is chosen
            cost_expressions.append(is_present * task_cost)
            
            # Local machine variables
            local_start = model.NewIntVar(0, horizon, f'local_start_{t_id}_{r_id}')
            local_end = model.NewIntVar(0, horizon, f'local_end_{t_id}_{r_id}')
            
            # The Interval Block
            interval = model.NewOptionalIntervalVar(local_start, duration_minutes, local_end, is_present, f'int_{t_id}_{r_id}')
            
            model.Add(task_start == local_start).OnlyEnforceIf(is_present)
            model.Add(task_end == local_end).OnlyEnforceIf(is_present)
            
            machine_intervals[r_id].append(interval)

        # RULE: The task MUST be assigned to exactly ONE machine
        model.AddExactlyOne(presence_literals)

    # -----------------------------------------------------------------
    # STEP 3: ENFORCING CHRONOLOGY (The DAG)
    # -----------------------------------------------------------------
    for dep in dependencies:
        pred_id = dep['predecessor_task_id'] 
        succ_id = dep['successor_task_id']   
        wait = dep['mandatory_wait_minutes'] 
        
        if pred_id in task_vars and succ_id in task_vars:
            # RULE: Next task start >= Previous task end + Wait Time
            model.Add(task_vars[succ_id]['start'] >= task_vars[pred_id]['end'] + wait)

    # -----------------------------------------------------------------
    # STEP 4: PREVENTING CLASHES (No Overlap)
    # -----------------------------------------------------------------
    for r_id, intervals in machine_intervals.items():
        # RULE: A physical machine cannot do two tasks at the exact same time
        model.AddNoOverlap(intervals)

    # -----------------------------------------------------------------
    # STEP 5: THE MULTI-OBJECTIVE EQUATION
    # -----------------------------------------------------------------
    # 1. Measure Time (Makespan)
    makespan_var = model.NewIntVar(0, horizon, 'makespan')
    model.AddMaxEquality(makespan_var, [vars['end'] for vars in task_vars.values()])
    
    # 2. Measure Total Cost
    # (We set a massive upper bound just to satisfy the Integer Variable limits)
    total_cost_var = model.NewIntVar(0, 99999999, 'total_cost')
    model.Add(total_cost_var == sum(cost_expressions))

    # 3. The Alpha/Beta Minimization
    # Tell the solver to balance the schedule based on your custom weights
    model.Minimize((alpha * makespan_var) + (beta * total_cost_var))

    # -----------------------------------------------------------------
    # STEP 6: UNLEASH THE ENGINE
    # -----------------------------------------------------------------
    solver = cp_model.CpSolver()
    status = solver.Solve(model) 

    # =====================================================================
    # PHASE 3: DATA EXTRACTION & SAVING THE RESULTS
    # =====================================================================
    
    if status == cp_model.OPTIMAL or status == cp_model.FEASIBLE:
        final_makespan = solver.Value(makespan_var)
        final_cost = solver.Value(total_cost_var)
        
        print(f"✅ Schedule Found! Time: {final_makespan} mins | Cost: ${final_cost}")
        
        for task in tasks:
            t_id = task['id']
            
            # Extract real times
            start_minutes = solver.Value(task_vars[t_id]['start'])
            end_minutes = solver.Value(task_vars[t_id]['end'])
            
            actual_start_time = project_start_time + timedelta(minutes=start_minutes)
            actual_end_time = project_start_time + timedelta(minutes=end_minutes)
            
            # Extract winning machine
            assigned_r_id = None
            for (track_t_id, r_id), is_present_var in presence_trackers.items():
                if track_t_id == t_id and solver.Value(is_present_var) == 1:
                    assigned_r_id = r_id
                    break
            
            # Commit to Database
            supabase.table("tasks").update({
                "scheduled_start_time": actual_start_time.isoformat(),
                "scheduled_end_time": actual_end_time.isoformat(),
                "assigned_resource_id": assigned_r_id,
                "status": "SCHEDULED"
            }).eq("id", t_id).execute()
            
        return {
            "status": "success", 
            "makespan_minutes": final_makespan,
            "total_cost": final_cost
        }
    else:
        print("❌ No feasible schedule found.")
        return {"status": "error", "message": "Constraints impossible to satisfy."}