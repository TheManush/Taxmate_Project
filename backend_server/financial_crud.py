from datetime import datetime
from typing import Optional, Dict, Any, List
from financial_schemas import RiskTolerance
from models import FinancialData, Message
from database import SessionLocal
from supabase_client import supabase


def create_or_update_financial_data(client_id: int, financial_data: Dict[str, Any]) -> Optional[Dict[str, Any]]:
    db = SessionLocal()
    try:
        # Clean and strictly validate risk_tolerance
        risk_tolerance = financial_data.get("risk_tolerance")
        if isinstance(risk_tolerance, list):
            risk_tolerance = risk_tolerance[-1]
        if isinstance(risk_tolerance, RiskTolerance):
            risk_tolerance = risk_tolerance.value
        if isinstance(risk_tolerance, str):
            risk_tolerance = risk_tolerance.strip().capitalize()
            allowed = [item.value for item in RiskTolerance]
            if risk_tolerance not in allowed:
                risk_tolerance = RiskTolerance.MODERATE.value
        else:
            risk_tolerance = RiskTolerance.MODERATE.value

        allowed_keys = {
            "monthly_salary", "annual_bonus", "other_income", "monthly_rent", "utilities", 
            "food_expenses", "transportation", "entertainment", "healthcare", "other_expenses", 
            "savings_account", "checking_account", "investments", "property_value", 
            "vehicle_value", "other_assets", "credit_card_debt", "student_loans", 
            "mortgage", "car_loan", "other_debts", "financial_goals", "risk_tolerance"
        }
        clean_data = {k: v for k, v in financial_data.items() if k in allowed_keys}
        clean_data["risk_tolerance"] = risk_tolerance

        # Try to get existing record
        instance = db.query(FinancialData).filter_by(client_id=client_id).first()
        if instance:
            for k, v in clean_data.items():
                setattr(instance, k, v)
            instance.updated_at = datetime.now()
            db.commit()
            db.refresh(instance)
            return instance.__dict__
        else:
            new_instance = FinancialData(client_id=client_id, **clean_data)
            db.add(new_instance)
            db.commit()
            db.refresh(new_instance)
            return new_instance.__dict__
    finally:
        db.close()

def get_financial_data(client_id: int) -> Optional[Dict[str, Any]]:
    db = SessionLocal()
    try:
        instance = db.query(FinancialData).filter_by(client_id=client_id).first()
        return instance.__dict__ if instance else None
    finally:
        db.close()

def calculate_financial_summary(financial_data: Dict[str, Any]) -> Dict[str, float]:
    if not financial_data:
        return None
    total_income = (financial_data.get("monthly_salary", 0) * 12 + financial_data.get("annual_bonus", 0) + financial_data.get("other_income", 0))
    total_monthly_expenses = (
        financial_data.get("monthly_rent", 0) + financial_data.get("utilities", 0) + 
        financial_data.get("food_expenses", 0) + financial_data.get("transportation", 0) + 
        financial_data.get("entertainment", 0) + financial_data.get("healthcare", 0) + 
        financial_data.get("other_expenses", 0)
    )
    total_expenses = total_monthly_expenses * 12
    total_assets = (
        financial_data.get("savings_account", 0) + financial_data.get("checking_account", 0) + 
        financial_data.get("investments", 0) + financial_data.get("property_value", 0) + 
        financial_data.get("vehicle_value", 0) + financial_data.get("other_assets", 0)
    )
    total_liabilities = (
        financial_data.get("credit_card_debt", 0) + financial_data.get("student_loans", 0) + 
        financial_data.get("mortgage", 0) + financial_data.get("car_loan", 0) + financial_data.get("other_debts", 0)
    )
    net_worth = total_assets - total_liabilities
    monthly_surplus = financial_data.get("monthly_salary", 0) - total_monthly_expenses
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

def create_chat_message(client_id: int, message: str, response: str) -> Optional[Dict[str, Any]]:
    db = SessionLocal()
    try:
        chat = Message(client_id=client_id, message=message, response=response)
        db.add(chat)
        db.commit()
        db.refresh(chat)
        return {
            "id": chat.id,
            "client_id": chat.client_id,
            "message": chat.message,
            "response": chat.response,
            "timestamp": chat.timestamp
        }
    finally:
        db.close()

def get_chat_history(client_id: int, limit: int = 50) -> List[Dict[str, Any]]:
    db = SessionLocal()
    try:
        messages = db.query(Message).filter_by(client_id=client_id).order_by(Message.timestamp.desc()).limit(limit).all()
        return [
            {
                "id": m.id,
                "client_id": m.client_id,
                "message": m.message,
                "response": m.response,
                "timestamp": m.timestamp
            }
            for m in messages
        ]
    finally:
        db.close()

def create_or_update_financial_data_supabase(client_id: int, financial_data: Dict[str, Any]) -> Optional[Dict[str, Any]]:
    # Clean and strictly validate risk_tolerance
    risk_tolerance = financial_data.get("risk_tolerance")
    if isinstance(risk_tolerance, list):
        risk_tolerance = risk_tolerance[-1]
    if isinstance(risk_tolerance, RiskTolerance):
        risk_tolerance = risk_tolerance.value
    if isinstance(risk_tolerance, str):
        risk_tolerance = risk_tolerance.strip().capitalize()
        allowed = [item.value for item in RiskTolerance]
        if risk_tolerance not in allowed:
            risk_tolerance = RiskTolerance.MODERATE.value
    else:
        risk_tolerance = RiskTolerance.MODERATE.value

    allowed_keys = {
        "monthly_salary", "annual_bonus", "other_income", "monthly_rent", "utilities", 
        "food_expenses", "transportation", "entertainment", "healthcare", "other_expenses", 
        "savings_account", "checking_account", "investments", "property_value", 
        "vehicle_value", "other_assets", "credit_card_debt", "student_loans", 
        "mortgage", "car_loan", "other_debts", "financial_goals", "risk_tolerance"
    }
    clean_data = {k: v for k, v in financial_data.items() if k in allowed_keys}
    clean_data["risk_tolerance"] = risk_tolerance
    clean_data["client_id"] = client_id
    clean_data["updated_at"] = datetime.utcnow().isoformat()

    # Upsert logic
    existing = supabase.table("financial_data").select("*").eq("client_id", client_id).execute()
    if existing.data:
        response = supabase.table("financial_data").update(clean_data).eq("client_id", client_id).execute()
        return response.data[0] if response.data else None
    else:
        clean_data["created_at"] = datetime.utcnow().isoformat()
        response = supabase.table("financial_data").insert(clean_data).execute()
        return response.data[0] if response.data else None

def get_financial_data_supabase(client_id: int) -> Optional[Dict[str, Any]]:
    response = supabase.table("financial_data").select("*").eq("client_id", client_id).execute()
    return response.data[0] if response.data else None

def create_chat_message_supabase(client_id: int, message: str, response: str) -> Optional[Dict[str, Any]]:
    chat = {
        "client_id": client_id,
        "message": message,
        "response": response,
        "timestamp": datetime.utcnow().isoformat()
    }
    result = supabase.table("chat_messages").insert(chat).execute()
    return result.data[0] if result.data else None

def get_chat_history_supabase(client_id: int, limit: int = 50) -> List[Dict[str, Any]]:
    response = supabase.table("chat_messages").select("*").eq("client_id", client_id).order("timestamp", desc=True).limit(limit).execute()
    return response.data if response.data else []
