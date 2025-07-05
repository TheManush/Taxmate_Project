from sqlalchemy.orm import Session
from financial_models import FinancialData, ChatMessage
from financial_schemas import FinancialDataCreate, ChatMessageCreate
from datetime import datetime

def create_or_update_financial_data(db: Session, client_id: int, financial_data: FinancialDataCreate):
    # Check if financial data already exists for this client
    existing_data = db.query(FinancialData).filter(FinancialData.client_id == client_id).first()
    
    if existing_data:
        # Update existing data
        for field, value in financial_data.dict().items():
            setattr(existing_data, field, value)
        existing_data.updated_at = datetime.utcnow()
        db.commit()
        db.refresh(existing_data)
        return existing_data
    else:
        # Create new data
        db_financial_data = FinancialData(
            client_id=client_id,
            **financial_data.dict()
        )
        db.add(db_financial_data)
        db.commit()
        db.refresh(db_financial_data)
        return db_financial_data

def get_financial_data(db: Session, client_id: int):
    return db.query(FinancialData).filter(FinancialData.client_id == client_id).first()

def calculate_financial_summary(financial_data: FinancialData):
    if not financial_data:
        return None
    
    total_income = (financial_data.monthly_salary * 12) + financial_data.annual_bonus + financial_data.other_income
    total_monthly_expenses = (
        financial_data.monthly_rent + financial_data.utilities + 
        financial_data.food_expenses + financial_data.transportation + 
        financial_data.entertainment + financial_data.healthcare + 
        financial_data.other_expenses
    )
    total_expenses = total_monthly_expenses * 12
    
    total_assets = (
        financial_data.savings_account + financial_data.checking_account + 
        financial_data.investments + financial_data.property_value + 
        financial_data.vehicle_value + financial_data.other_assets
    )
    
    total_liabilities = (
        financial_data.credit_card_debt + financial_data.student_loans + 
        financial_data.mortgage + financial_data.car_loan + financial_data.other_debts
    )
    
    net_worth = total_assets - total_liabilities
    monthly_surplus = financial_data.monthly_salary - total_monthly_expenses
    debt_to_income_ratio = (total_liabilities / total_income * 100) if total_income > 0 else 0
    savings_rate = ((total_income - total_expenses) / total_income * 100) if total_income > 0 else 0
    
    return {
        "total_income": total_income,
        "total_expenses": total_expenses,
        "total_assets": total_assets,
        "total_liabilities": total_liabilities,
        "net_worth": net_worth,
        "monthly_surplus": monthly_surplus,
        "debt_to_income_ratio": debt_to_income_ratio,
        "savings_rate": savings_rate
    }

def create_chat_message(db: Session, client_id: int, message: str, response: str):
    db_message = ChatMessage(
        client_id=client_id,
        message=message,
        response=response
    )
    db.add(db_message)
    db.commit()
    db.refresh(db_message)
    return db_message

def get_chat_history(db: Session, client_id: int, limit: int = 50):
    return db.query(ChatMessage).filter(
        ChatMessage.client_id == client_id
    ).order_by(ChatMessage.timestamp.desc()).limit(limit).all()