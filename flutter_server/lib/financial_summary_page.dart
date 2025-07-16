import 'package:flutter/material.dart';
import 'financial_models.dart';
import 'financial_service.dart';
import 'financial_data_form.dart';

class FinancialSummaryPage extends StatefulWidget {
  final int clientId;
  final FinancialService financialService;

  const FinancialSummaryPage({
    Key? key,
    required this.clientId,
    required this.financialService,
  }) : super(key: key);

  @override
  State<FinancialSummaryPage> createState() => _FinancialSummaryPageState();
}

class _FinancialSummaryPageState extends State<FinancialSummaryPage> {
  FinancialData? _financialData;
  FinancialSummary? _financialSummary;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFinancialSummary();
  }

  Future<void> _loadFinancialSummary() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _financialSummary = null;
    });
    
    try {
      final summary = await widget.financialService.getFinancialSummary(widget.clientId);
      setState(() {
        _financialSummary = summary; // Will be null if no data
      });
    } catch (e) {
      print('Financial summary error: $e'); // Debug print
      // Check if it's a "no data" error
      String errorString = e.toString().toLowerCase();
      if (errorString.contains('404') || 
          errorString.contains('no financial data found') ||
          errorString.contains('no data')) {
        setState(() {
          _financialSummary = null; // Show "no data" UI
        });
      } else {
        setState(() {
          _error = 'Unable to load financial summary. Please try again.';
        });
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Financial Summary')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 64,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading summary',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(_error!),
                      const SizedBox(height: 8),
                      Text(
                        'Client ID: ${widget.clientId}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadFinancialSummary,
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                )
              : _financialSummary == null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: const Color(0xFF7C3AED).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: const Icon(
                              Icons.analytics_outlined,
                              size: 50,
                              color: Color(0xFF7C3AED),
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'No Financial Data Available',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Enter your financial information first to see your summary',
                            style: TextStyle(color: Color(0xFF64748B)),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FinancialDataForm(
                                    clientId: widget.clientId,
                                    financialService: widget.financialService,
                                  ),
                                ),
                              ).then((_) => _loadFinancialSummary());
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Enter Financial Data'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              backgroundColor: const Color(0xFF7C3AED),
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    )
                  : _buildSummaryView(),
    );
  }

  Widget _buildSummaryView() {
    final s = _financialSummary!;
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFe0eafc), Color(0xFFcfdef3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.pie_chart, color: Color(0xFF3b82f6), size: 32),
                  const SizedBox(width: 10),
                  const Text('Financial Overview', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF1e293b))),
                ],
              ),
              const SizedBox(height: 18),
              _buildBarChart(s),
              const SizedBox(height: 18),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _modernStatCard('Net Worth', s.netWorth, Colors.blue, isCurrency: true),
                  _modernStatCard('Total Income', s.totalIncome, Colors.green, isCurrency: true),
                  _modernStatCard('Total Expenses', s.totalExpenses, Colors.red, isCurrency: true),
                  _modernStatCard('Total Assets', s.totalAssets, Colors.teal, isCurrency: true),
                  _modernStatCard('Total Liabilities', s.totalLiabilities, Colors.orange, isCurrency: true),
                  _modernStatCard('Monthly Surplus', s.monthlySurplus, Colors.purple, isCurrency: true),
                  _modernStatCard('Debt-to-Income Ratio', s.debtToIncomeRatio, Colors.brown, isCurrency: false, isPercent: true),
                  _modernStatCard('Savings Rate', s.savingsRate, Colors.indigo, isCurrency: false, isPercent: true),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FinancialDataForm(
                          clientId: widget.clientId,
                          financialService: widget.financialService,
                        ),
                      ),
                    ).then((_) => _loadFinancialSummary()); // Refresh data when returning
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit Financial Data'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    backgroundColor: const Color(0xFF3b82f6),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'Analysis generated for you! 💡',
                  style: TextStyle(fontSize: 16, color: Colors.grey[700], fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _modernStatCard(String title, double value, Color color, {bool isCurrency = false, bool isPercent = false}) {
    String displayValue = isCurrency
        ? '\$${value.toStringAsFixed(2)}'
        : isPercent
            ? '${value.toStringAsFixed(1)}%'
            : value.toStringAsFixed(2);
    return Container(
      width: MediaQuery.of(context).size.width / 2 - 24,
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.09),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(0.18),
                child: Icon(Icons.trending_up, color: color, size: 20),
                radius: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: color, fontSize: 15)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            displayValue,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(FinancialSummary s) {
    final maxVal = [s.netWorth.abs(), s.totalIncome.abs(), s.totalExpenses.abs()].reduce((a, b) => a > b ? a : b);
    double barWidth(double val) => maxVal == 0 ? 0 : (val.abs() / maxVal) * 200;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Key Metrics', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        _barRow('Net Worth', s.netWorth, Colors.blue, barWidth(s.netWorth)),
        _barRow('Income', s.totalIncome, Colors.green, barWidth(s.totalIncome)),
        _barRow('Expenses', s.totalExpenses, Colors.red, barWidth(s.totalExpenses)),
      ],
    );
  }

  Widget _barRow(String label, double value, Color color, double width) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 80, child: Text(label, style: TextStyle(fontWeight: FontWeight.w500))),
          Container(
            height: 18,
            width: width,
            decoration: BoxDecoration(
              color: color.withOpacity(0.7),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(width: 8),
          Text(value.toStringAsFixed(2), style: TextStyle(fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, double value, Color color, {bool isCurrency = false, bool isPercent = false}) {
    String displayValue = isCurrency
        ? '\$${value.toStringAsFixed(2)}'
        : isPercent
            ? '${value.toStringAsFixed(1)}%'
            : value.toStringAsFixed(2);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: color.withOpacity(0.2), child: Icon(Icons.pie_chart, color: color)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: Text(displayValue, style: TextStyle(fontSize: 18, color: color, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
