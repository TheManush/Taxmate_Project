from sqlalchemy import Column, Integer, String, Date
from database import Base

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    user_type = Column(String(50), nullable=False)  # client, service_provider, admin
    client_type = Column(String(50), nullable=True)  # individual, enterprise
    service_provider_type = Column(String(50), nullable=True)  # ca, financial_planner, loan_officer
    full_name = Column(String(100), nullable=False)
    email = Column(String(100), unique=True, index=True, nullable=False)
    phone = Column(String(20), nullable=False)
    address = Column(String, nullable=False)
    password = Column(String, nullable=False)
    
    # Client fields
    profession = Column(String(100), nullable=True)
    gender = Column(String(10), nullable=True)
    dob = Column(Date, nullable=True)
    
    # Enterprise client fields
    enterprise_name = Column(String(100), nullable=True)
    tin_number = Column(String(50), nullable=True)
    business_type = Column(String(50), nullable=True)
    
    # Service provider fields
    experience = Column(String(50), nullable=True)
    qualification = Column(String, nullable=True)