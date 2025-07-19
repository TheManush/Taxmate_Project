class FinancialData {
  final int? id;
  final int clientId;
  final double monthlySalary;
  final double annualBonus;
  final double otherIncome;
  final double monthlyRent;
  final double utilities;
  final double foodExpenses;
  final double transportation;
  final double entertainment;
  final double healthcare;
  final double otherExpenses;
  final double savingsAccount;
  final double checkingAccount;
  final double investments;
  final double propertyValue;
  final double vehicleValue;
  final double otherAssets;
  final double creditCardDebt;
  final double studentLoans;
  final double mortgage;
  final double carLoan;
  final double otherDebts;
  final String financialGoals;
  final String riskTolerance;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  FinancialData({
    this.id,
    required this.clientId,
    this.monthlySalary = 0.0,
    this.annualBonus = 0.0,
    this.otherIncome = 0.0,
    this.monthlyRent = 0.0,
    this.utilities = 0.0,
    this.foodExpenses = 0.0,
    this.transportation = 0.0,
    this.entertainment = 0.0,
    this.healthcare = 0.0,
    this.otherExpenses = 0.0,
    this.savingsAccount = 0.0,
    this.checkingAccount = 0.0,
    this.investments = 0.0,
    this.propertyValue = 0.0,
    this.vehicleValue = 0.0,
    this.otherAssets = 0.0,
    this.creditCardDebt = 0.0,
    this.studentLoans = 0.0,
    this.mortgage = 0.0,
    this.carLoan = 0.0,
    this.otherDebts = 0.0,
    this.financialGoals = '',
    this.riskTolerance = 'Moderate',
    this.createdAt,
    this.updatedAt,
  });
  Map<String, dynamic> toJson() {
    return {
      'client_id': clientId,
      'monthly_salary': monthlySalary,
      'annual_bonus': annualBonus,
      'other_income': otherIncome,
      'monthly_rent': monthlyRent,
      'utilities': utilities,
      'food_expenses': foodExpenses,
      'transportation': transportation,
      'entertainment': entertainment,
      'healthcare': healthcare,
      'other_expenses': otherExpenses,
      'savings_account': savingsAccount,
      'checking_account': checkingAccount,
      'investments': investments,
      'property_value': propertyValue,
      'vehicle_value': vehicleValue,
      'other_assets': otherAssets,
      'credit_card_debt': creditCardDebt,
      'student_loans': studentLoans,
      'mortgage': mortgage,
      'car_loan': carLoan,
      'other_debts': otherDebts,
      'financial_goals': financialGoals,
      'risk_tolerance': riskTolerance,
    };
  }
}

class FinancialSummary {
  final double totalIncome;
  final double totalExpenses;
  final double totalAssets;
  final double totalLiabilities;
  final double netWorth;
  final double monthlySurplus;
  final double debtToIncomeRatio;
  final double savingsRate;

  FinancialSummary({
    required this.totalIncome,
    required this.totalExpenses,
    required this.totalAssets,
    required this.totalLiabilities,
    required this.netWorth,
    required this.monthlySurplus,
    required this.debtToIncomeRatio,
    required this.savingsRate,
  });
}

class ChatMessage {
  final int? id;
  final int clientId;
  final String message;
  final String response;
  final DateTime timestamp;

  ChatMessage({
    this.id,
    required this.clientId,
    required this.message,
    required this.response,
    required this.timestamp,
  });
}
