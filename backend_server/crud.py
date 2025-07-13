from sqlalchemy.orm import Session
from datetime import date
import models, schemas

def get_user_by_email(db: Session, email: str):
    return db.query(models.User).filter(models.User.email == email).first()

def create_user(db: Session, user: dict):
    is_approved = True
    if user["user_type"] == "service_provider":
        is_approved = False  # require admin approval
    db_user = models.User(
        user_type=user["user_type"],
        client_type=user.get("client_type"),
        service_provider_type=user.get("service_provider_type"),
        full_name=user["full_name"],
        email=user["email"],
        phone=user["phone"],
        address=user["address"],
        password=user["password"],
        profession=user.get("profession"),
        gender=user.get("gender"),
        dob=user.get("dob"),
        enterprise_name=user.get("enterprise_name"),
        tin_number=user.get("tin_number"),
        business_type=user.get("business_type"),
        experience=user.get("experience"),
        qualification=user.get("qualification"),
        is_approved=is_approved
    )
    
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return db_user