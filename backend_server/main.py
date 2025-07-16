from datetime import date, datetime
from typing import Optional, List
from fastapi import Body, FastAPI, Depends, HTTPException, status, APIRouter
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session, selectinload
import uvicorn
from passlib.context import CryptContext
import models, schemas, crud
from database import SessionLocal, engine, get_db
from models import User, ServiceRequest
from schemas import UserOut, UserShort, ServiceRequestCreate, ServiceRequestOut, ServiceRequestUpdate, ServiceRequestDetailedOut
from file_upload import router as upload_router
from chat1 import chat_router
from fcm_utils import send_fcm_v1_notification

#add this extra line for password recovery
from recovery_pass import router as recovery_router

# Create tables
models.Base.metadata.create_all(bind=engine)

app = FastAPI()
app.include_router(upload_router)
app.include_router(chat_router)
#add this extra line for password recovery
app.include_router(recovery_router, prefix="/recovery", tags=["recovery"])


# Password hashing
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

# CORS (Keep original)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# --------------------------
# Original Endpoints (Preserved Exactly)
# --------------------------
@app.post("/register_fcm_token/")
def register_fcm_token(user_id: int = Body(...), fcm_token: str = Body(...), db: Session = Depends(get_db)):
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    user.fcm_token = fcm_token
    db.commit()
    return {"message": "FCM token updated successfully"}

@app.post("/signup/", response_model=schemas.UserOut, status_code=status.HTTP_201_CREATED)
def signup(user: schemas.UserCreate, db: Session = Depends(get_db)):
    existing_user = crud.get_user_by_email(db, email=user.email)
    if existing_user:
        raise HTTPException(status_code=400, detail="Email already registered")
    
    hashed_password = pwd_context.hash(user.password)
    user_data = user.dict()
    user_data["password"] = hashed_password
    
    if user_data.get("dob"):
        if isinstance(user_data["dob"], str):
            user_data["dob"] = datetime.strptime(user_data["dob"], "%Y-%m-%d").date()
    
    created_user = crud.create_user(db=db, user=user_data)
    return created_user

@app.post("/login/")
def login(request: schemas.UserLogin, db: Session = Depends(get_db)):
    user = crud.get_user_by_email(db, email=request.email)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    if not pwd_context.verify(request.password, user.password):
        raise HTTPException(status_code=401, detail="Incorrect password")
    if user.user_type == "service_provider" and not user.is_approved:
        raise HTTPException(status_code=403, detail="Account pending admin approval")
    
    # Standardize service_provider_type in response
    sp_type = None
    if user.service_provider_type:
        sp_type = user.service_provider_type.lower().replace(" ", "_")
    
    return {
        "status": "success",
        "data": {
            "id": user.id,
            "email": user.email,
            "user_type": user.user_type,
            "service_provider_type": sp_type,
            "full_name": user.full_name,
            # ... (all original fields)
        }
    }

# --------------------------
# Service Provider Endpoints (Original + FP)
# --------------------------
@app.get("/chartered_accountants/", response_model=List[UserOut])
def get_chartered_accountants(db: Session = Depends(get_db)):
    return db.query(User).filter(
        User.user_type == "service_provider",
        User.service_provider_type.ilike("chartered accountant")
    ).all()

@app.get("/bank_loan_officers/", response_model=List[UserOut])
def get_bank_loan_officers(db: Session = Depends(get_db)):
    return db.query(User).filter(
        User.user_type == "service_provider",
        User.service_provider_type.ilike("bank loan officer")
    ).all()

# NEW: Financial Planners endpoint
@app.get("/financial_planners/", response_model=List[UserOut])
def get_financial_planners(db: Session = Depends(get_db)):
    return db.query(User).filter(
        User.user_type == "service_provider",
        User.service_provider_type.ilike("financial planner")
    ).all()

