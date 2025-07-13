
# Standard library imports
from datetime import date, datetime
from typing import Optional, List

# Third-party imports
from fastapi import Body, FastAPI, Depends, HTTPException, status, APIRouter
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
import uvicorn
from passlib.context import CryptContext

# Local app imports
import models, schemas, crud
from database import SessionLocal, engine, get_db
from models import User, ServiceRequest
from schemas import UserOut, UserShort, ServiceRequestCreate, ServiceRequestOut
from file_upload import router as upload_router
from chat1 import chat_router
from fcm_utils import send_fcm_v1_notification

# Create tables
models.Base.metadata.create_all(bind=engine)

app = FastAPI()

app.include_router(upload_router)
app.include_router(chat_router)
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

# Endpoint to register/update FCM token for a user
@app.post("/register_fcm_token/")
def register_fcm_token(user_id: int = Body(...), fcm_token: str = Body(...), db: Session = Depends(get_db)):
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    user.fcm_token = fcm_token
    db.commit()
    return {"message": "FCM token updated successfully"}
# Dependency to get DB session


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
     # Check approval for service providers
    if user.user_type == "service_provider" and not user.is_approved:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Account pending admin approval"
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

@app.get("/bank_loan_officers/", response_model=List[UserOut])
def get_bank_loan_officers(db: Session = Depends(get_db)):
    blo_users = db.query(User).filter(
        User.user_type == "service_provider",
        User.service_provider_type.ilike("bank loan officer")
    ).all()
    return blo_users

from sqlalchemy.orm import selectinload
from schemas import ServiceRequestUpdate, ServiceRequestDetailedOut

@app.post("/requests/", response_model=ServiceRequestOut, status_code=status.HTTP_201_CREATED)
def create_service_request(request: ServiceRequestCreate, db: Session = Depends(get_db)):
    try:
        print(f"DEBUG: Creating service request with data: {request}")
        print(f"DEBUG: ca_id={request.ca_id}, blo_id={request.blo_id}, client_id={request.client_id}")
        
        # Validate that either ca_id or blo_id is provided, but not both
        if not request.ca_id and not request.blo_id:
            print("DEBUG: Neither CA ID nor BLO ID provided")
            raise HTTPException(status_code=400, detail="Either CA ID or BLO ID must be provided")
        
        if request.ca_id and request.blo_id:
            print("DEBUG: Both CA ID and BLO ID provided")
            raise HTTPException(status_code=400, detail="Cannot request both CA and BLO services simultaneously")
    
        # Handle CA requests (original functionality)
        if request.ca_id:
            print(f"DEBUG: Processing CA request for CA ID: {request.ca_id}")
            ca_user = db.query(User).filter(
                User.id == request.ca_id,
                User.user_type == "service_provider",
                User.service_provider_type.ilike("chartered accountant")
            ).first()
            if not ca_user:
                print(f"DEBUG: CA user not found for ID: {request.ca_id}")
                raise HTTPException(status_code=404, detail="Chartered Accountant not found")
            
            # Check for existing CA request
            existing = db.query(ServiceRequest).filter_by(
                client_id=request.client_id,
                ca_id=request.ca_id,
                status="pending"
            ).first()
            if existing:
                print(f"DEBUG: CA request already exists for client {request.client_id}")
                raise HTTPException(status_code=400, detail="Request already sent")
        
        # Handle BLO requests (new functionality)
        if request.blo_id:
            print(f"DEBUG: Processing BLO request for BLO ID: {request.blo_id}")
            blo_user = db.query(User).filter(
                User.id == request.blo_id,
                User.user_type == "service_provider",
                User.service_provider_type.ilike("bank loan officer")
            ).first()
            if not blo_user:
                print(f"DEBUG: BLO user not found for ID: {request.blo_id}")
                raise HTTPException(status_code=404, detail="Bank Loan Officer not found")
            
            # Check for existing BLO request
            existing = db.query(ServiceRequest).filter_by(
                client_id=request.client_id,
                blo_id=request.blo_id,
                status="pending"
            ).first()
            if existing:
                print(f"DEBUG: BLO request already exists for client {request.client_id}")
                raise HTTPException(status_code=400, detail="Request already sent")

        print(f"DEBUG: Creating new ServiceRequest object")
        new_request = ServiceRequest(
            client_id=request.client_id,
            ca_id=request.ca_id,
            blo_id=request.blo_id,
            status="pending"
        )
        print(f"DEBUG: Adding to database")
        db.add(new_request)
        db.commit()
        db.refresh(new_request)
        print(f"DEBUG: Request created successfully with ID: {new_request.id}")
        return new_request
        
    except Exception as e:
        print(f"DEBUG: Exception occurred: {str(e)}")
        print(f"DEBUG: Exception type: {type(e)}")
        import traceback
        traceback.print_exc()
        raise HTTPException(status_code=500, detail=f"Internal server error: {str(e)}")


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
    requests = db.query(ServiceRequest).filter(
        ServiceRequest.ca_id == ca_id
    ).options(
        selectinload(ServiceRequest.client),
        selectinload(ServiceRequest.ca)
    ).all()
    return requests

