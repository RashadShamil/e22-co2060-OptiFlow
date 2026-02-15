from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from booking_manager import check_availability, supabase

app = FastAPI()

class BookingRequest(BaseModel):
    machine_id: str
    user_name: str
    start_time: str
    end_time: str 

@app.get("/")
def read_root():
    return {"status": "Backend is working."}

@app.post("/book_machine")
def book_machine(request: BookingRequest):
    print(f"Recieve request for {request.user_name}")

    is_clear = check_availability(request.machine_id,request.start_time,request.end_time)

    if not is_clear:
        raise HTTPException(status_code=400, detail="Slot is already booked!")
        
    data_to_save = {
        "machine_id": request.machine_id,
        "user_name": request.user_name,
        "start_time": request.start_time,
        "end_time": request.end_time
    }

    supabase.table("bookings").insert(data_to_save).execute()

    return {"message": "✅ Booking Confirmed!", "saved_data": data_to_save}

# --- NEW: JOB BOARD ROUTES ---

@app.get("/jobs")
def get_open_jobs():
    """
    Fetch all jobs that are currently OPEN for students to take.
    """
    print("📋 Fetching open jobs...")
    
    # 1. Ask Supabase for all jobs where status is 'OPEN'
    response = supabase.table('jobs').select("*").eq("status", "OPEN").execute()
    
    # 2. Return the list to the mobile app
    return {"count": len(response.data), "jobs": response.data}

class JobClaimRequest(BaseModel):
    job_id: str
    student_name: str

@app.post("/claim_job")
def claim_job(request: JobClaimRequest):

    print(f"Claim request form {request.student_name} for job {request.job_id}")

    try:
        response = supabase.table('jobs').select("*")\
            .eq("id", request.job_id)\
            .eq("status", "OPEN")\
            .execute()
        if len(response.data)==0:
                raise HTTPException(status_code=400, detail="Job is already taken.")

        update_data = {
                "status": "TAKEN",
                "assigned_to": request.student_name
            }

        supabase.table('jobs').update(update_data).eq("id", request.job_id).execute()
            
        print(f"Job successfully assigned to {request.student_name}")
        return {"message": "Job Claimed! Get to work.", "job_id": request.job_id}

    except Exception as e:
        print(f"ERROR: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))  

class JobCreateRequest(BaseModel):
    title: str
    price: int
    deadline: str
    estimated_hours: int

@app.post("/create_job")
def create_job(job: JobCreateRequest):
    print(f"Manager is posting a new job: {job.title}")

    try: 
        new_job_data = {
            "title": job.title,
            "price": job.price,
            "deadline": job.deadline,
            "estimated_hours": job.estimated_hours,
            "status": "OPEN" # Always starts as OPEN
        }
        response = supabase.table('jobs').insert(new_job_data).execute()
                
        print("Job posted successfully!")
        return {"message": "Job Posted!", "job_details": response.data}

    except Exception as e:
        print(f" ERROR: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

class MachineStatusUpdate(BaseModel):
    status:str

@app.patch("/machine.{machine_id}")
def update_machine_status(machine_id: str, update: MachineStatusUpdate):
    print(f" Updating Machine {machine_id} to {update.status}...")

    try:
        # 1. Update the specific machine
        response = supabase.table('machines').update({"status": update.status}).eq("id", machine_id).execute()
        return {"message": "Status Updated!", "data": response.data}

    except Exception as e:
        print(f"🔥 ERROR: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/machines")
def get_machines():
    """
    Fetch all machines and their current status.
    """
    # Ask Supabase for everything in the 'machines' table
    response = supabase.table('machines').select("*").execute()
    return {"machines": response.data}