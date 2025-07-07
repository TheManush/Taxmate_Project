from sqlalchemy import Column, Integer, String, Date,ForeignKey,DateTime, Enum
from database import Base
from datetime import datetime
from sqlalchemy.orm import relationship

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
    
    #relationships
    service_requests_sent = relationship("ServiceRequest", back_populates="client", foreign_keys='ServiceRequest.client_id')
    service_requests_received = relationship("ServiceRequest", back_populates="ca", foreign_keys='ServiceRequest.ca_id')

class ServiceRequest(Base):
    __tablename__ = "service_requests"

    id = Column(Integer, primary_key=True, index=True)
    client_id = Column(Integer, ForeignKey('users.id'), nullable=False)
    ca_id = Column(Integer, ForeignKey('users.id'), nullable=False)
    status = Column(String(20), default='pending')  # 'pending', 'approved', 'rejected'

    client = relationship("User", back_populates="service_requests_sent", foreign_keys=[client_id])
    ca = relationship("User", back_populates="service_requests_received", foreign_keys=[ca_id])