@app.get("/bank_loan_officer/{blo_id}/requests", response_model=List[ServiceRequestDetailedOut])
def get_requests_for_blo(blo_id: int, db: Session = Depends(get_db)):
    requests = db.query(ServiceRequest).filter(
        ServiceRequest.blo_id == blo_id
    ).options(
        selectinload(ServiceRequest.client),
        selectinload(ServiceRequest.blo)
    ).all()
    return requests

@app.get("/client/{client_id}/requests", response_model=List[ServiceRequestDetailedOut])
def get_requests_for_client(client_id: int, db: Session = Depends(get_db)):
    try:
        requests = db.query(ServiceRequest).filter_by(client_id=client_id).options(
            selectinload(ServiceRequest.ca),
            selectinload(ServiceRequest.blo),
            selectinload(ServiceRequest.client)
        ).all()
        
        # Debug: Print what we're returning
        print(f"Found {len(requests)} requests for client {client_id}")
        for req in requests:
            print(f"Request {req.id}: ca_id={req.ca_id}, blo_id={req.blo_id}, status={req.status}")
            
        return requests
    except Exception as e:
        print(f"Error fetching client requests: {e}")
        raise HTTPException(status_code=500, detail=f"Error fetching requests: {str(e)}")

@app.get("/ca/{ca_id}/approved_clients", response_model=List[UserShort])
def get_approved_clients_for_ca(ca_id: int, db: Session = Depends(get_db)):
    approved_requests = db.query(ServiceRequest).filter(
        ServiceRequest.ca_id == ca_id,
        ServiceRequest.status == "approved"
    ).all()
    
    client_ids = [req.client_id for req in approved_requests]
    if not client_ids:
        return []

    clients = db.query(User).filter(User.id.in_(client_ids)).all()
    return clients

@app.get("/bank_loan_officer/{blo_id}/approved_clients", response_model=List[UserShort])
def get_approved_clients_for_blo(blo_id: int, db: Session = Depends(get_db)):
    approved_requests = db.query(ServiceRequest).filter(
        ServiceRequest.blo_id == blo_id,
        ServiceRequest.status == "approved"
    ).all()
    
    client_ids = [req.client_id for req in approved_requests]
    if not client_ids:
        return []

    clients = db.query(User).filter(User.id.in_(client_ids)).all()
    return clients


@app.get("/admin/pending_users/")
def get_pending_service_providers(db: Session = Depends(get_db)):
    pending_users = db.query(models.User).filter(
        models.User.user_type == "service_provider",
        models.User.is_approved == False
    ).all()
    return pending_users

# ✅ Approve a specific service provider by ID
@app.post("/admin/approve_user/{user_id}")
def approve_user(user_id: int, db: Session = Depends(get_db)):
    user = db.query(models.User).filter(models.User.id == user_id).first()

    # Check if user exists and is a service provider
    if not user or user.user_type != "service_provider":
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found or not a service provider"
        )

    # Update approval status
    user.is_approved = True
    db.commit()
    return {"message": f"{user.full_name} has been approved."}


if __name__ == "__main__":
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)