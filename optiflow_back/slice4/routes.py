from fastapi import APIRouter, HTTPException
from app.database import supabase
from app.models import *

router = APIRouter()

# ─────────────────────────────────────────
# OPERATION TYPES
# ─────────────────────────────────────────

@router.get("/operation-types")
def get_all_operation_types():
    res = supabase.table("operation_types").select("*").execute()
    return res.data

import uuid

@router.post("/operation-types")
def create_operation_type(body: OperationTypeCreate):
    existing = supabase.table("operation_types").select("id").eq("name", body.name).execute()
    if existing.data:
        raise HTTPException(status_code=400, detail="Operation type already exists")
    data = body.model_dump()
    data["id"] = str(uuid.uuid4())
    res = supabase.table("operation_types").insert(data).execute()
    return res.data[0]

@router.put("/operation-types/{id}")
def update_operation_type(id: str, body: OperationTypeUpdate):
    res = supabase.table("operation_types").update(body.model_dump(exclude_none=True)).eq("id", id).execute()
    if not res.data:
        raise HTTPException(status_code=404, detail="Operation type not found")
    return res.data[0]

@router.delete("/operation-types/{id}")
def delete_operation_type(id: str):
    supabase.table("operation_types").delete().eq("id", id).execute()
    return {"message": "Deleted successfully"}


# ─────────────────────────────────────────
# RESOURCES
# ─────────────────────────────────────────

@router.get("/resources")
def get_all_resources():
    res = supabase.table("resources").select("*").execute()
    return res.data

@router.get("/resources/{id}")
def get_resource(id: str):
    res = supabase.table("resources").select("*").eq("id", id).execute()
    if not res.data:
        raise HTTPException(status_code=404, detail="Resource not found")
    return res.data[0]

@router.post("/resources")
def create_resource(body: ResourceCreate):
    if body.type not in ["MACHINE", "HUMAN"]:
        raise HTTPException(status_code=400, detail="Type must be 'MACHINE' or 'HUMAN'")
    if body.status not in ["ACTIVE", "IDLE", "OFFLINE"]:
        raise HTTPException(status_code=400, detail="Status must be ACTIVE, IDLE, or OFFLINE")
    data = body.model_dump()
    data["id"] = str(uuid.uuid4())
    res = supabase.table("resources").insert(data).execute()
    return res.data[0]

@router.put("/resources/{id}")
def update_resource(id: str, body: ResourceUpdate):
    if body.type and body.type not in ["MACHINE", "HUMAN"]:
        raise HTTPException(status_code=400, detail="Type must be 'MACHINE' or 'HUMAN'")
    if body.status and body.status not in ["ACTIVE", "IDLE", "OFFLINE"]:
        raise HTTPException(status_code=400, detail="Status must be ACTIVE, IDLE, or OFFLINE")
    res = supabase.table("resources").update(body.model_dump(exclude_none=True)).eq("id", id).execute()
    if not res.data:
        raise HTTPException(status_code=404, detail="Resource not found")
    return res.data[0]

@router.delete("/resources/{id}")
def delete_resource(id: str):
    supabase.table("resources").delete().eq("id", id).execute()
    return {"message": "Deleted successfully"}


# ─────────────────────────────────────────
# RESOURCE CAPABILITIES (Skills Matrix)
# ─────────────────────────────────────────

@router.get("/capabilities")
def get_all_capabilities():
    res = supabase.table("resource_capabilities").select("*, resources(*), operation_types(*)").execute()
    return res.data

@router.get("/capabilities/resource/{resource_id}")
def get_capabilities_by_resource(resource_id: str):
    res = supabase.table("resource_capabilities").select("*, operation_types(*)").eq("resource_id", resource_id).execute()
    return res.data

@router.post("/capabilities")
def create_capability(body: CapabilityCreate):
    existing = supabase.table("resource_capabilities") \
        .select("id") \
        .eq("resource_id", body.resource_id) \
        .eq("operation_type_id", body.operation_type_id) \
        .execute()
    if existing.data:
        raise HTTPException(status_code=400, detail="This resource already has this capability assigned")
    res = supabase.table("resource_capabilities").insert(body.model_dump()).execute()
    return res.data[0]

@router.put("/capabilities/{id}")
def update_capability(id: str, body: CapabilityUpdate):
    res = supabase.table("resource_capabilities").update(body.model_dump(exclude_none=True)).eq("id", id).execute()
    if not res.data:
        raise HTTPException(status_code=404, detail="Capability not found")
    return res.data[0]

@router.delete("/capabilities/{id}")
def delete_capability(id: str):
    supabase.table("resource_capabilities").delete().eq("id", id).execute()
    return {"message": "Deleted successfully"}