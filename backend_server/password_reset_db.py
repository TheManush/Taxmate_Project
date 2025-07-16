"""
Database-based Password Reset Module for TaxMate App
This version stores tokens in the database for production use
"""

from datetime import datetime, timedelta
from typing import Dict, Any
import secrets
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from fastapi import Body, Depends, HTTPException
from sqlalchemy.orm import Session
from passlib.context import CryptContext

from database import get_db
from models import User, PasswordResetToken
from email_config import EMAIL_CONFIG, EMAIL_TEMPLATES

# Password hashing context
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def send_email(to_email: str, subject: str, body: str) -> bool:
    """
    Send email using SMTP. Configure with your email provider.
    For production, use a proper email service like SendGrid, AWS SES, etc.
    """
    try:
        # Get email configuration
        config = EMAIL_CONFIG
        
        msg = MIMEMultipart()
        msg['From'] = config["smtp_username"]
        msg['To'] = to_email
        msg['Subject'] = subject
        
        msg.attach(MIMEText(body, 'html'))
        
        server = smtplib.SMTP(config["smtp_server"], config["smtp_port"])
        server.starttls()
        server.login(config["smtp_username"], config["smtp_password"])
        text = msg.as_string()
        server.sendmail(config["smtp_username"], to_email, text)
        server.quit()
        
        print(f"Email sent successfully to {to_email}")
        return True
    except Exception as e:
        print(f"Error sending email: {e}")
        return False

def forgot_password_handler_db(email: str, db: Session) -> Dict[str, str]:
    """
    Handle forgot password request using database storage
    """
    try:
        # Check if user exists
        user = db.query(User).filter(User.email == email).first()
        if not user:
            # Don't reveal if email exists or not for security
            return {"message": "If the email exists, a reset link has been sent"}
        
        # Clean up any existing unused tokens for this email
        db.query(PasswordResetToken).filter(
            PasswordResetToken.email == email,
            PasswordResetToken.used == False
        ).delete()
        
        # Generate reset token
        reset_token = secrets.token_urlsafe(32)
        
        # Create database record
        expiration = datetime.utcnow() + timedelta(hours=1)
        token_record = PasswordResetToken(
            email=email,
            token=reset_token,
            expires_at=expiration,
            used=False
        )
        
        db.add(token_record)
        db.commit()
        
        # Create reset link
        reset_link = f"https://yourapp.com/reset-password?token={reset_token}"
        
        # Get email template
        template = EMAIL_TEMPLATES["password_reset"]
        subject = template["subject"]
        body = template["body_template"].format(
            user_name=user.full_name,
            reset_link=reset_link
        )
        
        # Send email (for development, just print the token)
        if send_email(email, subject, body):
            print(f"Password reset token for {email}: {reset_token}")  # For development
            return {"message": "If the email exists, a reset link has been sent"}
        else:
            # For development, still return success and print token
            print(f"Password reset token for {email}: {reset_token}")  # For development
            return {"message": "If the email exists, a reset link has been sent"}
            
    except Exception as e:
        print(f"Error in forgot password: {e}")
        db.rollback()
        raise HTTPException(status_code=500, detail="Internal server error")

def reset_password_handler_db(token: str, new_password: str, db: Session) -> Dict[str, str]:
    """
    Handle password reset request using database storage
    """
    try:
        # Find the token in database
        token_record = db.query(PasswordResetToken).filter(
            PasswordResetToken.token == token,
            PasswordResetToken.used == False
        ).first()
        
        if not token_record:
            raise HTTPException(status_code=400, detail="Invalid or expired reset token")
        
        # Check if token has expired
        if datetime.utcnow() > token_record.expires_at:
            # Mark as used and delete
            db.delete(token_record)
            db.commit()
            raise HTTPException(status_code=400, detail="Invalid or expired reset token")
        
        # Get user
        user = db.query(User).filter(User.email == token_record.email).first()
        if not user:
            raise HTTPException(status_code=404, detail="User not found")
        
        # Hash new password
        hashed_password = pwd_context.hash(new_password)
        
        # Update user password
        user.password = hashed_password
        
        # Mark token as used
        token_record.used = True
        
        db.commit()
        
        return {"message": "Password reset successfully"}
        
    except HTTPException:
        raise
    except Exception as e:
        print(f"Error in reset password: {e}")
        db.rollback()
        raise HTTPException(status_code=500, detail="Internal server error")

def cleanup_expired_tokens_db(db: Session):
    """
    Clean up expired tokens from database
    """
    try:
        current_time = datetime.utcnow()
        expired_count = db.query(PasswordResetToken).filter(
            PasswordResetToken.expires_at < current_time
        ).delete()
        
        db.commit()
        
        if expired_count > 0:
            print(f"Cleaned up {expired_count} expired password reset tokens")
            
    except Exception as e:
        print(f"Error cleaning up expired tokens: {e}")
        db.rollback()
