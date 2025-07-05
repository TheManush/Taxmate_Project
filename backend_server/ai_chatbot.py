import openai
import json
import os
from dotenv import load_dotenv
from financial_crud import calculate_financial_summary

# Load environment variables
load_dotenv()

class FinancialAIChatbot:
    def __init__(self):
        # Initialize OpenAI client
        openai.api_key = os.getenv('OPENAI_API_KEY')
        if not openai.api_key:
            raise ValueError("OpenAI API key not found. Please set OPENAI_API_KEY in your .env file")
        
        self.system_prompt = """You are a professional financial advisor AI assistant. Your role is to provide helpful, accurate, and personalized financial advice based on the user's financial data.

Key guidelines:
1. Always be supportive and encouraging
2. Provide specific, actionable advice
3. Use the user's actual financial data when available
4. Explain financial concepts in simple terms
5. Suggest concrete steps for improvement
6. Be honest about limitations and recommend professional help when needed
7. Focus on practical, achievable goals
8. Use emojis sparingly but appropriately to make responses engaging

When financial data is provided, analyze it thoroughly and give personalized recommendations. When no data is available, provide general financial guidance and encourage the user to share their financial information for personalized advice."""

    async def generate_response(self, message: str, financial_data=None):
        try:
            # Prepare the context with financial data if available
            context = self._prepare_financial_context(financial_data)
            
            # Create the conversation messages
            messages = [
                {"role": "system", "content": self.system_prompt},
                {"role": "user", "content": f"{context}\n\nUser question: {message}"}
            ]
            
            # Call OpenAI API
            response = await openai.ChatCompletion.acreate(
                model="gpt-3.5-turbo",
                messages=messages,
                max_tokens=500,
                temperature=0.7,
                presence_penalty=0.1,
                frequency_penalty=0.1
            )
            
            return response.choices[0].message.content.strip()
            
        except Exception as e:
            print(f"OpenAI API Error: {e}")
            return self._get_fallback_response(message, financial_data)
    
    def _prepare_financial_context(self, financial_data):
        if not financial_data:
            return "The user has not provided their financial data yet. Encourage them to share their financial information for personalized advice."
        
        # Calculate financial summary
        summary = calculate_financial_summary(financial_data)
        
        context = f"""
User's Financial Profile:
- Net Worth: ${summary['net_worth']:,.2f}
- Annual Income: ${summary['total_income']:,.2f}
- Annual Expenses: ${summary['total_expenses']:,.2f}
- Monthly Surplus/Deficit: ${summary['monthly_surplus']:,.2f}
- Total Assets: ${summary['total_assets']:,.2f}
- Total Liabilities: ${summary['total_liabilities']:,.2f}
- Debt-to-Income Ratio: {summary['debt_to_income_ratio']:.1f}%
- Savings Rate: {summary['savings_rate']:.1f}%

Detailed Breakdown:
Income:
- Monthly Salary: ${financial_data.monthly_salary:,.2f}
- Annual Bonus: ${financial_data.annual_bonus:,.2f}
- Other Income: ${financial_data.other_income:,.2f}

Monthly Expenses:
- Housing: ${financial_data.monthly_rent:,.2f}
- Utilities: ${financial_data.utilities:,.2f}
- Food: ${financial_data.food_expenses:,.2f}
- Transportation: ${financial_data.transportation:,.2f}
- Entertainment: ${financial_data.entertainment:,.2f}
- Healthcare: ${financial_data.healthcare:,.2f}
- Other: ${financial_data.other_expenses:,.2f}

Assets:
- Savings Account: ${financial_data.savings_account:,.2f}
- Checking Account: ${financial_data.checking_account:,.2f}
- Investments: ${financial_data.investments:,.2f}
- Property Value: ${financial_data.property_value:,.2f}
- Vehicle Value: ${financial_data.vehicle_value:,.2f}
- Other Assets: ${financial_data.other_assets:,.2f}

Liabilities:
- Credit Card Debt: ${financial_data.credit_card_debt:,.2f}
- Student Loans: ${financial_data.student_loans:,.2f}
- Mortgage: ${financial_data.mortgage:,.2f}
- Car Loan: ${financial_data.car_loan:,.2f}
- Other Debts: ${financial_data.other_debts:,.2f}

Financial Goals: {financial_data.financial_goals or 'Not specified'}
Risk Tolerance: {financial_data.risk_tolerance}

Please provide personalized financial advice based on this data.
"""
        return context
    
    def _get_fallback_response(self, message: str, financial_data=None):
        """Fallback response when OpenAI API is unavailable"""
        message_lower = message.lower()
        
        # Greeting responses
        if any(word in message_lower for word in ["hello", "hi", "hey", "good morning", "good afternoon"]):
            return "Hello! I'm your AI financial advisor. I can help you understand your financial situation and provide personalized advice. What would you like to know about your finances?"
        
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
        return """I can help you with various financial topics:

💰 Financial summary and net worth analysis
💡 Savings strategies and emergency fund planning
📊 Investment advice based on your risk tolerance
💳 Debt management and payoff strategies
📈 Budget optimization and expense tracking
🎯 Financial goal setting and planning

What specific area would you like to explore? For the most personalized advice, please make sure your financial data is up to date."""
    
    def _get_financial_summary_response(self, financial_data):
        if not financial_data:
            return "I don't have your financial data yet. Please upload your financial information first so I can provide a personalized summary and analysis."
        
        summary = calculate_financial_summary(financial_data)
        
        response = f"""Here's your comprehensive financial summary:

💰 **Net Worth**: ${summary['net_worth']:,.2f}
📈 **Total Assets**: ${summary['total_assets']:,.2f}
📉 **Total Liabilities**: ${summary['total_liabilities']:,.2f}
💵 **Annual Income**: ${summary['total_income']:,.2f}
💸 **Annual Expenses**: ${summary['total_expenses']:,.2f}
💡 **Monthly Surplus**: ${summary['monthly_surplus']:,.2f}
📊 **Savings Rate**: {summary['savings_rate']:.1f}%
⚖️ **Debt-to-Income Ratio**: {summary['debt_to_income_ratio']:.1f}%

**Analysis:**
"""
        
        if summary['net_worth'] > 0:
            response += "✅ Positive net worth - you're building wealth! "
        else:
            response += "⚠️ Negative net worth - focus on debt reduction and asset building. "
        
        if summary['savings_rate'] > 20:
            response += "🌟 Excellent savings rate!"
        elif summary['savings_rate'] > 10:
            response += "👍 Good savings rate, room for improvement."
        else:
            response += "📈 Consider increasing your savings rate."
        
        return response
    
    def _get_net_worth_response(self, financial_data):
        if not financial_data:
            return "I need your financial data to calculate your net worth. Please upload your financial information first, then I can provide detailed analysis and recommendations."
        
        summary = calculate_financial_summary(financial_data)
        net_worth = summary['net_worth']
        
        response = f"Your current net worth is **${net_worth:,.2f}**. "
        
        if net_worth > 100000:
            response += "🎉 Excellent! You're building substantial wealth. Consider diversifying your investments and exploring tax-advantaged accounts."
        elif net_worth > 50000:
            response += "👏 You're doing well! Focus on consistent investing and consider increasing your emergency fund."
        elif net_worth > 0:
            response += "✅ Great job maintaining a positive net worth! Focus on increasing assets and minimizing high-interest debt."
        else:
            response += "💪 Let's work on improving this! Focus on paying down high-interest debt and building an emergency fund."
        
        return response
    
    def _get_savings_advice(self, financial_data):
        if not financial_data:
            return "Upload your financial data so I can provide personalized savings advice based on your income, expenses, and financial goals."
        
        summary = calculate_financial_summary(financial_data)
        
        response = "**Personalized Savings Strategy:**\n\n"
        
        if summary['monthly_surplus'] > 0:
            response += f"💰 Great! You have a monthly surplus of ${summary['monthly_surplus']:,.2f}. Here's how to optimize it:\n\n"
            response += "1. **Automate savings** - Set up automatic transfers to a high-yield savings account\n"
            response += "2. **Follow the 50/30/20 rule** - 50% needs, 30% wants, 20% savings/debt repayment\n"
        else:
            response += "⚠️ You're spending more than you earn. Priority actions:\n\n"
            response += "1. **Track expenses** for 30 days to identify spending patterns\n"
            response += "2. **Cut non-essential expenses** temporarily\n"
            response += "3. **Consider increasing income** through side hustles or skill development\n\n"
        
        emergency_fund_needed = summary['total_expenses'] / 2  # 6 months of expenses
        current_liquid_assets = financial_data.savings_account + financial_data.checking_account
        
        if current_liquid_assets < emergency_fund_needed:
            response += f"🚨 **Emergency Fund Priority**: You need ${emergency_fund_needed:,.2f} (6 months expenses). "
            response += f"Current liquid savings: ${current_liquid_assets:,.2f}\n"
            response += f"**Gap to fill**: ${emergency_fund_needed - current_liquid_assets:,.2f}"
        else:
            response += "✅ **Emergency fund is solid!** Consider investing additional savings for long-term growth."
        
        return response
    
    def _get_debt_advice(self, financial_data):
        if not financial_data:
            return "Share your debt information so I can create a personalized debt elimination strategy tailored to your situation."
        
        total_debt = (financial_data.credit_card_debt + financial_data.student_loans + 
                     financial_data.mortgage + financial_data.car_loan + financial_data.other_debts)
        
        if total_debt == 0:
            return "🎉 Congratulations! You're debt-free! Focus on building wealth through:\n• Maximizing retirement contributions\n• Building investment portfolio\n• Considering real estate investments"
        
        summary = calculate_financial_summary(financial_data)
        
        response = f"**Debt Management Strategy** (Total debt: ${total_debt:,.2f})\n\n"
        
        if summary['debt_to_income_ratio'] > 40:
            response += "🚨 **High debt ratio** - Aggressive action needed:\n"
        elif summary['debt_to_income_ratio'] > 20:
            response += "⚠️ **Moderate debt level** - Manageable with focused effort:\n"
        else:
            response += "✅ **Reasonable debt level** - Stay on track:\n"
        
        response += "\n**Recommended Strategy:**\n"
        
        # Prioritize high-interest debt
        if financial_data.credit_card_debt > 0:
            response += f"1. **Priority**: Pay off credit card debt (${financial_data.credit_card_debt:,.2f}) - likely highest interest\n"
        
        response += "2. **Debt Avalanche Method**: Pay minimums on all debts, extra payments to highest interest rate\n"
        response += "3. **Consider debt consolidation** if you have multiple high-interest debts\n"
        response += "4. **Negotiate with creditors** for better terms if struggling\n"
        
        if summary['monthly_surplus'] > 0:
            response += f"\n💡 **With your ${summary['monthly_surplus']:,.2f} monthly surplus, you could eliminate debt faster!**"
        
        return response
    
    def _get_investment_advice(self, financial_data):
        if not financial_data:
            return "I need to understand your complete financial picture before providing investment advice. Please upload your financial data for personalized recommendations."
        
        summary = calculate_financial_summary(financial_data)
        emergency_fund_needed = summary['total_expenses'] / 2
        current_liquid_assets = financial_data.savings_account + financial_data.checking_account
        
        response = "**Investment Strategy Recommendations:**\n\n"
        
        # Check prerequisites
        if current_liquid_assets < emergency_fund_needed:
            response += "⚠️ **First Priority**: Build emergency fund before investing\n"
            response += f"Need: ${emergency_fund_needed:,.2f} | Have: ${current_liquid_assets:,.2f}\n\n"
        
        if financial_data.credit_card_debt > 0:
            response += "⚠️ **Pay off credit card debt first** - guaranteed 'return' often beats market returns\n\n"
        
        if summary['monthly_surplus'] > 0:
            response += f"💰 **Available for investing**: ${summary['monthly_surplus']:,.2f}/month\n\n"
        
        # Risk-based recommendations
        risk_tolerance = financial_data.risk_tolerance.lower()
        response += "**Portfolio Recommendations:**\n"
        
        if risk_tolerance == "conservative":
            response += "🛡️ **Conservative approach**:\n"
            response += "• 60% Bonds/Fixed Income\n• 30% Large-cap stocks\n• 10% International bonds\n"
            response += "• Consider CDs and high-yield savings for short-term goals"
        elif risk_tolerance == "aggressive":
            response += "🚀 **Aggressive growth**:\n"
            response += "• 80% Stocks (mix of large, mid, small-cap)\n• 15% International/Emerging markets\n• 5% Bonds\n"
            response += "• Consider growth stocks and sector ETFs"
        else:
            response += "⚖️ **Balanced approach**:\n"
            response += "• 70% Stocks (diversified)\n• 25% Bonds\n• 5% REITs/Alternatives\n"
            response += "• Target-date funds are excellent for beginners"
        
        response += "\n**Action Steps:**\n"
        response += "1. **Maximize employer 401(k) match** (free money!)\n"
        response += "2. **Open Roth IRA** for tax-free growth\n"
        response += "3. **Start with low-cost index funds**\n"
        response += "4. **Automate investments** for consistency"
        
        return response
    
    def _get_budget_advice(self, financial_data):
        if not financial_data:
            return "Upload your expense data so I can analyze your spending patterns and provide targeted budgeting advice."
        
        summary = calculate_financial_summary(financial_data)
        monthly_income = financial_data.monthly_salary
        
        response = "**Budget Analysis & Recommendations:**\n\n"
        
        if summary['monthly_surplus'] < 0:
            response += "🚨 **Spending exceeds income** - Immediate action needed:\n\n"
        
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
        
        response += "**Expense Breakdown:**\n"
        for category, amount in expenses.items():
            if amount > 0:
                percentage = (amount / monthly_income) * 100 if monthly_income > 0 else 0
                response += f"• {category}: ${amount:,.2f} ({percentage:.1f}% of income)\n"
        
        response += "\n**Optimization Opportunities:**\n"
        
        # Housing advice
        housing_percentage = (financial_data.monthly_rent / monthly_income) * 100 if monthly_income > 0 else 0
        if housing_percentage > 30:
            response += f"🏠 **Housing** ({housing_percentage:.1f}%): Exceeds 30% rule. Consider downsizing or roommates\n"
        
        # Food advice
        food_percentage = (financial_data.food_expenses / monthly_income) * 100 if monthly_income > 0 else 0
        if food_percentage > 15:
            response += f"🍽️ **Food** ({food_percentage:.1f}%): High food costs. Try meal planning and cooking at home\n"
        
        # Entertainment advice
        entertainment_percentage = (financial_data.entertainment / monthly_income) * 100 if monthly_income > 0 else 0
        if entertainment_percentage > 10:
            response += f"🎬 **Entertainment** ({entertainment_percentage:.1f}%): Consider reducing discretionary spending\n"
        
        response += "\n**Budgeting Tips:**\n"
        response += "1. **Use the envelope method** for variable expenses\n"
        response += "2. **Track spending daily** for 30 days\n"
        response += "3. **Automate fixed expenses** to avoid late fees\n"
        response += "4. **Review and adjust monthly**"
        
        return response

# Initialize the chatbot
financial_chatbot = FinancialAIChatbot()