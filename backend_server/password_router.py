"""
FastAPI Router for Password Reset Endpoints
"""

from fastapi import APIRouter, Body, Depends, HTTPException
from sqlalchemy.orm import Session
from database import get_db
from password_reset import forgot_password_handler, reset_password_handler

# Create router
password_router = APIRouter()

@password_router.post("/forgot-password")
def forgot_password(email: str = Body(..., embed=True), db: Session = Depends(get_db)):
    """
    Send password reset email to user
    """
    return forgot_password_handler(email, db)

@password_router.post("/reset-password")
def reset_password(
    token: str = Body(...), 
    new_password: str = Body(...), 
    db: Session = Depends(get_db)
):
    """
    Reset password using the token
    """
    return reset_password_handler(token, new_password, db)
