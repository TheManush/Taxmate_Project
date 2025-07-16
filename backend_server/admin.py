# create_admin.py
from database import SessionLocal
from models import User
from passlib.hash import bcrypt  # assuming you're hashing passwords

db = SessionLocal()

admin_email = "admin@gmail.com"
existing_admin = db.query(User).filter_by(email=admin_email).first()

if not existing_admin:
    admin = User(
        user_type="admin",
        full_name="Admin User",
        email=admin_email,
        phone="0000000000",
        address="Admin HQ",
        password=bcrypt.hash("admin123"),  # replace with strong password
    )
    db.add(admin)
    db.commit()
    print("Admin user created.")
else:
    print("Admin user already exists.")
