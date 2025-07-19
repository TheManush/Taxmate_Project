import 'dart:convert';
import 'package:http/http.dart' as http;
import 'financial_models.dart';

class FinancialService {
  final String baseUrl;

  FinancialService(this.baseUrl);

  Future<FinancialData?> getFinancialData(int clientId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/financial-data/$clientId'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return FinancialData(
          id: data['id'],
          clientId: data['client_id'],
          monthlySalary: (data['monthly_salary'] ?? 0).toDouble(),
          annualBonus: (data['annual_bonus'] ?? 0).toDouble(),
          otherIncome: (data['other_income'] ?? 0).toDouble(),
          monthlyRent: (data['monthly_rent'] ?? 0).toDouble(),
          utilities: (data['utilities'] ?? 0).toDouble(),
          foodExpenses: (data['food_expenses'] ?? 0).toDouble(),
          transportation: (data['transportation'] ?? 0).toDouble(),
          entertainment: (data['entertainment'] ?? 0).toDouble(),
          healthcare: (data['healthcare'] ?? 0).toDouble(),
          otherExpenses: (data['other_expenses'] ?? 0).toDouble(),
          savingsAccount: (data['savings_account'] ?? 0).toDouble(),
          checkingAccount: (data['checking_account'] ?? 0).toDouble(),
          investments: (data['investments'] ?? 0).toDouble(),
          propertyValue: (data['property_value'] ?? 0).toDouble(),
          vehicleValue: (data['vehicle_value'] ?? 0).toDouble(),
          otherAssets: (data['other_assets'] ?? 0).toDouble(),
          creditCardDebt: (data['credit_card_debt'] ?? 0).toDouble(),
          studentLoans: (data['student_loans'] ?? 0).toDouble(),
          mortgage: (data['mortgage'] ?? 0).toDouble(),
          carLoan: (data['car_loan'] ?? 0).toDouble(),
          otherDebts: (data['other_debts'] ?? 0).toDouble(),
          financialGoals: data['financial_goals'] ?? '',
          riskTolerance: data['risk_tolerance'] ?? 'Moderate',
          createdAt: data['created_at'] != null ? DateTime.parse(data['created_at']) : null,
          updatedAt: data['updated_at'] != null ? DateTime.parse(data['updated_at']) : null,
        );
      } else if (response.statusCode == 404) {
        return null; // No data found
      } else {
        throw Exception('Failed to load financial data');
      }
    } catch (e) {
      throw Exception('Error loading financial data: $e');
    }
  }

  Future<FinancialSummary?> getFinancialSummary(int clientId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/financial-summary/$clientId'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return FinancialSummary(
        totalIncome: (data['total_income'] ?? 0).toDouble(),
        totalExpenses: (data['total_expenses'] ?? 0).toDouble(),
        totalAssets: (data['total_assets'] ?? 0).toDouble(),
        totalLiabilities: (data['total_liabilities'] ?? 0).toDouble(),
        netWorth: (data['net_worth'] ?? 0).toDouble(),
        monthlySurplus: (data['monthly_surplus'] ?? 0).toDouble(),
        debtToIncomeRatio: (data['debt_to_income_ratio'] ?? 0).toDouble(),
        savingsRate: (data['savings_rate'] ?? 0).toDouble(),
      );
    } else if (response.statusCode == 404) {
      return null; // No financial data found
    } else {
      throw Exception('Failed to load financial summary: ${response.statusCode}');
    }
  }

  Future<void> saveFinancialData(int clientId, FinancialData data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/financial-data/$clientId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data.toJson()),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      String msg = 'Failed to save financial data';
      try {
        final err = jsonDecode(response.body);
        msg = err['detail'] ?? msg;
      } catch (_) {}
      throw Exception(msg);
    }
  }
}
