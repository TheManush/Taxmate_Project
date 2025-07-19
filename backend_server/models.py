from sqlalchemy import Column, Integer, String, Date,ForeignKey,DateTime, Enum,Boolean, Text, Float
from database import Base
from datetime import datetime,timezone
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
    is_approved = Column(Boolean, default=True)
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
    
    # FCM token for push notifications
    fcm_token = Column(String(255), nullable=True)

    #relationships
    service_requests_sent = relationship("ServiceRequest", back_populates="client", foreign_keys='ServiceRequest.client_id')
    service_requests_received = relationship("ServiceRequest", back_populates="ca", foreign_keys='ServiceRequest.ca_id')
    blo_requests_received = relationship("ServiceRequest", back_populates="blo", foreign_keys='ServiceRequest.blo_id')
    fp_requests_received = relationship("ServiceRequest", back_populates="fp", foreign_keys='ServiceRequest.fp_id')

class ServiceRequest(Base):
    __tablename__ = "service_requests"

    id = Column(Integer, primary_key=True, index=True)
    client_id = Column(Integer, ForeignKey('users.id'), nullable=False)
    ca_id = Column(Integer, ForeignKey('users.id'), nullable=True)
    blo_id = Column(Integer, ForeignKey('users.id'), nullable=True)
    fp_id = Column(Integer, ForeignKey('users.id'), nullable=True)
    status = Column(String(20), default='pending')  # 'pending', 'approved', 'rejected'

    client = relationship("User", back_populates="service_requests_sent", foreign_keys=[client_id])
    ca = relationship("User", back_populates="service_requests_received", foreign_keys=[ca_id])
    blo = relationship("User", back_populates="blo_requests_received", foreign_keys=[blo_id])
    fp = relationship("User", back_populates="fp_requests_received", foreign_keys=[fp_id])


class Message(Base):
    __tablename__ = "messages" 
    id = Column(Integer, primary_key=True)
    sender_id = Column(Integer)
    receiver_id = Column(Integer)
    message = Column(String)
    timestamp = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))

class LoanRequest(Base):
    __tablename__ = "loan_requests"

    id = Column(Integer, primary_key=True, index=True)
    client_id = Column(Integer, ForeignKey('users.id'), nullable=False)
    blo_id = Column(Integer, ForeignKey('users.id'), nullable=False)
    
    # Personal Info
    full_name = Column(String(100), nullable=False)
    date_of_birth = Column(Date, nullable=False)
    nid_number = Column(String(50), nullable=False)
    phone_number = Column(String(20), nullable=False)
    email = Column(String(100), nullable=False)
    present_address = Column(Text, nullable=False)
    
    # Business Info
    employment_type = Column(String(50), nullable=False)  # salaried, self-employed, business owner, freelancer
    company_name = Column(String(100), nullable=True)
    designation = Column(String(100), nullable=True)
    monthly_income = Column(Float, nullable=False)
    length_of_employment = Column(String(50), nullable=False)
    
    # Loan Details
    loan_type = Column(String(100), nullable=False)
    requested_amount = Column(Float, nullable=False)
    loan_tenure = Column(String(50), nullable=False)
    purpose_of_loan = Column(Text, nullable=False)
    preferred_bank = Column(String(100), nullable=False)
    
    # Additional Info (Optional)
    guarantor_name = Column(String(100), nullable=True)
    guarantor_nid = Column(String(50), nullable=True)
    guarantor_phone = Column(String(20), nullable=True)
    collateral_info = Column(Text, nullable=True)
    notes_remarks = Column(Text, nullable=True)
    
    # Status and timestamps
    status = Column(String(20), default='pending')  # pending, under_review, approved, rejected
    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))
    updated_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc))

    # Relationships
    client = relationship("User", foreign_keys=[client_id])
    blo = relationship("User", foreign_keys=[blo_id])

class LoanStatus(Base):
    __tablename__ = "loan_status"

    id = Column(Integer, primary_key=True, index=True)
    loan_request_id = Column(Integer, ForeignKey('loan_requests.id'), nullable=False)
    client_id = Column(Integer, ForeignKey('users.id'), nullable=False)
    blo_id = Column(Integer, ForeignKey('users.id'), nullable=False)
    status = Column(String(20), nullable=False)  # approved, rejected, pending, missing_info
    message = Column(Text, nullable=True)  # Additional message from BLO
    updated_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))
    
    # Store loan details for easy access
    requested_amount = Column(Float, nullable=True)
    purpose_of_loan = Column(Text, nullable=True)
    preferred_bank = Column(String(100), nullable=True)
    loan_tenure = Column(String(50), nullable=True)
    
    # Relationships
    loan_request = relationship("LoanRequest", foreign_keys=[loan_request_id])
    client = relationship("User", foreign_keys=[client_id])
    blo = relationship("User", foreign_keys=[blo_id])

class PasswordResetToken(Base):
    __tablename__ = "password_reset_tokens"
    
    id = Column(Integer, primary_key=True, index=True)
    email = Column(String(100), nullable=False, index=True)
    token = Column(String(255), unique=True, nullable=False, index=True)
    expires_at = Column(DateTime(timezone=True), nullable=False)
    used = Column(Boolean, default=False, nullable=False)
    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))
    
    # Relationship to user
    user = relationship("User", foreign_keys=[email], primaryjoin="User.email == PasswordResetToken.email")

class FinancialData(Base):
    __tablename__ = "financial_data"
    
    id = Column(Integer, primary_key=True, index=True)
    client_id = Column(Integer, ForeignKey('users.id'), nullable=False)
    
    # Income fields
    monthly_salary = Column(Float, default=0.0)
    annual_bonus = Column(Float, default=0.0)
    other_income = Column(Float, default=0.0)
    
    # Expense fields
    monthly_rent = Column(Float, default=0.0)
    utilities = Column(Float, default=0.0)
    food_expenses = Column(Float, default=0.0)
    transportation = Column(Float, default=0.0)
    entertainment = Column(Float, default=0.0)
    healthcare = Column(Float, default=0.0)
    other_expenses = Column(Float, default=0.0)
    
    # Asset fields
    savings_account = Column(Float, default=0.0)
    checking_account = Column(Float, default=0.0)
    investments = Column(Float, default=0.0)
    property_value = Column(Float, default=0.0)
    vehicle_value = Column(Float, default=0.0)
    other_assets = Column(Float, default=0.0)
    
    # Liability fields
    credit_card_debt = Column(Float, default=0.0)
    student_loans = Column(Float, default=0.0)
    mortgage = Column(Float, default=0.0)
    car_loan = Column(Float, default=0.0)
    other_debts = Column(Float, default=0.0)
    
    # Financial planning fields
    financial_goals = Column(Text, default="")
    risk_tolerance = Column(String(20), default="Moderate")  # Low, Moderate, High
    
    # Timestamps
    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))
    updated_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc))
    
    # Relationship
    client = relationship("User", foreign_keys=[client_id])