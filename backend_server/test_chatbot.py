#!/usr/bin/env python3
"""
Simple test script for the financial chatbot
"""

def test_mutual_fund_response():
    try:
        from simple_chatbot import AdvancedFinancialChatbot
        
        print("Initializing chatbot...")
        bot = AdvancedFinancialChatbot()
        
        print("Testing mutual fund query...")
        response = bot.generate_response("mutual fund", 1)
        print(f"Response: {response}")
        
        print("\nTesting 'what is a mutual fund' query...")
        response2 = bot.generate_response("what is a mutual fund", 1)
        print(f"Response: {response2}")
        
        return True
        
    except Exception as e:
        print(f"Error: {e}")
        return False

if __name__ == "__main__":
    test_mutual_fund_response()
