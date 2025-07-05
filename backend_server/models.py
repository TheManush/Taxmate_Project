from sqlalchemy import Column, Integer, String, Date,ForeignKey, Enum, Float, Text, DateTime
from database import Base
from sqlalchemy.orm import relationship
from datetime import datetime

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
    financial_data = relationship("FinancialData", back_populates="client", uselist=False)
    chat_messages = relationship("ChatMessage", back_populates="client")

class ServiceRequest(Base):
    __tablename__ = "service_requests"

    id = Column(Integer, primary_key=True, index=True)
    client_id = Column(Integer, ForeignKey('users.id'), nullable=False)
    ca_id = Column(Integer, ForeignKey('users.id'), nullable=False)
    status = Column(String(20), default='pending')  # 'pending', 'approved', 'rejected'

    client = relationship("User", back_populates="service_requests_sent", foreign_keys=[client_id])
    ca = relationship("User", back_populates="service_requests_received", foreign_keys=[ca_id])

class FinancialData(Base):
    __tablename__ = "financial_data"

    id = Column(Integer, primary_key=True, index=True)
    client_id = Column(Integer, ForeignKey('users.id'), nullable=False)
    
    # Income Details
    monthly_salary = Column(Float, default=0.0)
    annual_bonus = Column(Float, default=0.0)
    other_income = Column(Float, default=0.0)
    
    # Expenses
    monthly_rent = Column(Float, default=0.0)
    utilities = Column(Float, default=0.0)
    food_expenses = Column(Float, default=0.0)
    transportation = Column(Float, default=0.0)
    entertainment = Column(Float, default=0.0)
    healthcare = Column(Float, default=0.0)
    other_expenses = Column(Float, default=0.0)
    
    # Assets
    savings_account = Column(Float, default=0.0)
    checking_account = Column(Float, default=0.0)
    investments = Column(Float, default=0.0)
    property_value = Column(Float, default=0.0)
    vehicle_value = Column(Float, default=0.0)
    other_assets = Column(Float, default=0.0)
    
    # Liabilities
    credit_card_debt = Column(Float, default=0.0)
    student_loans = Column(Float, default=0.0)
    mortgage = Column(Float, default=0.0)
    car_loan = Column(Float, default=0.0)
    other_debts = Column(Float, default=0.0)
    
    # Goals
    financial_goals = Column(Text)
    risk_tolerance = Column(String(20))  # Conservative, Moderate, Aggressive
    
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationship
    client = relationship("User", back_populates="financial_data")

class ChatMessage(Base):
    __tablename__ = "chat_messages"

    id = Column(Integer, primary_key=True, index=True)
    client_id = Column(Integer, ForeignKey('users.id'), nullable=False)
    message = Column(Text, nullable=False)
    response = Column(Text, nullable=False)
    timestamp = Column(DateTime, default=datetime.utcnow)
    
    # Relationship
    client = relationship("User", back_populates="chat_messages")