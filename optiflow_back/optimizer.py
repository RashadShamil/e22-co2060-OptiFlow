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
    # 1. Get every step required to complete this specific order (e.g., Print, Fold, Bind)
    tasks = supabase.table("tasks").select("*").eq("job_id", job_id).execute().data
    
    # 2. Extract just the IDs so we can look up their specific chronological rules
    task_ids = [t['id'] for t in tasks]
    
    # 3. Get the DAG (Directed Acyclic Graph) rules. 
    # Example: "Task B (Fold) is the successor_task_id to Task A (Print)"
    dependencies = supabase.table("task_dependencies").select("*").in_("successor_task_id", task_ids).execute().data
    
    # 4. Get the Skills Matrix. This tells us which machines/workers exist, 
    # what they can do, how fast they do it, and what they cost.
    capabilities = supabase.table("resource_capabilities").select("*").execute().data
    
    return tasks, dependencies, capabilities

# =====================================================================
# PHASE 2: THE MATHEMATICAL BRAIN (CP-SAT)
# =====================================================================

def run_optimization_engine(job_id: str, project_start_time: datetime):
    
    # Bring the database information into the engine's memory
    tasks, dependencies, capabilities = fetch_optiflow_data(job_id)
    
    # Instantiate the blank canvas where we will build our mathematical universe
    model = cp_model.CpModel()
      
    # The solver needs a definitive "End of Time" to cap its search space.
    # We set 100,000 minutes (about 69 days). No print job should take this long.
    horizon = 100000 

    # --- TRACKING DICTIONARIES ---
    # The solver generates thousands of temporary variables. We need these 
    # dictionaries to keep track of them so we can extract the winners later.
    task_vars = {}          # Tracks the global start/end time of a task
    machine_intervals = {}  # Groups time blocks by machine (used to prevent double-booking)
    presence_trackers = {}  # Tracks the boolean (0 or 1) of WHO was assigned to WHAT

    # -----------------------------------------------------------------
    # STEP 2: CREATING THE QUANTUM TIMELINE (Variables & Intervals)
    # -----------------------------------------------------------------
    for task in tasks:
        t_id = task['id']
        op_type = task['operation_type_id'] # e.g., 'fold_pages'
        qty = task['quantity_to_process']   # e.g., 500 units
        
        # Create an integer variable for the absolute start and end time of this task.
        # We don't know the answer yet. We just tell the solver: "It is a number between 0 and 100,000."
        task_start = model.NewIntVar(0, horizon, f'start_{t_id}')
        task_end = model.NewIntVar(0, horizon, f'end_{t_id}')
        task_vars[t_id] = {'start': task_start, 'end': task_end}
        
        # Filter the Skills Matrix to find EVERY resource that knows how to do this operation
        capable_resources = [c for c in capabilities if c['operation_type_id'] == op_type]
        
        # This list will hold the "Switches" (0 or 1) for each possible machine
        presence_literals = []

        for cap in capable_resources:
            r_id = cap['resource_id']
            
            # Ensure this machine has a list in our tracking dictionary
            if r_id not in machine_intervals:
                machine_intervals[r_id] = []
            
            # MATH: Calculate how long this specific machine takes to do the quantity.
            # (Quantity / Units Per Hour) * 60 minutes + Setup Time
            duration_minutes = int((qty / cap['processing_rate_per_hr']) * 60 + cap['setup_time_minutes'])
            
            # THE SWITCH: A Boolean variable (True=1, False=0).
            # "Is this task assigned to this specific machine?"
            is_present = model.NewBoolVar(f'presence_{t_id}_{r_id}')
            presence_literals.append(is_present)
            presence_trackers[(t_id, r_id)] = is_present 
            
            # Create local start/end times just for this specific machine
            local_start = model.NewIntVar(0, horizon, f'local_start_{t_id}_{r_id}')
            local_end = model.NewIntVar(0, horizon, f'local_end_{t_id}_{r_id}')
            
            # THE INTERVAL: This is CP-SAT's superpower. It creates a solid "Block" of time.
            # Notice we pass `is_present`. If the solver decides NOT to use this machine, 
            # this entire interval effectively disappears from the math (Size = 0).
            interval = model.NewOptionalIntervalVar(local_start, duration_minutes, local_end, is_present, f'int_{t_id}_{r_id}')
            
            # If the solver flips the switch to 1 (True), force the global task start time 
            # to exactly match this machine's local start time.
            model.Add(task_start == local_start).OnlyEnforceIf(is_present)
            model.Add(task_end == local_end).OnlyEnforceIf(is_present)
            
            # Add this block of time to the machine's personal calendar
            machine_intervals[r_id].append(interval)

        # CRITICAL RULE: The task MUST be done. The solver is allowed to flip exactly 
        # ONE of these machine switches to 1. The rest must be 0.
        model.AddExactlyOne(presence_literals)

    # -----------------------------------------------------------------
    # STEP 3: ENFORCING CHRONOLOGY (The DAG)
    # -----------------------------------------------------------------
    for dep in dependencies:
        pred_id = dep['predecessor_task_id'] # The task that must finish first (e.g., Print)
        succ_id = dep['successor_task_id']   # The task waiting in line (e.g., Fold)
        wait = dep['mandatory_wait_minutes'] # e.g., 120 minutes of ink drying time
        
        if pred_id in task_vars and succ_id in task_vars:
            # RULE: Start Time of Folding >= End Time of Printing + Wait Time
            model.Add(task_vars[succ_id]['start'] >= task_vars[pred_id]['end'] + wait)

    # -----------------------------------------------------------------
    # STEP 4: PREVENTING CLASHES (No Overlap)
    # -----------------------------------------------------------------
    for r_id, intervals in machine_intervals.items():
        # Look at every single time block assigned to Machine X.
        # Mathematically guarantee that none of them intersect.
        model.AddNoOverlap(intervals)

    # -----------------------------------------------------------------
    # STEP 5: THE GOAL (Objective Function)
    # -----------------------------------------------------------------
    # Create a variable to represent the very end of the entire job (Makespan)
    obj_var = model.NewIntVar(0, horizon, 'makespan')
    
    # Set obj_var to equal the largest 'end' time out of all the tasks
    model.AddMaxEquality(obj_var, [vars['end'] for vars in task_vars.values()])
     
    # Tell the solver: "Find the schedule that makes this number as small as possible."
    model.Minimize(obj_var)

    # -----------------------------------------------------------------
    # STEP 6: UNLEASH THE C++ ENGINE
    # -----------------------------------------------------------------
    solver = cp_model.CpSolver()
    status = solver.Solve(model) # This is where the CPU spikes and calculates millions of paths

    # =====================================================================
    # PHASE 3: DATA EXTRACTION & SAVING THE RESULTS
    # =====================================================================
    
    # If the solver found the mathematically perfect schedule (OPTIMAL), or 
    # at least a schedule that doesn't break any rules (FEASIBLE)...
    if status == cp_model.OPTIMAL or status == cp_model.FEASIBLE:
        print(f"✅ Optimal Schedule Found! Total Time: {solver.ObjectiveValue()} minutes.")
        
        for task in tasks:
            t_id = task['id']
            
            # Read the solver's memory to find out exactly what minute it picked
            start_minutes = solver.Value(task_vars[t_id]['start'])
            end_minutes = solver.Value(task_vars[t_id]['end'])
            
            # Add those minutes to our starting clock to get a real Timestamp
            actual_start_time = project_start_time + timedelta(minutes=start_minutes)
            actual_end_time = project_start_time + timedelta(minutes=end_minutes)
            
            # Loop through our Boolean switches to find the ONE machine that got flipped to 1
            assigned_r_id = None
            for (track_t_id, r_id), is_present_var in presence_trackers.items():
                if track_t_id == t_id and solver.Value(is_present_var) == 1:
                    assigned_r_id = r_id
                    break
            
            # Push the final answers to PostgreSQL so the Flutter app can see them
            supabase.table("tasks").update({
                "scheduled_start_time": actual_start_time.isoformat(),
                "scheduled_end_time": actual_end_time.isoformat(),
                "assigned_resource_id": assigned_r_id,
                "status": "SCHEDULED"
            }).eq("id", t_id).execute()
            
            print(f"Task {task['name']} -> Assigned to {assigned_r_id} at {actual_start_time}")
            
        return {"status": "success", "makespan_minutes": solver.ObjectiveValue()}
    else:
        # If the DAG is broken (e.g., A depends on B, and B depends on A), it fails here.
        print("❌ No feasible schedule found.")
        return {"status": "error", "message": "Constraints impossible to satisfy."}
