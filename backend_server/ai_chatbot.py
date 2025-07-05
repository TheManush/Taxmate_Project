import json
from financial_crud import calculate_financial_summary

class FinancialAIChatbot:
    def __init__(self):
        self.context_responses = {
            "greeting": [
                "Hello! I'm your personal financial advisor AI. How can I help you with your finances today?",
                "Hi there! I'm here to help you understand and improve your financial situation. What would you like to know?",
                "Welcome! I can help you analyze your financial data and provide personalized advice. What's on your mind?"
            ],
            "net_worth": [
                "Your net worth is calculated by subtracting your total liabilities from your total assets.",
                "Net worth represents your overall financial position - it's what you own minus what you owe.",
                "A positive net worth means your assets exceed your debts, which is a good financial sign."
            ],
            "savings": [
                "Building an emergency fund should be your first priority - aim for 3-6 months of expenses.",
                "Consider automating your savings to make it easier to build wealth consistently.",
                "The 50/30/20 rule suggests allocating 20% of your income to savings and debt repayment."
            ],
            "debt": [
                "Focus on paying off high-interest debt first, like credit cards.",
                "Consider the debt avalanche method: pay minimums on all debts, then extra on the highest interest rate.",
                "Debt consolidation might help if you have multiple high-interest debts."
            ],
            "investment": [
                "Start with low-cost index funds if you're new to investing.",
                "Diversification is key - don't put all your money in one investment.",
                "Consider your risk tolerance and time horizon when choosing investments."
            ]
        }
    
    def generate_response(self, message: str, financial_data=None):
        message_lower = message.lower()
        
        # Greeting responses
        if any(word in message_lower for word in ["hello", "hi", "hey", "good morning", "good afternoon"]):
            return self._get_greeting_response()
        
        # Financial summary requests
        if any(word in message_lower for word in ["summary", "overview", "status", "situation"]):
            return self._get_financial_summary_response(financial_data)
        
        # Net worth questions
        if any(word in message_lower for word in ["net worth", "wealth", "total value"]):
            return self._get_net_worth_response(financial_data)
        
        # Savings advice
        if any(word in message_lower for word in ["save", "saving", "emergency fund", "savings"]):
            return self._get_savings_advice(financial_data)
        
        # Debt advice
        if any(word in message_lower for word in ["debt", "loan", "credit card", "mortgage", "owe"]):
            return self._get_debt_advice(financial_data)
        
        # Investment advice
        if any(word in message_lower for word in ["invest", "investment", "stocks", "portfolio", "retirement"]):
            return self._get_investment_advice(financial_data)
        
        # Budget advice
        if any(word in message_lower for word in ["budget", "expense", "spending", "money management"]):
            return self._get_budget_advice(financial_data)
        
        # Default response
        return self._get_default_response()
    
    def _get_greeting_response(self):
        return "Hello! I'm your personal financial advisor AI. I can help you understand your financial situation, provide budgeting advice, and suggest ways to improve your financial health. What would you like to know about your finances?"
    
    def _get_financial_summary_response(self, financial_data):
        if not financial_data:
            return "I don't have your financial data yet. Please upload your financial information first so I can provide a personalized summary."
        
        summary = calculate_financial_summary(financial_data)
        
        response = f"""Here's your financial summary:
        
💰 **Net Worth**: ${summary['net_worth']:,.2f}
📈 **Total Assets**: ${summary['total_assets']:,.2f}
📉 **Total Liabilities**: ${summary['total_liabilities']:,.2f}
💵 **Annual Income**: ${summary['total_income']:,.2f}
💸 **Annual Expenses**: ${summary['total_expenses']:,.2f}
💡 **Monthly Surplus**: ${summary['monthly_surplus']:,.2f}
📊 **Savings Rate**: {summary['savings_rate']:.1f}%
⚖️ **Debt-to-Income Ratio**: {summary['debt_to_income_ratio']:.1f}%

"""
        
        if summary['net_worth'] > 0:
            response += "Great job! You have a positive net worth. "
        else:
            response += "Your net worth is negative, but don't worry - we can work on improving it. "
        
        if summary['savings_rate'] > 20:
            response += "Your savings rate is excellent!"
        elif summary['savings_rate'] > 10:
            response += "Your savings rate is good, but there's room for improvement."
        else:
            response += "Consider increasing your savings rate to build wealth faster."
        
        return response
    
    def _get_net_worth_response(self, financial_data):
        if not financial_data:
            return "I need your financial data to calculate your net worth. Please upload your financial information first."
        
        summary = calculate_financial_summary(financial_data)
        net_worth = summary['net_worth']
        
        response = f"Your current net worth is ${net_worth:,.2f}. "
        
        if net_worth > 100000:
            response += "Excellent! You're building substantial wealth."
        elif net_worth > 50000:
            response += "You're doing well! Keep building your assets."
        elif net_worth > 0:
            response += "You're on the right track with a positive net worth."
        else:
            response += "Focus on reducing debt and building assets to improve your net worth."
        
        return response
    
    def _get_savings_advice(self, financial_data):
        if not financial_data:
            return "Upload your financial data so I can provide personalized savings advice based on your income and expenses."
        
        summary = calculate_financial_summary(financial_data)
        
        response = "Here's my savings advice for you:\n\n"
        
        if summary['monthly_surplus'] > 0:
            response += f"Great! You have a monthly surplus of ${summary['monthly_surplus']:,.2f}. "
            response += "Consider automating this amount into a high-yield savings account.\n\n"
        else:
            response += "You're spending more than you earn. Let's work on reducing expenses first.\n\n"
        
        emergency_fund_needed = summary['total_expenses'] / 2  # 6 months of expenses
        current_liquid_assets = financial_data.savings_account + financial_data.checking_account
        
        if current_liquid_assets < emergency_fund_needed:
            response += f"Priority: Build an emergency fund of ${emergency_fund_needed:,.2f} (6 months of expenses). "
            response += f"You currently have ${current_liquid_assets:,.2f} in liquid savings."
        else:
            response += "Great! You have a solid emergency fund. Consider investing additional savings for long-term growth."
        
        return response
    
    def _get_debt_advice(self, financial_data):
        if not financial_data:
            return "Share your debt information so I can provide personalized debt management strategies."
        
        total_debt = (financial_data.credit_card_debt + financial_data.student_loans + 
                     financial_data.mortgage + financial_data.car_loan + financial_data.other_debts)
        
        if total_debt == 0:
            return "Congratulations! You're debt-free. Focus on building wealth through savings and investments."
        
        summary = calculate_financial_summary(financial_data)
        
        response = f"You have ${total_debt:,.2f} in total debt. "
        
        if summary['debt_to_income_ratio'] > 40:
            response += "Your debt-to-income ratio is high. Focus on aggressive debt repayment.\n\n"
        elif summary['debt_to_income_ratio'] > 20:
            response += "Your debt level is manageable but could be improved.\n\n"
        else:
            response += "Your debt level is reasonable.\n\n"
        
        # Prioritize high-interest debt
        if financial_data.credit_card_debt > 0:
            response += f"Priority: Pay off your credit card debt (${financial_data.credit_card_debt:,.2f}) first - it likely has the highest interest rate.\n"
        
        response += "Consider the debt avalanche method: pay minimums on all debts, then put extra money toward the highest interest rate debt."
        
        return response
    
    def _get_investment_advice(self, financial_data):
        if not financial_data:
            return "I need to understand your financial situation before providing investment advice. Please upload your financial data."
        
        summary = calculate_financial_summary(financial_data)
        emergency_fund_needed = summary['total_expenses'] / 2
        current_liquid_assets = financial_data.savings_account + financial_data.checking_account
        
        response = "Here's my investment advice:\n\n"
        
        if current_liquid_assets < emergency_fund_needed:
            response += "Before investing, build an emergency fund of 6 months of expenses. This should be your first priority.\n\n"
        
        if financial_data.credit_card_debt > 0:
            response += "Pay off high-interest credit card debt before investing - the guaranteed 'return' of debt elimination often beats market returns.\n\n"
        
        if summary['monthly_surplus'] > 0:
            response += f"With your monthly surplus of ${summary['monthly_surplus']:,.2f}, you could invest regularly. "
        
        # Risk tolerance advice
        risk_tolerance = financial_data.risk_tolerance.lower()
        if risk_tolerance == "conservative":
            response += "Given your conservative risk tolerance, consider bonds, CDs, and stable value funds."
        elif risk_tolerance == "aggressive":
            response += "With your aggressive risk tolerance, you might consider growth stocks and emerging market funds."
        else:
            response += "With moderate risk tolerance, a balanced portfolio of stocks and bonds (like 70/30) could work well."
        
        return response
    
    def _get_budget_advice(self, financial_data):
        if not financial_data:
            return "Upload your expense data so I can analyze your spending patterns and provide budgeting advice."
        
        summary = calculate_financial_summary(financial_data)
        monthly_income = financial_data.monthly_salary
        total_monthly_expenses = summary['total_expenses'] / 12
        
        response = "Here's your budget analysis:\n\n"
        
        if summary['monthly_surplus'] < 0:
            response += "⚠️ You're spending more than you earn. Here are the areas to focus on:\n\n"
        
        # Analyze expense categories
        expenses = {
            "Housing": financial_data.monthly_rent,
            "Food": financial_data.food_expenses,
            "Transportation": financial_data.transportation,
            "Entertainment": financial_data.entertainment,
            "Utilities": financial_data.utilities,
            "Healthcare": financial_data.healthcare,
            "Other": financial_data.other_expenses
        }
        
        for category, amount in expenses.items():
            if amount > 0:
                percentage = (amount / monthly_income) * 100 if monthly_income > 0 else 0
                response += f"• {category}: ${amount:,.2f} ({percentage:.1f}% of income)\n"
        
        response += f"\n💡 **Recommendations:**\n"
        
        # Housing advice
        housing_percentage = (financial_data.monthly_rent / monthly_income) * 100 if monthly_income > 0 else 0
        if housing_percentage > 30:
            response += f"• Your housing costs ({housing_percentage:.1f}%) exceed the recommended 30% of income. Consider downsizing or finding a roommate.\n"
        
        # Food advice
        food_percentage = (financial_data.food_expenses / monthly_income) * 100 if monthly_income > 0 else 0
        if food_percentage > 15:
            response += f"• Your food expenses ({food_percentage:.1f}%) are high. Try meal planning and cooking at home more often.\n"
        
        return response
    
    def _get_default_response(self):
        return """I can help you with various financial topics:

💰 Ask about your financial summary or net worth
💡 Get savings and budgeting advice  
📊 Learn about investment strategies
💳 Receive debt management tips
📈 Understand your financial ratios

What specific area would you like to explore?"""

# Initialize the chatbot
financial_chatbot = FinancialAIChatbot()