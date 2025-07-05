from sqlalchemy import Column, Integer, String, Float, Date, Text, ForeignKey, DateTime
from sqlalchemy.orm import relationship
from database import Base
from datetime import datetime

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