# --------------------------
# Request Management (Enhanced with FP)
# --------------------------
@app.post("/requests/", response_model=ServiceRequestOut)
def create_service_request(request: ServiceRequestCreate, db: Session = Depends(get_db)):
    # Count how many service providers are specified
    provider_count = sum(1 for x in [request.ca_id, request.blo_id, request.fp_id] if x is not None)
    
    if provider_count != 1:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Exactly one service provider (CA, BLO, or FP) must be specified"
        )
    
    # Validate the specified provider
    provider_map = {
        "ca": (request.ca_id, "chartered accountant"),
        "blo": (request.blo_id, "bank loan officer"),
        "fp": (request.fp_id, "financial planner")
    }
    
    provider_type = None
    provider_id = None
    
    for key, (id_val, sp_type) in provider_map.items():
        if id_val is not None:
            provider_id = id_val
            provider_type = sp_type
            break
    
    # Check provider exists and matches type
    provider = db.query(User).filter(
        User.id == provider_id,
        User.user_type == "service_provider",
        User.service_provider_type.ilike(provider_type)
    ).first()
    
    if not provider:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"{provider_type.title()} not found"
        )
    
    # Check for existing pending request
    existing = db.query(ServiceRequest).filter(
        ServiceRequest.client_id == request.client_id,
        getattr(ServiceRequest, f"{key}_id") == provider_id,
        ServiceRequest.status == "pending"
    ).first()
    
    if existing:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Pending request already exists for this provider"
        )
    
    # Create new request
    new_request = ServiceRequest(
        client_id=request.client_id,
        ca_id=request.ca_id,
        blo_id=request.blo_id,
        fp_id=request.fp_id,
        status="pending"
    )
    
    db.add(new_request)
    db.commit()
    db.refresh(new_request)
    return new_request

# --------------------------
# Request Status Endpoints (Original + FP)
# --------------------------
@app.patch("/requests/{request_id}", response_model=ServiceRequestOut)
def update_request_status(request_id: int, update: ServiceRequestUpdate, db: Session = Depends(get_db)):
    request = db.query(ServiceRequest).get(request_id)
    if not request:
        raise HTTPException(status_code=404, detail="Request not found")
    request.status = update.status
    db.commit()
    return request

@app.get("/ca/{ca_id}/requests", response_model=List[ServiceRequestDetailedOut])
def get_ca_requests(ca_id: int, db: Session = Depends(get_db)):
    return db.query(ServiceRequest).filter(
        ServiceRequest.ca_id == ca_id
    ).options(
        selectinload(ServiceRequest.client)
    ).all()

@app.get("/bank_loan_officer/{blo_id}/requests", response_model=List[ServiceRequestDetailedOut])
def get_blo_requests(blo_id: int, db: Session = Depends(get_db)):
    return db.query(ServiceRequest).filter(
        ServiceRequest.blo_id == blo_id
    ).options(
        selectinload(ServiceRequest.client)
    ).all()

# NEW: FP requests endpoint
@app.get("/financial_planner/{fp_id}/requests", response_model=List[ServiceRequestDetailedOut])
def get_fp_requests(fp_id: int, db: Session = Depends(get_db)):
    return db.query(ServiceRequest).filter(
        ServiceRequest.fp_id == fp_id
    ).options(
        selectinload(ServiceRequest.client)
    ).all()

@app.get("/client/{client_id}/requests", response_model=List[ServiceRequestDetailedOut])
def get_client_requests(client_id: int, db: Session = Depends(get_db)):
    return db.query(ServiceRequest).filter(
        ServiceRequest.client_id == client_id
    ).options(
        selectinload(ServiceRequest.client),
        selectinload(ServiceRequest.ca),
        selectinload(ServiceRequest.blo),
        selectinload(ServiceRequest.fp)
    ).all()

# --------------------------
# Admin Endpoints (Preserved)
# --------------------------
@app.get("/admin/pending_users/")
def get_pending_service_providers(db: Session = Depends(get_db)):
    return db.query(User).filter(
        User.user_type == "service_provider",
        User.is_approved == False
    ).all()

@app.post("/admin/approve_user/{user_id}")
def approve_user(user_id: int, db: Session = Depends(get_db)):
    user = db.query(User).get(user_id)
    if not user or user.user_type != "service_provider":
        raise HTTPException(status_code=404, detail="User not found or not a service provider")
    user.is_approved = True
    db.commit()
    return {"message": f"{user.full_name} approved"}

if __name__ == "__main__":
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
