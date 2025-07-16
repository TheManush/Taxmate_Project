from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
import smtplib
import random
from email.mime.text import MIMEText
from sqlalchemy.orm import Session
from database import get_db
from models import User
from passlib.context import CryptContext

router = APIRouter()
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

otp_store = {}

# Gmail credentials
EMAIL = "taxmateserver@gmail.com"
APP_PASSWORD = "ulez mwcr obgv piql"

class EmailSchema(BaseModel):
    email: str

class VerifySchema(BaseModel):
    email: str
    otp: str
    new_password: str
    confirm_password: str

@router.post("/send-otp/")
def send_otp(data: EmailSchema, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.email == data.email).first()
    if not user:
        raise HTTPException(status_code=404, detail="Email not found")

    otp = str(random.randint(100000, 999999))
    otp_store[data.email] = otp

    msg = MIMEText(f"Your OTP is {otp}")
    msg["Subject"] = "Password Recovery OTP"
    msg["From"] = EMAIL
    msg["To"] = data.email

    try:
        server = smtplib.SMTP("smtp.gmail.com", 587)
        server.starttls()
        server.login(EMAIL, APP_PASSWORD)
        server.sendmail(EMAIL, [data.email], msg.as_string())
        server.quit()
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Email sending failed: {e}")

    return {"message": "OTP sent successfully"}

@router.post("/verify-otp/")
def verify_otp(data: VerifySchema, db: Session = Depends(get_db)):
    if data.email not in otp_store or otp_store[data.email] != data.otp:
        raise HTTPException(status_code=400, detail="Invalid OTP")

    if data.new_password != data.confirm_password:
        raise HTTPException(status_code=400, detail="Passwords do not match")

    hashed_password = pwd_context.hash(data.new_password)
    user = db.query(User).filter(User.email == data.email).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    user.password = hashed_password
    db.commit()

    del otp_store[data.email]
    return {"message": "Password updated successfully"}
