import 'package:flutter/material.dart';
import 'financial_models.dart';
import 'financial_service.dart';
import 'financial_data_form.dart';

class FinancialSummaryPage extends StatefulWidget {
  final int clientId;
  final FinancialService financialService;

  const FinancialSummaryPage({
    super.key,
    required this.clientId,
    required this.financialService,
  });

  @override
  State<FinancialSummaryPage> createState() => _FinancialSummaryPageState();
}

class _FinancialSummaryPageState extends State<FinancialSummaryPage> {
  FinancialData? _financialData;
  FinancialSummary? _financialSummary;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFinancialData();
  }

  Future<void> _loadFinancialData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final data = await widget.financialService.getFinancialData(widget.clientId);
      if (data != null) {
        final summary = await widget.financialService.getFinancialSummary(widget.clientId);
        setState(() {
          _financialData = data;
          _financialSummary = summary;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Summary'),
        backgroundColor: Colors.blue[800],
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _navigateToEditForm,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _financialData == null
              ? _buildNoDataView()
              : _buildSummaryView(),
      floatingActionButton: _financialData == null
          ? FloatingActionButton.extended(
              onPressed: _navigateToAddForm,
              icon: const Icon(Icons.add),
              label: const Text('Add Financial Data'),
              backgroundColor: Colors.blue[700],
            )
          : null,
    );
  }

  Widget _buildNoDataView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet,
            size: 100,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          Text(
            'No Financial Data Found',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Add your financial information to get\npersonalized insights and advice',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildNetWorthCard(),
          const SizedBox(height: 16),
          _buildQuickStatsGrid(),
          const SizedBox(height: 16),
          _buildIncomeExpenseCard(),
          const SizedBox(height: 16),
          _buildAssetsLiabilitiesCard(),
          const SizedBox(height: 16),
          _buildFinancialHealthCard(),
        ],
      ),
    );
  }

  Widget _buildNetWorthCard() {
    final netWorth = _financialSummary?.netWorth ?? 0;
    final isPositive = netWorth >= 0;

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: isPositive
                ? [Colors.green[400]!, Colors.green[600]!]
                : [Colors.red[400]!, Colors.red[600]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isPositive ? Icons.trending_up : Icons.trending_down,
                  color: Colors.white,
                  size: 32,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Net Worth',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '\$${_formatCurrency(netWorth)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isPositive
                  ? 'Great! Your assets exceed your liabilities'
                  : 'Focus on reducing debt and building assets',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStatsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: [
        _buildStatCard(
          'Monthly Surplus',
          _financialSummary?.monthlySurplus ?? 0,
          Icons.account_balance_wallet,
          Colors.blue,
        ),
        _buildStatCard(
          'Savings Rate',
          _financialSummary?.savingsRate ?? 0,
          Icons.savings,
          Colors.green,
          isPercentage: true,
        ),
        _buildStatCard(
          'Debt Ratio',
          _financialSummary?.debtToIncomeRatio ?? 0,
          Icons.credit_card,
          Colors.orange,
          isPercentage: true,
        ),
        _buildStatCard(
          'Total Assets',
          _financialSummary?.totalAssets ?? 0,
          Icons.trending_up,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, double value, IconData icon, Color color, {bool isPercentage = false}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              isPercentage
                  ? '${value.toStringAsFixed(1)}%'
                  : '\$${_formatCurrency(value)}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncomeExpenseCard() {
    final totalIncome = _financialSummary?.totalIncome ?? 0;
    final totalExpenses = _financialSummary?.totalExpenses ?? 0;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Annual Income vs Expenses',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildProgressBar('Income', totalIncome, Colors.green, totalIncome),
            const SizedBox(height: 16),
            _buildProgressBar('Expenses', totalExpenses, Colors.red, totalIncome),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(String label, double value, Color color, double maxValue) {
    final percentage = maxValue > 0 ? (value / maxValue) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '\$${_formatCurrency(value)}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: percentage.clamp(0.0, 1.0),
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 8,
        ),
      ],
    );
  }

  Widget _buildAssetsLiabilitiesCard() {
    final totalAssets = _financialSummary?.totalAssets ?? 0;
    final totalLiabilities = _financialSummary?.totalLiabilities ?? 0;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Assets vs Liabilities',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildAssetLiabilityItem(
                    'Assets',
                    totalAssets,
                    Icons.trending_up,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildAssetLiabilityItem(
                    'Liabilities',
                    totalLiabilities,
                    Icons.trending_down,
                    Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssetLiabilityItem(String title, double value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '\$${_formatCurrency(value)}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialHealthCard() {
    final savingsRate = _financialSummary?.savingsRate ?? 0;
    final debtRatio = _financialSummary?.debtToIncomeRatio ?? 0;

    String healthStatus;
    Color healthColor;
    IconData healthIcon;

    if (savingsRate > 20 && debtRatio < 20) {
      healthStatus = 'Excellent';
      healthColor = Colors.green;
      healthIcon = Icons.sentiment_very_satisfied;
    } else if (savingsRate > 10 && debtRatio < 40) {
      healthStatus = 'Good';
      healthColor = Colors.blue;
      healthIcon = Icons.sentiment_satisfied;
    } else if (savingsRate > 0 && debtRatio < 60) {
      healthStatus = 'Fair';
      healthColor = Colors.orange;
      healthIcon = Icons.sentiment_neutral;
    } else {
      healthStatus = 'Needs Improvement';
      healthColor = Colors.red;
      healthIcon = Icons.sentiment_dissatisfied;
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Financial Health Score',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Icon(healthIcon, color: healthColor, size: 48),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        healthStatus,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: healthColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _getHealthAdvice(healthStatus),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getHealthAdvice(String status) {
    switch (status) {
      case 'Excellent':
        return 'Keep up the great work! Consider increasing investments.';
      case 'Good':
        return 'You\'re on the right track. Focus on increasing savings.';
      case 'Fair':
        return 'Room for improvement. Review your budget and reduce expenses.';
      default:
        return 'Consider speaking with a financial advisor for personalized guidance.';
    }
  }

  String _formatCurrency(double amount) {
    if (amount.abs() >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount.abs() >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    } else {
      return amount.toStringAsFixed(0);
    }
  }

  Future<void> _navigateToAddForm() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FinancialDataForm(
          clientId: widget.clientId,
          financialService: widget.financialService,
        ),
      ),
    );

    if (result == true) {
      _loadFinancialData();
    }
  }

  Future<void> _navigateToEditForm() async {
    if (_financialData == null) return;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FinancialDataForm(
          clientId: widget.clientId,
          financialService: widget.financialService,
          existingData: _financialData,
        ),
      ),
    );

    if (result == true) {
      _loadFinancialData();
    }
  }
}