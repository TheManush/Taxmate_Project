from pydantic import BaseModel, EmailStr, validator
from typing import Optional
from datetime import date
from typing import Literal
from datetime import datetime


class UserBase(BaseModel):
    email: EmailStr
    full_name: str
    phone: str
    address: str

class UserCreate(UserBase):
    password: str
    user_type: str  # client, service_provider, admin
    client_type: Optional[str] = None  # individual, enterprise
    service_provider_type: Optional[str] = None  # ca, financial_planner, loan_officer
    profession: Optional[str] = None
    gender: Optional[str] = None
    dob: Optional[date] = None
    enterprise_name: Optional[str] = None
    tin_number: Optional[str] = None
    business_type: Optional[str] = None
    experience: Optional[str] = None
    qualification: Optional[str] = None

    @validator('password')
    def password_length(cls, v):
        if len(v) < 6:
            raise ValueError('Password must be at least 6 characters')
        return v

    @validator('user_type')
    def validate_user_type(cls, v):
        valid_types = ['client', 'service_provider', 'admin']
        if v.lower() not in valid_types:
            raise ValueError(f'User type must be one of: {", ".join(valid_types)}')
        return v.lower()

class UserLogin(BaseModel):
    email: EmailStr
    password: str

class UserOut(UserBase):
    id: int
    user_type: str
    client_type: Optional[str] = None
    service_provider_type: Optional[str] = None
    experience: Optional[str] = None
    qualification: Optional[str] = None

    class Config:
        from_attributes = True

# For client to send request
class ServiceRequestCreate(BaseModel):
    client_id: int
    ca_id: Optional[int] = None
    blo_id: Optional[int] = None


# For returning request data
class ServiceRequestOut(BaseModel):
    id: int
    client_id: int
    ca_id: Optional[int] = None
    blo_id: Optional[int] = None
    status: Literal['pending', 'approved', 'rejected']

    class Config:
        from_attributes = True 


class UserShort(BaseModel):
    id: int
    full_name: str
    email: str

    class Config:
        from_attributes = True

class ServiceRequestUpdate(BaseModel):
    status: Literal["approved", "rejected"]

class ServiceRequestDetailedOut(BaseModel):
    id: int
    status: str
    client: UserShort
    ca: Optional[UserShort] = None
    blo: Optional[UserShort] = None

    class Config:
        from_attributes = True


