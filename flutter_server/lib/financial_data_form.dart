import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'financial_models.dart';
import 'financial_service.dart';
import 'financial_summary_page.dart';

class FinancialDataForm extends StatefulWidget {
  final int clientId;
  final FinancialService financialService;
  final FinancialData? existingData;
  final VoidCallback? onDataSaved;

  const FinancialDataForm({
    Key? key,
    required this.clientId,
    required this.financialService,
    this.existingData,
    this.onDataSaved,
  }) : super(key: key);

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

  void _loadExistingData() async {
    if (widget.existingData != null) {
      _setControllerValues(widget.existingData!);
    } else {
      // Try to load existing data from server
      try {
        final data = await widget.financialService.getFinancialData(widget.clientId);
        if (data != null && mounted) {
          _setControllerValues(data);
        }
      } catch (e) {
        // No existing data or error loading - that's fine for new users
        print('No existing financial data found: $e');
      }
    }
  }

  void _setControllerValues(FinancialData data) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Financial Data Form')),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFe0eafc), Color(0xFFcfdef3)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                margin: const EdgeInsets.symmetric(vertical: 18, horizontal: 2),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.account_balance_wallet, color: Color(0xFF3b82f6), size: 28),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Enter Your Financial Details', 
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1e293b)),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        _buildNumberField('Monthly Salary', _monthlySalaryController),
                        _buildNumberField('Annual Bonus', _annualBonusController),
                        _buildNumberField('Other Income', _otherIncomeController),
                        const SizedBox(height: 12),
                        _buildNumberField('Monthly Rent', _monthlyRentController),
                        _buildNumberField('Utilities', _utilitiesController),
                        _buildNumberField('Food Expenses', _foodExpensesController),
                        _buildNumberField('Transportation', _transportationController),
                        _buildNumberField('Entertainment', _entertainmentController),
                        _buildNumberField('Healthcare', _healthcareController),
                        _buildNumberField('Other Expenses', _otherExpensesController),
                        const SizedBox(height: 12),
                        _buildNumberField('Savings Account', _savingsAccountController),
                        _buildNumberField('Checking Account', _checkingAccountController),
                        _buildNumberField('Investments', _investmentsController),
                        _buildNumberField('Property Value', _propertyValueController),
                        _buildNumberField('Vehicle Value', _vehicleValueController),
                        _buildNumberField('Other Assets', _otherAssetsController),
                        const SizedBox(height: 12),
                        _buildNumberField('Credit Card Debt', _creditCardDebtController),
                        _buildNumberField('Student Loans', _studentLoansController),
                        _buildNumberField('Mortgage', _mortgageController),
                        _buildNumberField('Car Loan', _carLoanController),
                        _buildNumberField('Other Debts', _otherDebtsController),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _financialGoalsController,
                          decoration: const InputDecoration(
                            labelText: 'Financial Goals',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: _selectedRiskTolerance,
                          decoration: const InputDecoration(
                            labelText: 'Risk Tolerance',
                            border: OutlineInputBorder(),
                          ),
                          items: ['Low', 'Moderate', 'High']
                              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                              .toList(),
                          onChanged: (val) {
                            setState(() {
                              _selectedRiskTolerance = val ?? 'Moderate';
                            });
                          },
                        ),
                        const SizedBox(height: 22),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _submitForm,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              backgroundColor: Colors.blue[800],
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text('Save Data', style: TextStyle(fontSize: 18)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNumberField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          // Allow empty fields - they will default to 0
          if (value != null && value.isNotEmpty && double.tryParse(value) == null) {
            return 'Enter a valid number';
          }
          return null;
        },
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final data = FinancialData(
        clientId: widget.clientId,
        monthlySalary: double.tryParse(_monthlySalaryController.text) ?? 0,
        annualBonus: double.tryParse(_annualBonusController.text) ?? 0,
        otherIncome: double.tryParse(_otherIncomeController.text) ?? 0,
        monthlyRent: double.tryParse(_monthlyRentController.text) ?? 0,
        utilities: double.tryParse(_utilitiesController.text) ?? 0,
        foodExpenses: double.tryParse(_foodExpensesController.text) ?? 0,
        transportation: double.tryParse(_transportationController.text) ?? 0,
        entertainment: double.tryParse(_entertainmentController.text) ?? 0,
        healthcare: double.tryParse(_healthcareController.text) ?? 0,
        otherExpenses: double.tryParse(_otherExpensesController.text) ?? 0,
        savingsAccount: double.tryParse(_savingsAccountController.text) ?? 0,
        checkingAccount: double.tryParse(_checkingAccountController.text) ?? 0,
        investments: double.tryParse(_investmentsController.text) ?? 0,
        propertyValue: double.tryParse(_propertyValueController.text) ?? 0,
        vehicleValue: double.tryParse(_vehicleValueController.text) ?? 0,
        otherAssets: double.tryParse(_otherAssetsController.text) ?? 0,
        creditCardDebt: double.tryParse(_creditCardDebtController.text) ?? 0,
        studentLoans: double.tryParse(_studentLoansController.text) ?? 0,
        mortgage: double.tryParse(_mortgageController.text) ?? 0,
        carLoan: double.tryParse(_carLoanController.text) ?? 0,
        otherDebts: double.tryParse(_otherDebtsController.text) ?? 0,
        financialGoals: _financialGoalsController.text,
        riskTolerance: _selectedRiskTolerance,
      );
      await widget.financialService.saveFinancialData(widget.clientId, data);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Financial data saved successfully!'),
            backgroundColor: Color(0xFF7C3AED),
            behavior: SnackBarBehavior.floating,
          ),
        );
        // Call the callback to notify parent that data was saved
        widget.onDataSaved?.call();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save data: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
