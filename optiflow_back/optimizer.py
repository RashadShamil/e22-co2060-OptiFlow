import os
from datetime import datetime, timedelta
from dotenv import load_dotenv
from supabase import create_client, Client
from ortools.sat.python import cp_model

# 1. Initialize Supabase Connection
load_dotenv(".env.local")
url: str = os.environ.get("SUPABASE_URL")
key: str = os.environ.get("SUPABASE_KEY")
supabase: Client = create_client(url, key)

def fetch_optiflow_data(job_id: str):
    """Fetches the DAG and Capabilities from Supabase for a specific job."""
    tasks = supabase.table("tasks").select("*").eq("job_id", job_id).execute().data
    task_ids = [t['id'] for t in tasks]
    dependencies = supabase.table("task_dependencies").select("*").in_("successor_task_id", task_ids).execute().data
    capabilities = supabase.table("resource_capabilities").select("*").execute().data
    return tasks, dependencies, capabilities

def run_optimization_engine(job_id: str, project_start_time: datetime):
    """The core CP-SAT algorithm for OptiFlow."""
    
    tasks, dependencies, capabilities = fetch_optiflow_data(job_id)
    model = cp_model.CpModel()
    horizon = 100000 

    task_vars = {} 
    machine_intervals = {} 
    presence_trackers = {} # New: We need to track this to know WHO got assigned

    # Step 2: Create Variables & Optional Intervals
    for task in tasks:
        t_id = task['id']
        op_type = task['operation_type_id']
        qty = task['quantity_to_process']
        
        task_start = model.NewIntVar(0, horizon, f'start_{t_id}')
        task_end = model.NewIntVar(0, horizon, f'end_{t_id}')
        task_vars[t_id] = {'start': task_start, 'end': task_end}
        
        capable_resources = [c for c in capabilities if c['operation_type_id'] == op_type]
        presence_literals = []

        for cap in capable_resources:
            r_id = cap['resource_id']
            if r_id not in machine_intervals:
                machine_intervals[r_id] = []
            
            duration_minutes = int((qty / cap['processing_rate_per_hr']) * 60 + cap['setup_time_minutes'])
            
            is_present = model.NewBoolVar(f'presence_{t_id}_{r_id}')
            presence_literals.append(is_present)
            presence_trackers[(t_id, r_id)] = is_present # Track this!
            
            local_start = model.NewIntVar(0, horizon, f'local_start_{t_id}_{r_id}')
            local_end = model.NewIntVar(0, horizon, f'local_end_{t_id}_{r_id}')
            
            interval = model.NewOptionalIntervalVar(local_start, duration_minutes, local_end, is_present, f'int_{t_id}_{r_id}')
            
            model.Add(task_start == local_start).OnlyEnforceIf(is_present)
            model.Add(task_end == local_end).OnlyEnforceIf(is_present)
            
            machine_intervals[r_id].append(interval)

        model.AddExactlyOne(presence_literals)

    # Step 3: Enforce DAG Dependencies
    for dep in dependencies:
        pred_id = dep['predecessor_task_id']
        succ_id = dep['successor_task_id']
        wait = dep['mandatory_wait_minutes']
        if pred_id in task_vars and succ_id in task_vars:
            model.Add(task_vars[succ_id]['start'] >= task_vars[pred_id]['end'] + wait)

    # Step 4: No Overlap Constraints
    for r_id, intervals in machine_intervals.items():
        model.AddNoOverlap(intervals)

    # Step 5: Minimize Makespan
    obj_var = model.NewIntVar(0, horizon, 'makespan')
    model.AddMaxEquality(obj_var, [vars['end'] for vars in task_vars.values()])
    model.Minimize(obj_var)

    # Step 6: Solve
    solver = cp_model.CpSolver()
    status = solver.Solve(model)

    # Step 7: Data Extraction & Database Update
    if status == cp_model.OPTIMAL or status == cp_model.FEASIBLE:
        print(f"✅ Optimal Schedule Found! Total Time: {solver.ObjectiveValue()} minutes.")
        
        for task in tasks:
            t_id = task['id']
            
            # Extract exact minutes from the solver
            start_minutes = solver.Value(task_vars[t_id]['start'])
            end_minutes = solver.Value(task_vars[t_id]['end'])
            
            # Convert minutes into real-world DateTime stamps
            actual_start_time = project_start_time + timedelta(minutes=start_minutes)
            actual_end_time = project_start_time + timedelta(minutes=end_minutes)
            
            # Figure out exactly which machine/worker the solver chose
            assigned_r_id = None
            for (track_t_id, r_id), is_present_var in presence_trackers.items():
                if track_t_id == t_id and solver.Value(is_present_var) == 1:
                    assigned_r_id = r_id
                    break
            
            # Push the optimized times directly to Supabase
            supabase.table("tasks").update({
                "scheduled_start_time": actual_start_time.isoformat(),
                "scheduled_end_time": actual_end_time.isoformat(),
                "assigned_resource_id": assigned_r_id,
                "status": "SCHEDULED"
            }).eq("id", t_id).execute()
            
            print(f"Task {task['name']} -> Assigned to {assigned_r_id} at {actual_start_time}")
            
        return {"status": "success", "makespan_minutes": solver.ObjectiveValue()}
    else:
        print("❌ No feasible schedule found.")
        return {"status": "error", "message": "Constraints impossible to satisfy."}