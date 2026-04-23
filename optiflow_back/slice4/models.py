from pydantic import BaseModel, Field
from typing import Optional

class OperationTypeCreate(BaseModel):
    name: str

class OperationTypeUpdate(BaseModel):
    name: Optional[str] = None

class ResourceCreate(BaseModel):
    name: str
    type: str
    status: Optional[str] = "ACTIVE"

class ResourceUpdate(BaseModel):
    name: Optional[str] = None
    type: Optional[str] = None
    status: Optional[str] = None

class CapabilityCreate(BaseModel):
    resource_id: str
    operation_type_id: str
    processing_rate_per_hr: float = Field(..., gt=0)
    setup_time_minutes: Optional[int] = 0
    cost_per_hour: float = Field(..., gt=0)

class CapabilityUpdate(BaseModel):
    processing_rate_per_hr: Optional[float] = Field(None, gt=0)
    setup_time_minutes: Optional[int] = None
    cost_per_hour: Optional[float] = Field(None, gt=0)