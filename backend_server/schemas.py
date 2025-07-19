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
    fp_id: Optional[int] = None


# For returning request data
class ServiceRequestOut(BaseModel):
    id: int
    client_id: int
    ca_id: Optional[int] = None
    blo_id: Optional[int] = None
    fp_id: Optional[int] = None
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
    fp: Optional[UserShort] = None

    class Config:
        from_attributes = True

class LoanRequestCreate(BaseModel):
    blo_id: int
    # Personal Info
    full_name: str
    date_of_birth: date
    nid_number: str
    phone_number: str
    email: str
    present_address: str
    
    # Business Info
    employment_type: str
    company_name: Optional[str] = None
    designation: Optional[str] = None
    monthly_income: float
    length_of_employment: str
    
    # Loan Details
    loan_type: str
    requested_amount: float
    loan_tenure: str
    purpose_of_loan: str
    preferred_bank: str
    
    # Additional Info (Optional)
    guarantor_name: Optional[str] = None
    guarantor_nid: Optional[str] = None
    guarantor_phone: Optional[str] = None
    collateral_info: Optional[str] = None
    notes_remarks: Optional[str] = None

class LoanRequestOut(BaseModel):
    id: int
    client_id: int
    blo_id: int
    # Personal Info
    full_name: str
    date_of_birth: date
    nid_number: str
    phone_number: str
    email: str
    present_address: str
    
    # Business Info
    employment_type: str
    company_name: Optional[str] = None
    designation: Optional[str] = None
    monthly_income: float
    length_of_employment: str
    
    # Loan Details
    loan_type: str
    requested_amount: float
    loan_tenure: str
    purpose_of_loan: str
    preferred_bank: str
    
    # Additional Info (Optional)
    guarantor_name: Optional[str] = None
    guarantor_nid: Optional[str] = None
    guarantor_phone: Optional[str] = None
    collateral_info: Optional[str] = None
    notes_remarks: Optional[str] = None
    
    # Status and timestamps
    status: str
    created_at: datetime
    updated_at: datetime
    
    # Relationships
    client: UserShort

    class Config:
        from_attributes = True

class LoanStatusCreate(BaseModel):
    status: str  # approved, rejected, pending, missing_info
    message: Optional[str] = None

class LoanStatusOut(BaseModel):
    id: int
    loan_request_id: int
    client_id: int
    blo_id: int
    status: str
    message: Optional[str] = None
    updated_at: datetime
    requested_amount: Optional[float] = None
    purpose_of_loan: Optional[str] = None
    preferred_bank: Optional[str] = None
    loan_tenure: Optional[str] = None

    class Config:
        from_attributes = True


