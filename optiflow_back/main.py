from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from booking_manager import check_availability, supabase

app = FastAPI()

# ------------------- MODELS -------------------

class BookingRequest(BaseModel):
    machine_id: str
    user_name: str
    start_time: str
    end_time: str


class JobClaimRequest(BaseModel):
    job_id: str
    student_name: str


class JobCreateRequest(BaseModel):
    title: str
    price: int
    deadline: str
    estimated_hours: int


class MachineStatusUpdate(BaseModel):
    status: str


class MachineCreateRequest(BaseModel):
    name: str
    status: str
    price_per_hour: int
    image_url: str


class JobSubmission(BaseModel):
    proof_url: str
    notes: str


# ------------------- ROOT -------------------

@app.get("/")
def read_root():
    return {"status": "Backend is working."}


# ------------------- MACHINE BOOKING -------------------

@app.post("/book_machine")
def book_machine(request: BookingRequest):
    # 🔧 Fixed typo: "Recieve" → "Receive"
    print(f"Receive request for {request.user_name}")

    is_clear = check_availability(
        request.machine_id,
        request.start_time,
        request.end_time
    )

    if not is_clear:
        raise HTTPException(status_code=400, detail="Slot is already booked!")

    data_to_save = {
        "machine_id": request.machine_id,
        "user_name": request.user_name,
        "start_time": request.start_time,
        "end_time": request.end_time
    }

    # 🔧 Ensured .execute() is explicitly called
    supabase.table("bookings").insert(data_to_save).execute()

    return {
        "message": "Booking Confirmed!",
        "saved_data": data_to_save
    }


# ------------------- JOB BOARD -------------------

@app.get("/jobs")
def get_open_jobs():
    print("Fetching open jobs...")

    # 🔧 Formatting fix + safer chained query style
    response = (
        supabase
        .table("jobs")
        .select("*")
        .eq("status", "OPEN")
        .execute()
    )

    return {
        "count": len(response.data),
        "jobs": response.data
    }


@app.post("/claim_job")
def claim_job(request: JobClaimRequest):
    # 🔧 Fixed typo: "form" → "from"
    print(f"Claim request from {request.student_name} for job {request.job_id}")

    try:
        response = (
            supabase
            .table("jobs")
            .select("*")
            .eq("id", request.job_id)
            .eq("status", "OPEN")
            .execute()
        )

        # 🔧 Safer empty-check instead of len(response.data) == 0
        if not response.data:
            raise HTTPException(status_code=400, detail="Job is already taken.")

        update_data = {
            "status": "TAKEN",
            "assigned_to": request.student_name
        }

        supabase.table("jobs").update(update_data).eq("id", request.job_id).execute()

        return {
            "message": "Job Claimed! Get to work.",
            "job_id": request.job_id
        }

    except HTTPException:
        # 🔧 Allows FastAPI to return correct error without converting to 500
        raise
    except Exception as e:
        print(f"ERROR: {str(e)}")
        raise HTTPException(status_code=500, detail="Internal Server Error")


@app.post("/create_job")
def create_job(job: JobCreateRequest):
    print(f"Manager is posting a new job: {job.title}")

    try:
        new_job_data = {
            "title": job.title,
            "price": job.price,
            "deadline": job.deadline,
            "estimated_hours": job.estimated_hours,
            "status": "OPEN"
        }

        response = supabase.table("jobs").insert(new_job_data).execute()

        return {
            "message": "Job Posted!",
            "job_details": response.data
        }

    except Exception as e:
        print(f"ERROR: {str(e)}")
        raise HTTPException(status_code=500, detail="Internal Server Error")


# ------------------- MACHINES -------------------

@app.patch("/machines/{machine_id}")
def update_machine_status(machine_id: str, update: MachineStatusUpdate):
    # 🔧 Minor formatting + clarity
    print(f"Updating Machine {machine_id} to {update.status}")

    try:
        response = (
            supabase
            .table("machines")
            .update({"status": update.status})
            .eq("id", machine_id)
            .execute()
        )

        return {
            "message": "Status Updated!",
            "data": response.data
        }

    except Exception as e:
        print(f"ERROR: {str(e)}")
        raise HTTPException(status_code=500, detail="Internal Server Error")


@app.get("/machines")
def get_machines():
    response = supabase.table("machines").select("*").execute()
    return {"machines": response.data}


@app.post("/create_machine")
def create_machine(machine: MachineCreateRequest):
    print(f"Create a new machine: {machine.name}")

    try:
        new_machine_data = {
            "name": machine.name,
            "status": machine.status,
            "price_per_hour": machine.price_per_hour,
            "image_url": machine.image_url
        }

        response = supabase.table("machines").insert(new_machine_data).execute()

        return {
            "message": "Machine Registered.",
            "machine_details": response.data
        }

    except Exception as e:
        print(f"ERROR: {str(e)}")
        raise HTTPException(status_code=500, detail="Internal Server Error")


# ------------------- JOB SUBMISSION -------------------

@app.post("/jobs/{job_id}/submit")
def submit_job(job_id: str, submission: JobSubmission):
    # 🔧 Fixed typo: "reviwew" → "review"
    print(f"Job {job_id} submitted for review")

    try:
        response = (
            supabase
            .table("jobs")
            .update({
                "status": "REVIEW",
                "proof_url": submission.proof_url,
                "worker_notes": submission.notes
            })
            .eq("id", job_id)
            .execute()
        )

        return {
            "message": "Great work! Manager will review it.",
            "data": response.data
        }

    except Exception as e:
        print(f"ERROR: {str(e)}")
        raise HTTPException(status_code=500, detail="Internal Server Error")
