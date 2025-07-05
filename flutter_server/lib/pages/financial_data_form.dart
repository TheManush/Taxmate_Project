import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/financial_models.dart';
import '../services/financial_service.dart';

class FinancialDataForm extends StatefulWidget {
  final int clientId;
  final FinancialService financialService;
  final FinancialData? existingData;

  const FinancialDataForm({
    super.key,
    required this.clientId,
    required this.financialService,
    this.existingData,
  });

  @override
  State<FinancialDataForm> createState() => _FinancialDataFormState();
}

class _FinancialDataFormState extends State<FinancialDataForm> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controllers for all fields
  final _monthlySalaryController = TextEditingController();
  final _annualBonusController = TextEditingController();
  final _otherIncomeController = TextEditingController();
  final _monthlyRentController = TextEditingController();
  final _utilitiesController = TextEditingController();
  final _foodExpensesController = TextEditingController();
  final _transportationController = TextEditingController();
  final _entertainmentController = TextEditingController();
  final _healthcareController = TextEditingController();
  final _otherExpensesController = TextEditingController();
  final _savingsAccountController = TextEditingController();
  final _checkingAccountController = TextEditingController();
  final _investmentsController = TextEditingController();
  final _propertyValueController = TextEditingController();
  final _vehicleValueController = TextEditingController();
  final _otherAssetsController = TextEditingController();
  final _creditCardDebtController = TextEditingController();
  final _studentLoansController = TextEditingController();
  final _mortgageController = TextEditingController();
  final _carLoanController = TextEditingController();
  final _otherDebtsController = TextEditingController();
  final _financialGoalsController = TextEditingController();

  String _selectedRiskTolerance = 'Moderate';

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  void _loadExistingData() {
    if (widget.existingData != null) {
      final data = widget.existingData!;
      _monthlySalaryController.text = data.monthlySalary.toString();
      _annualBonusController.text = data.annualBonus.toString();
      _otherIncomeController.text = data.otherIncome.toString();
      _monthlyRentController.text = data.monthlyRent.toString();
      _utilitiesController.text = data.utilities.toString();
      _foodExpensesController.text = data.foodExpenses.toString();
      _transportationController.text = data.transportation.toString();
      _entertainmentController.text = data.entertainment.toString();
      _healthcareController.text = data.healthcare.toString();
      _otherExpensesController.text = data.otherExpenses.toString();
      _savingsAccountController.text = data.savingsAccount.toString();
      _checkingAccountController.text = data.checkingAccount.toString();
      _investmentsController.text = data.investments.toString();
      _propertyValueController.text = data.propertyValue.toString();
      _vehicleValueController.text = data.vehicleValue.toString();
      _otherAssetsController.text = data.otherAssets.toString();
      _creditCardDebtController.text = data.creditCardDebt.toString();
      _studentLoansController.text = data.studentLoans.toString();
      _mortgageController.text = data.mortgage.toString();
      _carLoanController.text = data.carLoan.toString();
      _otherDebtsController.text = data.otherDebts.toString();
      _financialGoalsController.text = data.financialGoals;
      _selectedRiskTolerance = data.riskTolerance;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingData != null ? 'Update Financial Data' : 'Add Financial Data'),
        backgroundColor: Colors.blue[800],
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('💰 Income Information'),
                    _buildAmountField(_monthlySalaryController, 'Monthly Salary', Icons.attach_money),
                    _buildAmountField(_annualBonusController, 'Annual Bonus', Icons.card_giftcard),
                    _buildAmountField(_otherIncomeController, 'Other Income', Icons.trending_up),
                    
                    const SizedBox(height: 24),
                    _buildSectionHeader('💸 Monthly Expenses'),
                    _buildAmountField(_monthlyRentController, 'Rent/Mortgage Payment', Icons.home),
                    _buildAmountField(_utilitiesController, 'Utilities', Icons.electrical_services),
                    _buildAmountField(_foodExpensesController, 'Food & Groceries', Icons.restaurant),
                    _buildAmountField(_transportationController, 'Transportation', Icons.directions_car),
                    _buildAmountField(_entertainmentController, 'Entertainment', Icons.movie),
                    _buildAmountField(_healthcareController, 'Healthcare', Icons.local_hospital),
                    _buildAmountField(_otherExpensesController, 'Other Expenses', Icons.more_horiz),
                    
                    const SizedBox(height: 24),
                    _buildSectionHeader('📈 Assets'),
                    _buildAmountField(_savingsAccountController, 'Savings Account', Icons.savings),
                    _buildAmountField(_checkingAccountController, 'Checking Account', Icons.account_balance),
                    _buildAmountField(_investmentsController, 'Investments', Icons.trending_up),
                    _buildAmountField(_propertyValueController, 'Property Value', Icons.home_work),
                    _buildAmountField(_vehicleValueController, 'Vehicle Value', Icons.directions_car),
                    _buildAmountField(_otherAssetsController, 'Other Assets', Icons.inventory),
                    
                    const SizedBox(height: 24),
                    _buildSectionHeader('📉 Liabilities'),
                    _buildAmountField(_creditCardDebtController, 'Credit Card Debt', Icons.credit_card),
                    _buildAmountField(_studentLoansController, 'Student Loans', Icons.school),
                    _buildAmountField(_mortgageController, 'Mortgage Balance', Icons.home),
                    _buildAmountField(_carLoanController, 'Car Loan', Icons.directions_car),
                    _buildAmountField(_otherDebtsController, 'Other Debts', Icons.money_off),
                    
                    const SizedBox(height: 24),
                    _buildSectionHeader('🎯 Financial Goals & Risk'),
                    _buildGoalsField(),
                    _buildRiskToleranceField(),
                    
                    const SizedBox(height: 32),
                    _buildSaveButton(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }

  Widget _buildAmountField(TextEditingController controller, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
        ],
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.blue[700]),
          prefixText: '\$ ',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blue[700]!, width: 2),
          ),
        ),
        validator: (value) {
          if (value != null && value.isNotEmpty) {
            final amount = double.tryParse(value);
            if (amount == null || amount < 0) {
              return 'Please enter a valid amount';
            }
          }
          return null;
        },
      ),
    );
  }

  Widget _buildGoalsField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: _financialGoalsController,
        maxLines: 3,
        decoration: InputDecoration(
          labelText: 'Financial Goals',
          hintText: 'Describe your short-term and long-term financial goals...',
          prefixIcon: Icon(Icons.flag, color: Colors.blue[700]),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blue[700]!, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildRiskToleranceField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: _selectedRiskTolerance,
        decoration: InputDecoration(
          labelText: 'Risk Tolerance',
          prefixIcon: Icon(Icons.assessment, color: Colors.blue[700]),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blue[700]!, width: 2),
          ),
        ),
        items: ['Conservative', 'Moderate', 'Aggressive'].map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            _selectedRiskTolerance = newValue!;
          });
        },
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _saveFinancialData,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue[700],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Save Financial Data',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  double _parseAmount(String value) {
    return value.isEmpty ? 0.0 : double.parse(value);
  }

  Future<void> _saveFinancialData() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final financialData = FinancialData(
        clientId: widget.clientId,
        monthlySalary: _parseAmount(_monthlySalaryController.text),
        annualBonus: _parseAmount(_annualBonusController.text),
        otherIncome: _parseAmount(_otherIncomeController.text),
        monthlyRent: _parseAmount(_monthlyRentController.text),
        utilities: _parseAmount(_utilitiesController.text),
        foodExpenses: _parseAmount(_foodExpensesController.text),
        transportation: _parseAmount(_transportationController.text),
        entertainment: _parseAmount(_entertainmentController.text),
        healthcare: _parseAmount(_healthcareController.text),
        otherExpenses: _parseAmount(_otherExpensesController.text),
        savingsAccount: _parseAmount(_savingsAccountController.text),
        checkingAccount: _parseAmount(_checkingAccountController.text),
        investments: _parseAmount(_investmentsController.text),
        propertyValue: _parseAmount(_propertyValueController.text),
        vehicleValue: _parseAmount(_vehicleValueController.text),
        otherAssets: _parseAmount(_otherAssetsController.text),
        creditCardDebt: _parseAmount(_creditCardDebtController.text),
        studentLoans: _parseAmount(_studentLoansController.text),
        mortgage: _parseAmount(_mortgageController.text),
        carLoan: _parseAmount(_carLoanController.text),
        otherDebts: _parseAmount(_otherDebtsController.text),
        financialGoals: _financialGoalsController.text,
        riskTolerance: _selectedRiskTolerance,
      );

      await widget.financialService.saveFinancialData(widget.clientId, financialData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Financial data saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    // Dispose all controllers
    _monthlySalaryController.dispose();
    _annualBonusController.dispose();
    _otherIncomeController.dispose();
    _monthlyRentController.dispose();
    _utilitiesController.dispose();
    _foodExpensesController.dispose();
    _transportationController.dispose();
    _entertainmentController.dispose();
    _healthcareController.dispose();
    _otherExpensesController.dispose();
    _savingsAccountController.dispose();
    _checkingAccountController.dispose();
    _investmentsController.dispose();
    _propertyValueController.dispose();
    _vehicleValueController.dispose();
    _otherAssetsController.dispose();
    _creditCardDebtController.dispose();
    _studentLoansController.dispose();
    _mortgageController.dispose();
    _carLoanController.dispose();
    _otherDebtsController.dispose();
    _financialGoalsController.dispose();
    super.dispose();
  }
}