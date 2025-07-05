class FinancialData {
  final int? id;
  final int clientId;
  
  // Income
  final double monthlySalary;
  final double annualBonus;
  final double otherIncome;
  
  // Expenses
  final double monthlyRent;
  final double utilities;
  final double foodExpenses;
  final double transportation;
  final double entertainment;
  final double healthcare;
  final double otherExpenses;
  
  // Assets
  final double savingsAccount;
  final double checkingAccount;
  final double investments;
  final double propertyValue;
  final double vehicleValue;
  final double otherAssets;
  
  // Liabilities
  final double creditCardDebt;
  final double studentLoans;
  final double mortgage;
  final double carLoan;
  final double otherDebts;
  
  // Goals
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

  factory FinancialData.fromJson(Map<String, dynamic> json) {
    return FinancialData(
      id: json['id'],
      clientId: json['client_id'],
      monthlySalary: (json['monthly_salary'] ?? 0.0).toDouble(),
      annualBonus: (json['annual_bonus'] ?? 0.0).toDouble(),
      otherIncome: (json['other_income'] ?? 0.0).toDouble(),
      monthlyRent: (json['monthly_rent'] ?? 0.0).toDouble(),
      utilities: (json['utilities'] ?? 0.0).toDouble(),
      foodExpenses: (json['food_expenses'] ?? 0.0).toDouble(),
      transportation: (json['transportation'] ?? 0.0).toDouble(),
      entertainment: (json['entertainment'] ?? 0.0).toDouble(),
      healthcare: (json['healthcare'] ?? 0.0).toDouble(),
      otherExpenses: (json['other_expenses'] ?? 0.0).toDouble(),
      savingsAccount: (json['savings_account'] ?? 0.0).toDouble(),
      checkingAccount: (json['checking_account'] ?? 0.0).toDouble(),
      investments: (json['investments'] ?? 0.0).toDouble(),
      propertyValue: (json['property_value'] ?? 0.0).toDouble(),
      vehicleValue: (json['vehicle_value'] ?? 0.0).toDouble(),
      otherAssets: (json['other_assets'] ?? 0.0).toDouble(),
      creditCardDebt: (json['credit_card_debt'] ?? 0.0).toDouble(),
      studentLoans: (json['student_loans'] ?? 0.0).toDouble(),
      mortgage: (json['mortgage'] ?? 0.0).toDouble(),
      carLoan: (json['car_loan'] ?? 0.0).toDouble(),
      otherDebts: (json['other_debts'] ?? 0.0).toDouble(),
      financialGoals: json['financial_goals'] ?? '',
      riskTolerance: json['risk_tolerance'] ?? 'Moderate',
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
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

  factory FinancialSummary.fromJson(Map<String, dynamic> json) {
    return FinancialSummary(
      totalIncome: (json['total_income'] ?? 0.0).toDouble(),
      totalExpenses: (json['total_expenses'] ?? 0.0).toDouble(),
      totalAssets: (json['total_assets'] ?? 0.0).toDouble(),
      totalLiabilities: (json['total_liabilities'] ?? 0.0).toDouble(),
      netWorth: (json['net_worth'] ?? 0.0).toDouble(),
      monthlySurplus: (json['monthly_surplus'] ?? 0.0).toDouble(),
      debtToIncomeRatio: (json['debt_to_income_ratio'] ?? 0.0).toDouble(),
      savingsRate: (json['savings_rate'] ?? 0.0).toDouble(),
    );
  }
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

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      clientId: json['client_id'],
      message: json['message'],
      response: json['response'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}