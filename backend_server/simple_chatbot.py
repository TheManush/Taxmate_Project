
# --- Enhanced Financial Chatbot Implementation ---
import re
import random
import json
from typing import Dict, List, Optional, Any, Tuple
from datetime import datetime, timedelta
import numpy as np
import pandas as pd
# Note: Database functionality temporarily disabled for chatbot independence
# from financial_crud import get_financial_data_supabase, calculate_financial_summary
# from financial_schemas import RiskTolerance
get_financial_data_supabase = None
calculate_financial_summary = None
RiskTolerance = None

# Enhanced NLP and financial analysis capabilities
try:
    import spacy
    from spacy.matcher import PhraseMatcher
    from fuzzywuzzy import process
    import yfinance as yf
    from sklearn.feature_extraction.text import TfidfVectorizer
    from sklearn.metrics.pairwise import cosine_similarity
    import nltk
    from nltk.corpus import stopwords
    from nltk.stem import WordNetLemmatizer
    nltk.download(['stopwords', 'wordnet', 'punkt'])
except ImportError as e:
    print(f"Import error: {e}. Some features may be limited.")
    spacy = None
    process = None
    yf = None

# Financial knowledge base with hierarchical structure
FINANCIAL_KNOWLEDGE_GRAPH = {
    "investments": {
        "stocks": {
            "definition": "A stock represents ownership in a company and constitutes a claim on part of the company's assets and earnings.",
            "types": ["common stock", "preferred stock"],
            "risks": ["market risk", "liquidity risk", "concentration risk"],
            "strategies": ["value investing", "growth investing", "dividend investing"]
        },
        "bonds": {
            "definition": "A bond is a fixed income instrument representing a loan made by an investor to a borrower.",
            "types": ["government bonds", "corporate bonds", "municipal bonds"],
            "risks": ["interest rate risk", "credit risk", "inflation risk"],
            "strategies": ["laddering", "barbell strategy", "bullet strategy"]
        },
        "mutual_funds": {
            "definition": "A mutual fund is a pooled investment vehicle that collects money from many investors to invest in securities like stocks, bonds, and other assets.",
            "types": ["equity funds", "debt funds", "balanced funds", "index funds", "money market funds"],
            "risks": ["market risk", "credit risk", "liquidity risk", "interest rate risk"],
            "benefits": ["diversification", "professional management", "liquidity", "affordability"],
            "strategies": ["systematic investment plan (SIP)", "lump sum investment", "systematic withdrawal plan (SWP)"]
        },
        # ... (rest of the knowledge graph remains the same)
    }
}

# Expanded general finance Q&A
GENERAL_FINANCE_KB = {
    "what is a mutual fund": "A mutual fund is a pooled investment vehicle that collects money from many investors to invest in a diversified portfolio of securities like stocks, bonds, and other assets. It's managed by professional fund managers.",
    "what are mutual funds": "Mutual funds are pooled investment vehicles that collect money from many investors to invest in securities. They offer diversification, professional management, and liquidity.",
    "mutual fund": "A mutual fund pools money from multiple investors to invest in a diversified portfolio of securities. Professional fund managers make investment decisions on behalf of investors.",
    "what is sip": "SIP (Systematic Investment Plan) is a method of investing in mutual funds where you invest a fixed amount regularly, typically monthly. It helps with rupee cost averaging and disciplined investing.",
    "what is nav": "NAV (Net Asset Value) is the per-share value of a mutual fund, calculated by dividing the total value of all assets minus liabilities by the number of outstanding shares.",
    "what is expense ratio": "Expense ratio is the annual fee charged by mutual funds, expressed as a percentage of your investment. It covers fund management and operational costs.",
    "how to invest in mutual funds": "You can invest in mutual funds through SIP (regular investments) or lump sum. Choose funds based on your risk tolerance, investment horizon, and financial goals.",
    "types of mutual funds": "Main types include equity funds (stocks), debt funds (bonds), balanced/hybrid funds (mix), index funds (track market indices), and money market funds (short-term securities).",
    "mutual fund vs stocks": "Mutual funds offer instant diversification and professional management but charge fees. Stocks give you direct ownership and control but require more research and carry higher risk.",
    "benefits of mutual funds": "Key benefits include professional management, diversification, liquidity, affordability (small minimum investments), and various investment options to match different risk profiles."
}

