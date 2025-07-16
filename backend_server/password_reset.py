"""
Password Reset Module for TaxMate App
Handles forgot password and reset password functionality
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
from models import User
from email_config import EMAIL_CONFIG, EMAIL_TEMPLATES

# Password hashing context
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

# In-memory store for reset tokens (in production, use Redis or database)
password_reset_tokens: Dict[str, Dict[str, Any]] = {}

def send_email(to_email: str, subject: str, body: str) -> bool:
    """
    Send email using SMTP. Configure with your email provider.
    For production, use a proper email service like SendGrid, AWS SES, etc.
    """
    try:
        # Get email configuration
        config = EMAIL_CONFIG
        
        print(f"Attempting to send email from {config['smtp_username']} to {to_email}")
        
        msg = MIMEMultipart()
        msg['From'] = f"{config['sender_name']} <{config['smtp_username']}>"
        msg['To'] = to_email
        msg['Subject'] = subject
        msg['Reply-To'] = config["smtp_username"]
        
        msg.attach(MIMEText(body, 'html'))
        
        server = smtplib.SMTP(config["smtp_server"], config["smtp_port"])
        server.set_debuglevel(1)  # Enable debug output
        server.starttls()
        print("STARTTLS successful")
        
        server.login(config["smtp_username"], config["smtp_password"])
        print("Login successful")
        
        text = msg.as_string()
        server.sendmail(config["smtp_username"], to_email, text)
        print("Email sending command successful")
        
        server.quit()
        print(f"Email sent successfully to {to_email}")
        return True
    except Exception as e:
        print(f"Error sending email: {e}")
        return False

def forgot_password_handler(email: str, db: Session) -> Dict[str, str]:
    """
    Handle forgot password request
    """
    try:
        # Check if user exists
        user = db.query(User).filter(User.email == email).first()
        if not user:
            # Don't reveal if email exists or not for security
            return {"message": "If the email exists, a reset link has been sent"}
        
        # Generate reset token
        reset_token = secrets.token_urlsafe(32)
        
        # Store token with expiration (1 hour)
        expiration = datetime.now() + timedelta(hours=1)
        password_reset_tokens[reset_token] = {
            "email": email,
            "expires": expiration
        }
        
        # Create reset link - provide the token for copy/paste
        reset_link = f"{reset_token}"
        
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
        raise HTTPException(status_code=500, detail="Internal server error")

def reset_password_handler(token: str, new_password: str, db: Session) -> Dict[str, str]:
    """
    Handle password reset request
    """
    try:
        # Check if token exists and is valid
        if token not in password_reset_tokens:
            raise HTTPException(status_code=400, detail="Invalid or expired reset token")
        
        token_data = password_reset_tokens[token]
        
        # Check if token has expired
        if datetime.now() > token_data["expires"]:
            del password_reset_tokens[token]  # Clean up expired token
            raise HTTPException(status_code=400, detail="Invalid or expired reset token")
        
        # Get user
        user = db.query(User).filter(User.email == token_data["email"]).first()
        if not user:
            raise HTTPException(status_code=404, detail="User not found")
        
        # Hash new password
        hashed_password = pwd_context.hash(new_password)
        
        # Update user password
        user.password = hashed_password
        db.commit()
        
        # Remove used token
        del password_reset_tokens[token]
        
        return {"message": "Password reset successfully"}
        
    except HTTPException:
        raise
    except Exception as e:
        print(f"Error in reset password: {e}")
        raise HTTPException(status_code=500, detail="Internal server error")

def cleanup_expired_tokens():
    """
    Clean up expired tokens (can be called periodically)
    """
    current_time = datetime.now()
    expired_tokens = [
        token for token, data in password_reset_tokens.items()
        if current_time > data["expires"]
    ]
    
    for token in expired_tokens:
        del password_reset_tokens[token]
    
    if expired_tokens:
        print(f"Cleaned up {len(expired_tokens)} expired password reset tokens")
