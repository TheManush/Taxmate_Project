from fastapi import FastAPI, Depends, HTTPException, status
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
from datetime import date, datetime
from typing import Optional
import models, schemas, crud
from database import SessionLocal, engine
import uvicorn
from passlib.context import CryptContext
from fastapi import APIRouter, Depends
from typing import List
from models import User  
from schemas import UserOut, UserShort
from models import User, ServiceRequest
from schemas import ServiceRequestCreate, ServiceRequestOut
from fastapi import status
from file_upload import router as upload_router

# Create tables
models.Base.metadata.create_all(bind=engine)


app = FastAPI()

app.include_router(upload_router)
# Password hashing
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

# CORS configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Dependency to get DB session
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@app.post("/signup/", response_model=schemas.UserOut, status_code=status.HTTP_201_CREATED)
def signup(user: schemas.UserCreate, db: Session = Depends(get_db)):
    # Check if email already exists
    existing_user = crud.get_user_by_email(db, email=user.email)
    if existing_user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email already registered"
        )
    
    # Hash the password
    hashed_password = pwd_context.hash(user.password)
    user_data = user.dict()
    user_data["password"] = hashed_password
    
    # Convert date string to date object if exists
    if user_data.get("dob"):
        if isinstance(user_data["dob"], str):
            user_data["dob"] = datetime.strptime(user_data["dob"], "%Y-%m-%d").date()
    
    created_user = crud.create_user(db=db, user=user_data)
    
    return schemas.UserOut(
        id=created_user.id,
        email=created_user.email,
        user_type=created_user.user_type,
        full_name=created_user.full_name,
        phone=created_user.phone,
        address=created_user.address,
        client_type=created_user.client_type,
        service_provider_type=created_user.service_provider_type
    )

@app.post("/login/")
def login(request: schemas.UserLogin, db: Session = Depends(get_db)):
    user = crud.get_user_by_email(db, email=request.email)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found"
        )

    # Verify password
    if not pwd_context.verify(request.password, user.password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect password"
        )

    return {
        "status": "success",
        "message": "Login successful",
        "data": {
            "id": user.id,
            "email": user.email,
            "user_type": user.user_type,
            "full_name": user.full_name,
            "phone": user.phone,
            "address": user.address,
            "client_type": user.client_type,
            "service_provider_type": user.service_provider_type,
            "profession": user.profession,
            "gender": user.gender,
            "dob": str(user.dob) if user.dob else None,
            "enterprise_name": user.enterprise_name,
            "tin_number": user.tin_number,
            "business_type": user.business_type,
            "experience": user.experience,
            "qualification": user.qualification
        }
    }

@app.get("/chartered_accountants/", response_model=List[UserOut])
def get_chartered_accountants(db: Session = Depends(get_db)):
    ca_users = db.query(User).filter(
        User.user_type == "service_provider",
        User.service_provider_type.ilike("chartered accountant")
    ).all()
    return ca_users

from sqlalchemy.orm import selectinload
from schemas import ServiceRequestUpdate, ServiceRequestDetailedOut

@app.post("/requests/", response_model=ServiceRequestOut, status_code=status.HTTP_201_CREATED)
def create_service_request(request: ServiceRequestCreate, db: Session = Depends(get_db)):
    # Check if CA exists and is of correct type
    ca_user = db.query(User).filter(
        User.id == request.ca_id,
        User.user_type == "service_provider",
        User.service_provider_type.ilike("chartered accountant")
    ).first()
    if not ca_user:
        raise HTTPException(status_code=404, detail="Chartered Accountant not found")

    # Prevent duplicate pending request
    existing = db.query(ServiceRequest).filter_by(
        client_id=request.client_id,
        ca_id=request.ca_id,
        status="pending"
    ).first()
    if existing:
        raise HTTPException(status_code=400, detail="Request already sent")

    new_request = ServiceRequest(
        client_id=request.client_id,
        ca_id=request.ca_id,
        status="pending"
    )
    db.add(new_request)
    db.commit()
    db.refresh(new_request)
    return new_request


@app.patch("/requests/{request_id}", response_model=ServiceRequestOut)
def update_request_status(request_id: int, update: ServiceRequestUpdate, db: Session = Depends(get_db)):
    service_request = db.query(ServiceRequest).filter_by(id=request_id).first()
    if not service_request:
        raise HTTPException(status_code=404, detail="Request not found")
    
    service_request.status = update.status
    db.commit()
    db.refresh(service_request)
    return service_request


@app.get("/ca/{ca_id}/requests", response_model=List[ServiceRequestDetailedOut])
def get_requests_for_ca(ca_id: int, db: Session = Depends(get_db)):
    requests = db.query(ServiceRequest).filter_by(ca_id=ca_id).options(
        selectinload(ServiceRequest.client),
        selectinload(ServiceRequest.ca)
    ).all()
    return requests

@app.get("/client/{client_id}/requests", response_model=List[ServiceRequestDetailedOut])
def get_requests_for_client(client_id: int, db: Session = Depends(get_db)):
    requests = db.query(ServiceRequest).filter_by(client_id=client_id).options(
        selectinload(ServiceRequest.ca),
        selectinload(ServiceRequest.client)
    ).all()
    return requests

@app.get("/ca/{ca_id}/approved_clients", response_model=List[UserShort])
def get_approved_clients_for_ca(ca_id: int, db: Session = Depends(get_db)):
    approved_requests = db.query(ServiceRequest).filter_by(
        ca_id=ca_id, status="approved"
    ).all()
    
    client_ids = [req.client_id for req in approved_requests]

    clients = db.query(User).filter(User.id.in_(client_ids)).all()
    return clients


if __name__ == "__main__":
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)