class AdvancedFinancialChatbot:
    def __init__(self):
        self.greetings = [
            "Hello! I'm your advanced financial assistant. How can I help you today?",
            "Hi there! I'm ready to discuss any financial topic or analyze your personal finances.",
            "Welcome back! What financial questions or analysis can I help with today?"
        ]

        # Enhanced financial keywords with categories and descriptions
        self.financial_terms = {
            "Net Worth": "The total value of your assets minus liabilities. Calculated as: Assets - Liabilities.",
            "Debt-to-Income Ratio": "Your monthly debt payments divided by your gross monthly income.",
            "Savings Rate": "The percentage of your income that you're saving each month.",
            "Emergency Fund": "Savings to cover 3-6 months of living expenses for financial emergencies.",
            "Asset Allocation": "How your investments are distributed among different asset classes like stocks, bonds, and cash.",
            "Diversification": "Spreading investments across different assets to reduce risk.",
            "401(k)": "Employer-sponsored retirement account with tax advantages.",
            "IRA": "Individual Retirement Account with tax benefits.",
            "Roth Conversion": "Moving funds from a traditional IRA to a Roth IRA, with tax implications.",
            "Refinancing": "Replacing an existing loan with a new one, typically to get better terms.",
            "Amortization": "The process of paying off debt with regular payments over time.",
            "Tax Deductions": "Expenses that can be subtracted from your income to reduce taxable income.",
            "Life Insurance": "Policy that pays out to beneficiaries upon the policyholder's death.",
            "Mutual Fund": "A pooled investment vehicle that collects money from many investors to invest in a diversified portfolio of securities. Managed by professional fund managers.",
            "SIP": "Systematic Investment Plan - A method of investing in mutual funds where you invest a fixed amount regularly.",
            "NAV": "Net Asset Value - The per-share value of a mutual fund, calculated by dividing total assets minus liabilities by number of shares.",
            "Expense Ratio": "The annual fee charged by mutual funds, expressed as a percentage of your investment."
        }

        # Initialize NLP components
        self.nlp = spacy.load("en_core_web_sm") if spacy else None
        self.lemmatizer = WordNetLemmatizer()
        self.stop_words = set(stopwords.words('english'))

        # Initialize phrase matcher for financial terms
        if self.nlp:
            self.matcher = PhraseMatcher(self.nlp.vocab)
            patterns = [self.nlp(text) for text in self.financial_terms.keys()]
            self.matcher.add("FinancialTerms", patterns)

        # Initialize TF-IDF vectorizer for document similarity
        self.vectorizer = TfidfVectorizer(tokenizer=self._preprocess_text, stop_words=list(self.stop_words))
        kb_questions = list(GENERAL_FINANCE_KB.keys())
        # Only fit if there are questions, else use a default placeholder
        if kb_questions:
            self.vectorizer.fit(kb_questions)
        else:
            self.vectorizer.fit(["What is finance?"])

        # Response templates
        self.response_templates = {
            "greeting": lambda: random.choice(self.greetings),
            "no_data": "I can provide general financial information, but for personalized advice, please complete your financial profile.",
            "fallback": self._fallback_response,
            "summary": self._generate_summary_response,
            "market_data": self._generate_market_response,
            "calculation": self._generate_calculation_response,
            "definition": self._generate_definition_response,
            "comparison": self._generate_comparison_response,
            "strategy": self._generate_strategy_response,
            "term_list": self._generate_term_list_response,
            "term_definition": self._generate_term_definition_response
        }

        # User context tracking with historical data
        self.user_context = {}
        self.historical_data = {}  # Stores historical financial data by client_id

    def generate_response(self, message: str, client_id: Optional[int] = None) -> str:
        """Generate a response to the user's financial query."""
        message_lower = message.lower().strip()

        # Check for financial term explanation request
        term_response = self._handle_term_explanation_request(message)
        if term_response:
            return term_response
        # ...existing code...

    def _handle_term_explanation_request(self, message: str) -> Optional[str]:
        """Handle requests for financial term explanations."""
        if not self.nlp:
            return None

        doc = self.nlp(message.lower())

        # Check if user is asking about financial terms generally
        if any(word in message.lower() for word in ["what terms", "what financial terms", "list of terms", "what do you know"]):
            return self.response_templates["term_list"]()

        # Check for specific term matches
        matches = self.matcher(doc)
        if matches:
            matched_terms = []
            for match_id, start, end in matches:
                span = doc[start:end]
                matched_terms.append(span.text)

            if matched_terms:
                return self.response_templates["term_definition"](matched_terms[0])

        return None

    def _generate_term_list_response(self) -> str:
        """Generate a list of financial terms the chatbot knows."""
        term_list = "\n".join([f"- {term}" for term in self.financial_terms.keys()])
        return (f"I can explain these financial terms:\n{term_list}\n\n"
                "Ask me about any of these for more details!")

    def _generate_term_definition_response(self, term: str) -> str:
        """Generate a definition for a requested financial term."""
        definition = self.financial_terms.get(term)
        if definition:
            return f"{term}: {definition}"
        return f"I don't have a definition for '{term}'. Try asking about a different financial term."

    # Enhanced personalized financial advice methods
    def _try_personalized(self, message: str, financial_data: Dict[str, Any], summary: Dict[str, Any]) -> Optional[str]:
        """Enhanced personalized financial advice based on user data."""
        # Net worth analysis
        if "net worth" in message.lower():
            return self._handle_net_worth_questions(message, financial_data, summary)

        # Savings & Budgeting
        elif any(word in message.lower() for word in ["savings rate", "saving percentage"]):
            return self._handle_savings_rate_questions(financial_data, summary)

        # ... (other personalized question handlers)

        return None

    def _handle_net_worth_questions(self, message: str, financial_data: Dict[str, Any], summary: Dict[str, Any], client_id: Optional[int] = None) -> str:
        """Handle all net worth related questions."""
        nw = summary.get("net_worth")
        if nw is None:
            return "I don't have enough data to calculate your net worth."

        if "how has my net worth changed" in message.lower():
            return "I don't have historical data to compare your net worth changes over time."

        elif "am i financially healthy" in message.lower():
            return self._assess_financial_health(financial_data, nw)

        else:
            return f"Your current net worth is ${nw:,.2f}."

    def _calculate_net_worth_change(self, client_id: int, current_nw: float) -> str:
        """Calculate net worth change over the past year."""
        if client_id not in self.historical_data:
            return "I don't have historical data to compare your net worth."

        historical_nw = self.historical_data[client_id].get("net_worth")
        if not historical_nw:
            return "I don't have historical net worth data for comparison."

        change = current_nw - historical_nw
        change_pct = (change / historical_nw) * 100 if historical_nw != 0 else 0

        direction = "increased" if change >= 0 else "decreased"
        return (f"Your net worth has {direction} by ${abs(change):,.2f} "
                f"({abs(change_pct):.1f}%) over the past year.")

    def _assess_financial_health(self, financial_data: Dict[str, Any], net_worth: float) -> str:
        """Assess financial health based on net worth."""
        age = financial_data.get("age", 30)
        income = financial_data.get("annual_income", 0)

        if income <= 0:
            return "I need your income information to assess financial health."

        # Simple rule of thumb: net worth should be (age * income / 10)
        target_nw = age * income / 10
        difference = net_worth - target_nw

        if difference >= 0:
            return ("Your net worth is healthy! You're on track or ahead of typical benchmarks "
                   f"for your age and income (target: ${target_nw:,.2f}).")
        else:
            return (f"Your net worth is ${abs(difference):,.2f} below typical benchmarks "
                    f"for your age and income (target: ${target_nw:,.2f}). "
                    "Consider increasing savings and investments.")

    def _handle_savings_rate_questions(self, financial_data: Dict[str, Any], summary: Dict[str, Any]) -> str:
        """Handle savings rate related questions."""
        sr = summary.get("savings_rate")
        if sr is None:
            return "I can't calculate your savings rate without income and expense data."

        income = summary.get("annual_income", 0)
        if income <= 0:
            return "I need your income information to analyze savings."

        # 50/30/20 rule analysis
        needs = summary.get("essential_expenses", 0)
        wants = summary.get("discretionary_expenses", 0)
        savings = summary.get("savings", 0)

        response = [
            f"Your savings rate is {sr:.1f}% of your income.",
            "\nAccording to the 50/30/20 budgeting rule:",
            f"- Essentials (should be ~50%): {needs/income*100:.1f}%",
            f"- Discretionary (should be ~30%): {wants/income*100:.1f}%",
            f"- Savings (should be ~20%): {savings/income*100:.1f}%"
        ]

        if sr < 15:
            response.append("\nConsider increasing your savings rate to at least 15-20% of income.")
        elif sr >= 20:
            response.append("\nGreat job! You're meeting or exceeding recommended savings targets.")

        return "\n".join(response)

    # ... (other enhanced methods for the remaining question types)

    def update_historical_data(self, client_id: int, financial_data: Dict[str, Any]):
        """Update historical financial data for trend analysis."""
        if client_id not in self.historical_data:
            self.historical_data[client_id] = {}

        # Store current data with timestamp
        self.historical_data[client_id][datetime.now()] = {
            "net_worth": financial_data.get("net_worth"),
            "assets": financial_data.get("total_assets"),
            "liabilities": financial_data.get("total_liabilities"),
            "income": financial_data.get("annual_income")
        }

        # Keep only the last 2 years of data
        cutoff = datetime.now() - timedelta(days=730)
        self.historical_data[client_id] = {
            k: v for k, v in self.historical_data[client_id].items() 
            if isinstance(k, datetime) and k > cutoff
        }
    
    def generate_response(self, message: str, client_id: Optional[int] = None) -> str:
        """Generate a response to the user's financial query."""
        message_lower = message.lower().strip()
        
        # Track conversation context
        self._update_context(message_lower, client_id)
        
        # Check for greetings
        if any(greet in message_lower for greet in ["hello", "hi", "hey", "greetings"]):
            return self.response_templates["greeting"]()
            
        # Check for gratitude
        if any(thanks in message_lower for thanks in ["thanks", "thank you", "appreciate"]):
            return "You're welcome! Is there anything else I can help you with today?"
            
        # Check for farewell
        if any(bye in message_lower for bye in ["bye", "goodbye", "see you"]):
            return "Goodbye! Feel free to return if you have more financial questions."
        
        # Try to extract market data requests
        market_response = self._handle_market_data_requests(message_lower)
        if market_response:
            return market_response
            
        # Try to match calculation patterns
        calculation_response = self._handle_calculations(message_lower)
        if calculation_response:
            return calculation_response
            
        # Try to match definition requests
        definition_response = self._handle_definitions(message_lower)
        if definition_response:
            return definition_response
            
        # Try to match comparison requests
        comparison_response = self._handle_comparisons(message_lower)
        if comparison_response:
            return comparison_response
            
        # Try to match strategy requests
        strategy_response = self._handle_strategy_requests(message_lower)
        if strategy_response:
            return strategy_response
            
        # Try personalized advice if user has data
        if client_id and get_financial_data_supabase is not None:
            try:
                financial_data = get_financial_data_supabase(client_id)
                summary = calculate_financial_summary(financial_data) if financial_data else None
                
                if financial_data:
                    personalized = self._try_personalized(message_lower, financial_data, summary)
                    if personalized:
                        return personalized
                        
                    # If no specific personalized match, provide contextual summary
                    if "summary" in message_lower or "overview" in message_lower:
                        return self.response_templates["summary"](financial_data, summary)
            except Exception as e:
                print(f"Error accessing financial data: {e}")
                # Continue to general responses if database access fails
        
        # Enhanced knowledge base matching with semantic similarity
        kb_answer = self._query_knowledge_base(message_lower)
        if kb_answer:
            return kb_answer
            
        # Try to answer generally for any user
        general_answer = self._answer_general_finance_question(message_lower)
        if general_answer:
            if client_id:
                return general_answer + "\n\nFor personalized advice, please complete your financial profile."
            return general_answer
            
        # Ultimate fallback
        return self.response_templates["fallback"]()
    
    def _update_context(self, message: str, client_id: Optional[int]) -> None:
        """Update the conversation context based on the current message."""
        if client_id not in self.user_context:
            self.user_context[client_id] = {
                "last_topics": [],
                "financial_focus": None,
                "risk_profile": None
            }
        
        # Detect financial focus area
        focus_area = self._detect_financial_focus(message)
        if focus_area:
            self.user_context[client_id]["financial_focus"] = focus_area
            self.user_context[client_id]["last_topics"].append(focus_area)
            if len(self.user_context[client_id]["last_topics"]) > 5:
                self.user_context[client_id]["last_topics"].pop(0)
                
        # Detect risk-related language
        if "risk" in message:
            risk_level = self._detect_risk_language(message)
            if risk_level:
                self.user_context[client_id]["risk_profile"] = risk_level
    
    def _detect_financial_focus(self, message: str) -> Optional[str]:
        """Detect the main financial focus area of the message."""
        if not self.nlp:
            return None
            
        doc = self.nlp(message)
        matches = self.matcher(doc)
        
        if matches:
            match_id, start, end = matches[0]
            span = doc[start:end]
            for category, terms in self.finance_keywords.items():
                if span.text.lower() in terms:
                    return category
        return None
    
    def _detect_risk_language(self, message: str) -> Optional[str]:
        """Detect risk tolerance language in the message."""
        risk_keywords = {
            "conservative": ["safe", "conservative", "low risk", "preserve capital"],
            "moderate": ["balanced", "moderate", "some risk", "growth and income"],
            "aggressive": ["aggressive", "high risk", "maximum growth", "speculative"]
        }
        
        for level, keywords in risk_keywords.items():
            if any(keyword in message for keyword in keywords):
                return level
        return None
    
    def _handle_market_data_requests(self, message: str) -> Optional[str]:
        """Handle requests for market data and stock information."""
        # Pattern for stock price requests
        price_pattern = r"(?:what is|what's|show me|tell me) (?:the )?(?:price|value) of ([A-Z]{1,5})\??"
        price_match = re.search(price_pattern, message, re.IGNORECASE)
        if price_match:
            ticker = price_match.group(1).upper()
            return self.response_templates["market_data"](ticker, "price")
            
        # Pattern for stock performance requests
        perf_pattern = r"(?:how is|how's|what is|what's) (?:the )?performance of ([A-Z]{1,5})\??"
        perf_match = re.search(perf_pattern, message, re.IGNORECASE)
        if perf_match:
            ticker = perf_match.group(1).upper()
            return self.response_templates["market_data"](ticker, "performance")
            
        return None
    
    def _handle_calculations(self, message: str) -> Optional[str]:
        """Handle financial calculation requests."""
        # Future value calculation
        fv_pattern = r"(?:calculate|what is) (?:the )?future value of (\$?\d+(?:,\d+)*(?:\.\d+)?) at (\d+(?:\.\d+)?)% for (\d+) years?"
        fv_match = re.search(fv_pattern, message, re.IGNORECASE)
        if fv_match:
            amount = float(fv_match.group(1).replace('$', '').replace(',', ''))
            rate = float(fv_match.group(2)) / 100
            years = int(fv_match.group(3))
            return self.response_templates["calculation"]("future_value", amount, rate, years)
            
        # Present value calculation
        pv_pattern = r"(?:calculate|what is) (?:the )?present value of (\$?\d+(?:,\d+)*(?:\.\d+)?) at (\d+(?:\.\d+)?)% for (\d+) years?"
        pv_match = re.search(pv_pattern, message, re.IGNORECASE)
        if pv_match:
            amount = float(pv_match.group(1).replace('$', '').replace(',', ''))
            rate = float(pv_match.group(2)) / 100
            years = int(pv_match.group(3))
            return self.response_templates["calculation"]("present_value", amount, rate, years)
            
        return None
    
    def _handle_definitions(self, message: str) -> Optional[str]:
        """Handle requests for financial definitions."""
        def_pattern = r"(?:what is|what's|define) (?:a |an |the )?([a-zA-Z\s]+)\??"
        def_match = re.search(def_pattern, message, re.IGNORECASE)
        if def_match:
            term = def_match.group(1).strip()
            return self.response_templates["definition"](term)
            
        return None
    
    def _handle_comparisons(self, message: str) -> Optional[str]:
        """Handle requests to compare financial terms."""
        comp_pattern = r"(?:what is|what's) (?:the )?difference between (?:a |an |the )?([a-zA-Z\s]+) and (?:a |an |the )?([a-zA-Z\s]+)\??"
        comp_match = re.search(comp_pattern, message, re.IGNORECASE)
        if comp_match:
            term1 = comp_match.group(1).strip()
            term2 = comp_match.group(2).strip()
            return self.response_templates["comparison"](term1, term2)
            
        return None
    
    def _handle_strategy_requests(self, message: str) -> Optional[str]:
        """Handle requests for financial strategies."""
        strat_pattern = r"(?:what is|what's|recommend) (?:the )?best (?:strategy|approach|way) for ([a-zA-Z\s]+)\??"
        strat_match = re.search(strat_pattern, message, re.IGNORECASE)
        if strat_match:
            goal = strat_match.group(1).strip()
            return self.response_templates["strategy"](goal)
            
        return None
    
    def _try_personalized(self, message: str, financial_data: Dict[str, Any], 
                         summary: Dict[str, Any]) -> Optional[str]:
        """Enhanced personalized financial advice based on user data."""
        # Net worth analysis
        if "net worth" in message:
            nw = summary.get("net_worth")
            if nw is not None:
                context = ""
                if nw < 0:
                    context = " Focus on reducing debt and building positive net worth."
                elif nw < summary.get("annual_income", float('inf')):
                    context = " Consider increasing savings and investments to grow your net worth."
                else:
                    context = " You're doing well! Consider strategies to preserve and grow your wealth."
                return f"Your current net worth is ${nw:,.2f}.{context}"
        
        # Savings analysis
        if any(word in message for word in ["savings", "save", "saving rate"]):
            sr = summary.get("savings_rate")
            if sr is not None:
                context = ""
                if sr < 10:
                    context = " Financial experts typically recommend saving at least 15-20% of income."
                elif sr < 20:
                    context = " You're making good progress. Consider increasing to 20% for stronger financial security."
                else:
                    context = " Excellent savings rate! You're well on track for financial goals."
                return f"Your savings rate is {sr:.2f}%.{context}"
        
        # Debt analysis
        if any(word in message for word in ["debt", "loan", "credit card"]):
            total_debt = summary.get("total_debt")
            debt_to_income = summary.get("debt_to_income_ratio")
            if total_debt is not None and debt_to_income is not None:
                context = ""
                if debt_to_income > 0.4:
                    context = " Your debt level is high relative to income. Focus on debt reduction strategies."
                elif debt_to_income > 0.2:
                    context = " Consider paying down debt to improve financial flexibility."
                else:
                    context = " Your debt level is manageable. Maintain good repayment habits."
                return f"Your total debt is ${total_debt:,.2f} (DTI ratio: {debt_to_income:.2f}).{context}"
        
        # Retirement analysis
        if any(word in message for word in ["retire", "retirement"]):
            retirement_savings = summary.get("retirement_savings")
            age = financial_data.get("age")
            income = summary.get("total_income")
            
            if retirement_savings is not None and age is not None and income is not None:
                context = ""
                rule_of_thumb = age * income * 0.1  # Basic rule of thumb
                if retirement_savings < rule_of_thumb * 0.5:
                    context = " Consider increasing retirement contributions to catch up."
                elif retirement_savings < rule_of_thumb:
                    context = " You're making progress but may want to increase savings."
                else:
                    context = " You're on track! Continue regular contributions."
                return f"You have saved ${retirement_savings:,.2f} for retirement.{context}"
        
        # Income/expense analysis
        if any(word in message for word in ["income", "earn", "salary"]):
            income = summary.get("total_income")
            if income is not None:
                return f"Your total income is ${income:,.2f}."
        
        if any(word in message for word in ["expense", "spending", "budget"]):
            expense = summary.get("total_expense")
            if expense is not None:
                context = ""
                if "budget" in message:
                    return self._generate_budget_advice(financial_data, summary)
                return f"Your total expenses are ${expense:,.2f}."
        
        # Investment portfolio analysis
        if any(word in message for word in ["invest", "investment", "portfolio"]):
            return self._personalized_investment_advice(financial_data, summary)
        
        # Insurance needs analysis
        if "insurance" in message:
            return self._personalized_insurance_advice(financial_data, summary)
        
        # Tax planning advice
        if "tax" in message:
            return self._personalized_tax_advice(financial_data, summary)
        
        # Financial goal planning
        if any(word in message for word in ["goal", "plan", "target"]):
            return self._personalized_goal_advice(financial_data, summary)
        
        # College planning
        if any(word in message for word in ["college", "education", "tuition"]):
            return self._personalized_college_advice(financial_data, summary)
        
        # Home buying advice
        if any(word in message for word in ["house", "home", "mortgage", "buying property"]):
            return self._personalized_home_advice(financial_data, summary)
        
        return None
    
    def _query_knowledge_base(self, message: str) -> Optional[str]:
        """Enhanced knowledge base query with semantic similarity."""
        # Preprocess the message
        processed_message = self._preprocess_text(message)
        
        # Transform the message and KB questions to vectors
        try:
            message_vec = self.vectorizer.transform([processed_message])
            kb_questions = list(GENERAL_FINANCE_KB.keys())
            kb_vecs = self.vectorizer.transform(kb_questions)
            
            # Calculate cosine similarities
            similarities = cosine_similarity(message_vec, kb_vecs)
            best_match_idx = similarities.argmax()
            best_score = similarities[0, best_match_idx]
            
            # Threshold for considering a match
            if best_score > 0.6:
                best_question = kb_questions[best_match_idx]
                answer = GENERAL_FINANCE_KB[best_question]
                
                # Handle lambda functions in KB
                if callable(answer):
                    # Try to extract parameters from message
                    params = self._extract_parameters(best_question, message)
                    if params:
                        try:
                            return answer(*params)
                        except Exception as e:
                            print(f"Error executing KB function: {e}")
                            return None
                    return None
                return answer
        except Exception as e:
            print(f"Error in knowledge base query: {e}")
        
        return None
    
    def _extract_parameters(self, pattern: str, message: str) -> Optional[List[str]]:
        """Extract parameters from message based on a pattern with placeholders."""
        # Convert KB pattern to regex
        regex_pattern = re.escape(pattern)
        regex_pattern = regex_pattern.replace(r"\{", "(?P<").replace(r"\}", ">[^}]+)")
        regex_pattern = "^" + regex_pattern + "$"
        
        # Try to match
        match = re.search(regex_pattern, message, re.IGNORECASE)
        if match:
            return list(match.groups())
        return None
    
    def _answer_general_finance_question(self, message: str) -> Optional[str]:
        """Attempt to answer general finance questions using knowledge graph."""
        if not self.nlp:
            return None
            
        doc = self.nlp(message)
        
        # Check for definition questions
        if any(token.text.lower() in ["what", "define", "definition"] for token in doc):
            for ent in doc.ents:
                if ent.label_ in ["ORG", "PRODUCT"] or ent.text.lower() in self.finance_keywords:
                    definition = self.get_definition(ent.text)
                    if definition:
                        return definition
        
        # Check for comparison questions
        if "difference between" in message.lower():
            tokens = [token.text.lower() for token in doc]
            if "and" in tokens:
                and_idx = tokens.index("and")
                term1 = " ".join(tokens[tokens.index("between")+1:and_idx])
                term2 = " ".join(tokens[and_idx+1:])
                comparison = self.compare_terms(term1, term2)
                if comparison:
                    return comparison
        
        # Check for strategy questions
        if any(word in message.lower() for word in ["how to", "strategy", "approach", "best way"]):
            for token in doc:
                if token.text.lower() in FINANCIAL_KNOWLEDGE_GRAPH.get("investments", {}).get("strategies", []):
                    return self.suggest_strategy(token.text)
        
        return None
    
    def _preprocess_text(self, text: str) -> str:
        """Preprocess text for NLP tasks."""
        # Lowercase
        text = text.lower()
        
        # Remove punctuation
        text = re.sub(r'[^\w\s]', '', text)
        
        # Tokenize and lemmatize
        words = nltk.word_tokenize(text)
        words = [self.lemmatizer.lemmatize(word) for word in words if word not in self.stop_words]
        
        return " ".join(words)
    
    def _generate_summary_response(self, financial_data: Dict[str, Any], summary: Dict[str, Any]) -> str:
        """Generate a comprehensive financial summary."""
        if not summary:
            return self.response_templates["no_data"]
            
        response = [
            "Here's a detailed summary of your financial situation:",
            f"• Net Worth: ${summary.get('net_worth', 0):,.2f}",
            f"• Total Assets: ${summary.get('total_assets', 0):,.2f}",
            f"• Total Liabilities: ${summary.get('total_liabilities', 0):,.2f}",
            f"• Monthly Income: ${summary.get('monthly_income', 0):,.2f}",
            f"• Monthly Expenses: ${summary.get('monthly_expenses', 0):,.2f}",
            f"• Savings Rate: {summary.get('savings_rate', 0):.2f}%",
            f"• Debt-to-Income Ratio: {summary.get('debt_to_income_ratio', 0):.2f}",
            f"• Emergency Fund: {'Yes' if summary.get('has_emergency_fund', False) else 'No'}",
            "\nKey Recommendations:"
        ]
        
        # Add recommendations based on summary
        if summary.get('savings_rate', 0) < 15:
            response.append("- Consider increasing your savings rate to at least 15% of income")
            
        if summary.get('debt_to_income_ratio', 0) > 0.35:
            response.append("- Focus on reducing debt to improve financial flexibility")
            
        if not summary.get('has_retirement_account', False):
            response.append("- Open a retirement account (IRA or 401k) if available")
            
        if not summary.get('has_emergency_fund', False):
            response.append("- Build an emergency fund with 3-6 months of expenses")
            
        response.append("\nAsk me about specific areas for more detailed advice!")
        
        return "\n".join(response)
    
    def _generate_market_response(self, ticker: str, request_type: str) -> str:
        """Generate response for market data requests."""
        try:
            if request_type == "price":
                price = self.get_stock_price(ticker)
                if price:
                    return f"The current price of {ticker} is ${price:.2f}."
                return f"Sorry, I couldn't retrieve the price for {ticker}."
                
            elif request_type == "performance":
                perf = self.get_stock_performance(ticker)
                if perf:
                    return f"The performance of {ticker}: {perf}."
                return f"Sorry, I couldn't retrieve performance data for {ticker}."
                
        except Exception as e:
            print(f"Error getting market data: {e}")
            return "I encountered an error retrieving market data. Please try again later."
    
    def _generate_calculation_response(self, calc_type: str, *args) -> str:
        """Generate response for financial calculations."""
        try:
            if calc_type == "future_value":
                amount, rate, years = args
                fv = amount * (1 + rate) ** years
                return (f"The future value of ${amount:,.2f} at {rate*100:.2f}% annual growth "
                        f"after {years} years will be ${fv:,.2f}.")
                        
            elif calc_type == "present_value":
                amount, rate, years = args
                pv = amount / (1 + rate) ** years
                return (f"The present value of ${amount:,.2f} discounted at {rate*100:.2f}% "
                        f"for {years} years is ${pv:,.2f}.")
                        
        except Exception as e:
            print(f"Error in calculation: {e}")
            return "I couldn't complete that calculation. Please check your inputs."
    
    def _generate_definition_response(self, term: str) -> str:
        """Generate response for definition requests."""
        definition = self.get_definition(term)
        if definition:
            return f"{term.capitalize()}: {definition}"
        return f"I don't have a definition for '{term}'. Try asking about a different financial term."
    
    def _generate_comparison_response(self, term1: str, term2: str) -> str:
        """Generate response for comparison requests."""
        comparison = self.compare_terms(term1, term2)
        if comparison:
            return comparison
        return f"I can't compare {term1} and {term2}. Try asking about more common financial terms."
    
    def _generate_strategy_response(self, goal: str) -> str:
        """Generate response for strategy requests."""
        strategy = self.suggest_strategy(goal)
        if strategy:
            return strategy
        return f"I don't have specific strategies for '{goal}'. Try asking about common financial goals like retirement or debt reduction."
    
    def _generate_budget_advice(self, financial_data: Dict[str, Any], summary: Dict[str, Any]) -> str:
        """Generate personalized budget advice."""
        expenses = summary.get("monthly_expenses", 0)
        income = summary.get("monthly_income", 1)  # Avoid division by zero
        savings_rate = summary.get("savings_rate", 0)
        
        response = [f"Your monthly budget summary:\nIncome: ${income:,.2f}\nExpenses: ${expenses:,.2f}"]
        
        # Basic 50/30/20 rule analysis
        needs = expenses * 0.5
        wants = expenses * 0.3
        savings = expenses * 0.2
        
        if savings_rate < 20:
            response.append(f"\nYou're saving {savings_rate:.1f}% of income. The 50/30/20 rule suggests aiming for 20% savings.")
        
        # Expense category analysis
        if "expense_categories" in summary:
            largest_category = max(summary["expense_categories"].items(), key=lambda x: x[1])
            response.append(f"\nYour largest expense category is {largest_category[0]} (${largest_category[1]:,.2f}/month).")
            
            if largest_category[0].lower() in ["dining out", "entertainment", "shopping"]:
                response.append("Consider reducing discretionary spending in this category to increase savings.")
        
        return "\n".join(response)
    
    def _personalized_investment_advice(self, financial_data: Dict[str, Any], summary: Dict[str, Any]) -> str:
        """Generate personalized investment advice."""
        assets = financial_data.get("assets", [])
        age = financial_data.get("age", 30)
        risk_tolerance = financial_data.get("risk_tolerance", "moderate")
        
        response = ["Here's your personalized investment analysis:"]
        
        # Asset allocation analysis
        if assets and isinstance(assets, list):
            asset_types = {}
            total_value = sum(a.get("value", 0) for a in assets)
            
            for asset in assets:
                a_type = asset.get("type", "other").lower()
                asset_types[a_type] = asset_types.get(a_type, 0) + asset.get("value", 0)
            
            response.append("\nCurrent Asset Allocation:")
            for a_type, value in asset_types.items():
                response.append(f"- {a_type.capitalize()}: ${value:,.2f} ({value/total_value*100:.1f}%)")
            
            # Diversification check
            if len(asset_types) < 3:
                response.append("\nConsider diversifying across more asset classes to reduce risk.")
            
            # Stock concentration check
            if asset_types.get("stock", 0) / total_value > 0.7:
                response.append("\nYour portfolio is heavily weighted toward stocks. Consider adding bonds for balance.")
        
        # Age-appropriate advice
        years_to_retire = max(65 - age, 5)
        if years_to_retire > 30:
            response.append("\nWith many years until retirement, you can afford more growth-oriented investments.")
        elif years_to_retire < 10:
            response.append("\nAs you approach retirement, consider shifting to more conservative investments.")
        
        # Risk tolerance advice
        if risk_tolerance.lower() == "conservative":
            response.append("\nGiven your conservative risk tolerance, focus on bonds, CDs, and dividend stocks.")
        elif risk_tolerance.lower() == "aggressive":
            response.append("\nWith aggressive risk tolerance, you might consider growth stocks and alternative investments.")
        else:
            response.append("\nA balanced mix of stocks and bonds suits your moderate risk tolerance.")
        
        return "\n".join(response)
    
    def _personalized_insurance_advice(self, financial_data: Dict[str, Any], summary: Dict[str, Any]) -> str:
        """Generate personalized insurance advice."""
        insurance = financial_data.get("insurance", [])
        dependents = financial_data.get("dependents", 0)
        assets = summary.get("total_assets", 0)
        
        response = ["Here's your insurance needs analysis:"]
        
        # Life insurance check
        has_life = any(i.get("type", "").lower() == "life" for i in insurance)
        if not has_life and (dependents > 0 or assets > 500000):
            response.append("\nYou may need life insurance to protect your family's financial future.")
        elif has_life:
            response.append("\nYou have life insurance coverage. Review beneficiaries periodically.")
        
        # Health insurance check
        has_health = any(i.get("type", "").lower() == "health" for i in insurance)
        if not has_health:
            response.append("\nHealth insurance is essential to protect against medical expenses.")
        
        # Property insurance check
        has_home = any(i.get("type", "").lower() in ["home", "renters"] for i in insurance)
        if not has_home and assets > 100000:
            response.append("\nConsider property insurance to protect your home and belongings.")
        
        # Disability insurance check
        has_disability = any(i.get("type", "").lower() == "disability" for i in insurance)
        if not has_disability and summary.get("monthly_income", 0) > 3000:
            response.append("\nDisability insurance can protect your income if you're unable to work.")
        
        return "\n".join(response)
    
    def _personalized_tax_advice(self, financial_data: Dict[str, Any], summary: Dict[str, Any]) -> str:
        """Generate personalized tax advice."""
        accounts = financial_data.get("accounts", [])
        income = summary.get("total_income", 0)
        deductions = financial_data.get("deductions", [])
        
        response = ["Here's your tax planning analysis:"]
        
        # Retirement account check
        has_tax_advantaged = any(a.get("type", "").lower() in ["401k", "ira", "roth"] for a in accounts)
        if not has_tax_advantaged and income > 40000:
            response.append("\nConsider contributing to tax-advantaged retirement accounts to reduce taxable income.")
        elif has_tax_advantaged:
            response.append("\nYou're using tax-advantaged accounts. Maximize contributions for additional savings.")
        
        # Deduction check
        common_deductions = {"mortgage": False, "student_loan": False, "charitable": False}
        for d in deductions:
            if "mortgage" in d.get("type", "").lower():
                common_deductions["mortgage"] = True
            elif "student" in d.get("type", "").lower():
                common_deductions["student_loan"] = True
            elif "charit" in d.get("type", "").lower():
                common_deductions["charitable"] = True
        
        response.append("\nPotential Deductions:")
        for ded, has in common_deductions.items():
            response.append(f"- {ded.replace('_', ' ').title()}: {'Claimed' if has else 'Not claimed'}")
        
        # Tax bracket info
        if income > 0:
            bracket = self._estimate_tax_bracket(income)
            response.append(f"\nEstimated tax bracket: {bracket}%")
            if bracket >= 22:
                response.append("Consider tax-loss harvesting and other advanced strategies.")
        
        return "\n".join(response)
    
    def _estimate_tax_bracket(self, income: float) -> int:
        """Estimate federal tax bracket (simplified)."""
        if income <= 11000: return 10
        elif income <= 44725: return 12
        elif income <= 95375: return 22
        elif income <= 182100: return 24
        elif income <= 231250: return 32
        elif income <= 578125: return 35
        else: return 37
    
    def _personalized_goal_advice(self, financial_data: Dict[str, Any], summary: Dict[str, Any]) -> str:
        """Generate personalized advice for financial goals."""
        goals = financial_data.get("goals", [])
        net_worth = summary.get("net_worth", 0)
        savings_rate = summary.get("savings_rate", 0)
        
        if not goals:
            return ("You haven't set any financial goals yet. Common goals include: "
                   "retirement savings, buying a home, education funding, or debt freedom. "
                   "Let me know if you'd like help setting specific goals!")
        
        response = ["Your financial goals and progress:"]
        for goal in goals:
            g_name = goal.get("name", "Unnamed goal")
            g_amount = goal.get("target_amount", 0)
            g_saved = goal.get("saved_amount", 0)
            g_years = goal.get("years_remaining", 1)
            
            progress = min(g_saved / g_amount * 100, 100) if g_amount > 0 else 0
            needed_per_year = (g_amount - g_saved) / g_years if g_years > 0 else 0
            
            response.append(f"\n{g_name}: ${g_saved:,.2f} of ${g_amount:,.2f} ({progress:.1f}%)")
            response.append(f"To reach goal in {g_years} years, save ${needed_per_year:,.2f} annually")
            
            if needed_per_year > summary.get("annual_income", float('inf')) * 0.2:
                response.append("This goal may be too ambitious. Consider adjusting target or timeline.")
        
        return "\n".join(response)
    
    def _personalized_college_advice(self, financial_data: Dict[str, Any], summary: Dict[str, Any]) -> str:
        """Generate personalized college planning advice."""
        kids = financial_data.get("dependents", 0)
        college_funds = sum(a.get("value", 0) for a in financial_data.get("assets", []) 
                          if a.get("purpose", "").lower() == "education")
        
        response = ["College planning advice:"]
        
        if kids == 0:
            response.append("\nYou don't have any dependents listed. College planning may not be needed.")
        else:
            response.append(f"\nYou have {kids} dependent(s). Estimated college costs:")
            
            # Simplified cost projections
            current_cost = 25000  # Average public college annual cost
            years_until_college = max(18 - financial_data.get("oldest_child_age", 10), 1)
            inflation = 0.05
            future_cost = current_cost * (1 + inflation) ** years_until_college
            total_4yr_cost = future_cost * 4
            
            response.append(f"- Projected annual cost in {years_until_college} years: ${future_cost:,.2f}")
            response.append(f"- Total 4-year cost: ${total_4yr_cost:,.2f}")
            
            if college_funds > 0:
                response.append(f"\nYou've saved ${college_funds:,.2f} for education.")
                needed_per_year = (total_4yr_cost - college_funds) / years_until_college
                response.append(f"Save ${needed_per_year:,.2f} per year to fully fund education.")
            else:
                response.append("\nConsider starting a 529 plan or other education savings account.")
        
        return "\n".join(response)
    
    def _personalized_home_advice(self, financial_data: Dict[str, Any], summary: Dict[str, Any]) -> str:
        """Generate personalized home buying advice."""
        owns_home = any(a.get("type", "").lower() == "primary residence" for a in financial_data.get("assets", []))
        down_payment = financial_data.get("down_payment_saved", 0)
        income = summary.get("annual_income", 0)
        debt = summary.get("total_debt", 0)
        
        response = ["Home buying analysis:"]
        
        if owns_home:
            response.append("\nYou own a home. Consider these strategies:")
            mortgage = next((a for a in financial_data.get("liabilities", []) 
                           if a.get("type", "").lower() == "mortgage"), None)
            if mortgage:
                rate = mortgage.get("interest_rate", 0)
                balance = mortgage.get("balance", 0)
                response.append(f"- Mortgage balance: ${balance:,.2f} at {rate:.2f}%")
                if rate > 5:
                    response.append("Consider refinancing if rates have dropped since you got your mortgage.")
            else:
                response.append("- You own your home free and clear!")
            
            home_value = next((a.get("value", 0) for a in financial_data.get("assets", []) 
                             if a.get("type", "").lower() == "primary residence"), 0)
            response.append(f"- Estimated home value: ${home_value:,.2f}")
            
        else:
            response.append("\nYou don't currently own a home. Home buying considerations:")
            
            # Affordability estimate
            affordable_price = income * 3  # Simple rule of thumb
            needed_down = affordable_price * 0.2
            response.append(f"- Based on your income, you might afford a home up to ${affordable_price:,.2f}")
            response.append(f"- Recommended 20% down payment: ${needed_down:,.2f}")
            
            if down_payment > 0:
                response.append(f"- You've saved ${down_payment:,.2f} for a down payment")
                if down_payment >= needed_down:
                    response.append("You have enough saved for a 20% down payment!")
                else:
                    response.append(f"Save ${needed_down - down_payment:,.2f} more for 20% down")
            
            # Debt-to-income check
            dti = debt / income if income > 0 else 0
            if dti > 0.43:
                response.append("\nYour debt-to-income ratio is high for mortgage approval. Pay down debt first.")
            elif dti > 0.36:
                response.append("\nYour debt-to-income ratio is borderline. Consider reducing debt before buying.")
            else:
                response.append("\nYour debt-to-income ratio is good for mortgage approval.")
        
        return "\n".join(response)
    
    @staticmethod
    def get_stock_price(ticker: str) -> Optional[float]:
        """Get current stock price using yfinance."""
        try:
            stock = yf.Ticker(ticker)
            price = stock.history(period="1d")["Close"].iloc[-1]
            return price
        except Exception as e:
            print(f"Error getting stock price: {e}")
            return None
    
    @staticmethod
    def get_stock_performance(ticker: str) -> Optional[str]:
        """Get stock performance summary."""
        try:
            stock = yf.Ticker(ticker)
            hist = stock.history(period="1y")
            
            if hist.empty:
                return None
                
            start_price = hist["Close"].iloc[0]
            end_price = hist["Close"].iloc[-1]
            change_pct = (end_price - start_price) / start_price * 100
            
            high = hist["Close"].max()
            low = hist["Close"].min()
            vol = hist["Volume"].mean()
            
            return (f"1-year change: {change_pct:.2f}%, "
                    f"High: ${high:.2f}, Low: ${low:.2f}, "
                    f"Avg Volume: {vol:,.0f}")
        except Exception as e:
            print(f"Error getting stock performance: {e}")
            return None
    
    @staticmethod
    def calculate_future_value(present_value: float, rate: float, years: int) -> float:
        """Calculate future value of an investment."""
        return present_value * (1 + rate) ** years
    
    @staticmethod
    def get_definition(term: str) -> Optional[str]:
        """Get definition of a financial term from knowledge graph."""
        term_lower = term.lower().replace(" ", "_")
        
        # First, try to find in the financial terms dictionary (case-insensitive)
        # Check direct matches first
        for key, value in {
            "Net Worth": "The total value of your assets minus liabilities. Calculated as: Assets - Liabilities.",
            "Debt-to-Income Ratio": "Your monthly debt payments divided by your gross monthly income.",
            "Savings Rate": "The percentage of your income that you're saving each month.",
            "Emergency Fund": "Savings to cover 3-6 months of living expenses for financial emergencies.",
            "Asset Allocation": "How your investments are distributed among different asset classes like stocks, bonds, and cash.",
            "Diversification": "Spreading investments across different assets to reduce risk.",
            "401(k)": "Employer-sponsored retirement account with tax advantages.",
            "IRA": "Individual Retirement Account with tax benefits.",
            "Roth Conversion": "Moving funds from a traditional IRA to a Roth IRA, with tax implications.",
            "Refinancing": "Replacing an existing loan with a new one, typically to get better terms.",
            "Amortization": "The process of paying off debt with regular payments over time.",
            "Tax Deductions": "Expenses that can be subtracted from your income to reduce taxable income.",
            "Life Insurance": "Policy that pays out to beneficiaries upon the policyholder's death.",
            "Mutual Fund": "A pooled investment vehicle that collects money from many investors to invest in a diversified portfolio of securities. Managed by professional fund managers.",
            "SIP": "Systematic Investment Plan - A method of investing in mutual funds where you invest a fixed amount regularly.",
            "NAV": "Net Asset Value - The per-share value of a mutual fund, calculated by dividing total assets minus liabilities by number of shares.",
            "Expense Ratio": "The annual fee charged by mutual funds, expressed as a percentage of your investment."
        }.items():
            if key.lower() == term.lower():
                return value
        
        # Try knowledge base entries (case-insensitive)
        for kb_key, kb_value in GENERAL_FINANCE_KB.items():
            # Check if the term matches the key or is contained in the key
            if term.lower() in kb_key.lower() or kb_key.lower().endswith(term.lower()):
                return kb_value
        
        # Search knowledge graph recursively
        def search_graph(graph, term_parts):
            if not term_parts:
                return None
                
            current = term_parts[0]
            if current in graph:
                if isinstance(graph[current], dict):
                    if "definition" in graph[current]:
                        return graph[current]["definition"]
                    return search_graph(graph[current], term_parts[1:])
                return graph[current]
            return None
        
        # Try different term variations
        definition = search_graph(FINANCIAL_KNOWLEDGE_GRAPH, term_lower.split("_"))
        if definition:
            return definition
            
        # Try singular/plural variations
        if term_lower.endswith("s"):
            singular = term_lower[:-1]
            definition = search_graph(FINANCIAL_KNOWLEDGE_GRAPH, singular.split("_"))
            if definition:
                return definition
        
        return None
    
    @staticmethod
    def compare_terms(term1: str, term2: str) -> Optional[str]:
        """Compare two financial terms."""
        def1 = AdvancedFinancialChatbot.get_definition(term1)
        def2 = AdvancedFinancialChatbot.get_definition(term2)
        
        if not def1 or not def2:
            return None
            
        # Simple comparison - in a real implementation, this would be more sophisticated
        return (f"Comparison of {term1} and {term2}:\n"
                f"- {term1}: {def1}\n"
                f"- {term2}: {def2}\n"
                f"Key difference: {term1} is typically {'more' if len(def1) > len(def2) else 'less'} "
                "complex than {term2} in most financial contexts.")
    
    @staticmethod
    def suggest_strategy(goal: str) -> Optional[str]:
        """Suggest strategy for a financial goal."""
        goal_lower = goal.lower().replace(" ", "_")
        
        # Search knowledge graph for strategies
        for category, data in FINANCIAL_KNOWLEDGE_GRAPH.items():
            if isinstance(data, dict) and "strategies" in data:
                if goal_lower in category.lower():
                    strategies = data["strategies"]
                    if strategies:
                        if isinstance(strategies, list):
                            return (f"For {goal}, consider these strategies: " +
                                    ", ".join(strategies) + ".")
                        return f"For {goal}, consider: {strategies}."
        
        # Default strategies for common goals
        common_strategies = {
            "retirement": "Maximize contributions to tax-advantaged accounts like 401(k)s and IRAs, and maintain a diversified portfolio.",
            "debt": "Focus on paying off high-interest debt first (debt avalanche method) or smallest balances first (debt snowball method).",
            "savings": "Follow the 50/30/20 budget rule (50% needs, 30% wants, 20% savings) and automate your savings.",
            "college": "Consider a 529 plan for tax-advantaged education savings or Coverdell ESA for more investment options.",
            "home": "Save for a 20% down payment to avoid PMI, get pre-approved for a mortgage, and consider first-time homebuyer programs."
        }
        
        for key, strategy in common_strategies.items():
            if key in goal_lower:
                return strategy
                
        return None
    
    def _fallback_response(self, *args, **kwargs) -> str:
        """Generate a fallback response when no other match is found."""
        fallbacks = [
            "I'm here to help with any financial question—investments, savings, budgeting, taxes, insurance, retirement, and more.",
            "I can answer questions about personal finance, investing, retirement planning, and more. Try asking about a specific topic.",
            "For personalized advice, please provide your financial details. Otherwise, ask me about general financial topics.",
            "I specialize in financial advice. Try asking about investments, debt management, retirement planning, or other money topics."
        ]
        
        # Context-aware fallback
        client_id = kwargs.get("client_id")
        if client_id and client_id in self.user_context:
            last_topics = self.user_context[client_id]["last_topics"]
            if last_topics:
                return (f"I'm happy to discuss {', '.join(set(last_topics))} further. "
                        "Could you clarify or ask about a specific aspect?")
        
        return random.choice(fallbacks)