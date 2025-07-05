from pydantic import BaseModel
from typing import Optional
from datetime import datetime

class FinancialDataCreate(BaseModel):
    # Income
    monthly_salary: Optional[float] = 0.0
    annual_bonus: Optional[float] = 0.0
    other_income: Optional[float] = 0.0
    
    # Expenses
    monthly_rent: Optional[float] = 0.0
    utilities: Optional[float] = 0.0
    food_expenses: Optional[float] = 0.0
    transportation: Optional[float] = 0.0
    entertainment: Optional[float] = 0.0
    healthcare: Optional[float] = 0.0
    other_expenses: Optional[float] = 0.0
    
    # Assets
    savings_account: Optional[float] = 0.0
    checking_account: Optional[float] = 0.0
    investments: Optional[float] = 0.0
    property_value: Optional[float] = 0.0
    vehicle_value: Optional[float] = 0.0
    other_assets: Optional[float] = 0.0
    
    # Liabilities
    credit_card_debt: Optional[float] = 0.0
    student_loans: Optional[float] = 0.0
    mortgage: Optional[float] = 0.0
    car_loan: Optional[float] = 0.0
    other_debts: Optional[float] = 0.0
    
    # Goals
    financial_goals: Optional[str] = ""
    risk_tolerance: Optional[str] = "Moderate"

class FinancialDataOut(FinancialDataCreate):
    id: int
    client_id: int
    created_at: datetime
    updated_at: datetime
    
    class Config:
        from_attributes = True

class FinancialSummary(BaseModel):
    total_income: float
    total_expenses: float
    total_assets: float
    total_liabilities: float
    net_worth: float
    monthly_surplus: float
    debt_to_income_ratio: float
    savings_rate: float

class ChatMessageCreate(BaseModel):
    message: str

class ChatMessageOut(BaseModel):
    id: int
    client_id: int
    message: str
    response: str
    timestamp: datetime
    
    class Config:
        from_attributes = True