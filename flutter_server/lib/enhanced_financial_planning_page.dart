import 'package:flutter/material.dart';
import 'api_service.dart';
import 'financial_service.dart';
import 'financial_data_form.dart';
import 'financial_summary_page.dart';
import 'financial_report_download.dart';
import 'FP_profile_from_client.dart';

class EnhancedFinancialPlanningPage extends StatefulWidget {
  final ApiService apiService;
  final int clientId;

  const EnhancedFinancialPlanningPage({
    super.key, 
    required this.apiService, 
    required this.clientId,
  });

  @override
  State<EnhancedFinancialPlanningPage> createState() => _EnhancedFinancialPlanningPageState();
}

class _EnhancedFinancialPlanningPageState extends State<EnhancedFinancialPlanningPage> with TickerProviderStateMixin {
  late TabController _tabController;
  late FinancialService _financialService;
  late Future<List<Map<String, dynamic>>> _futureFPs;
  bool _hasFinancialData = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _financialService = FinancialService(widget.apiService.baseUrl);
    _futureFPs = widget.apiService.getFinancialPlanners();
    _checkFinancialData();
    
    // Listen to tab changes to prevent accessing Summary tab
    _tabController.addListener(_handleTabChange);
  }

  void _handleTabChange() {
    if (_tabController.index == 2 && !_hasFinancialData) {
      // If trying to access Summary tab without data, go back to Data Entry
      Future.delayed(Duration.zero, () {
        _tabController.animateTo(1); // Go to Data Entry tab
        _showDataRequiredSnackBar();
      });
    }
  }

  void _showDataRequiredSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please enter your financial data first to view the summary'),
        backgroundColor: Color(0xFF7C3AED),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _checkFinancialData() async {
    try {
      final data = await _financialService.getFinancialData(widget.clientId);
      setState(() {
        _hasFinancialData = data != null;
      });
    } catch (e) {
      setState(() {
        _hasFinancialData = false;
      });
    }
  }

  void _onDataSaved() {
    setState(() {
      _hasFinancialData = true;
    });
    
    // Show success message and automatically switch to Summary tab
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✨ Summary tab is now available! Switching to summary...'),
            backgroundColor: Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
        
        // Auto-switch to Summary tab after data is saved
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            _tabController.animateTo(2); // Switch to Summary tab
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Financial Planning',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF64748B)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF7C3AED),
          unselectedLabelColor: const Color(0xFF64748B),
          indicatorColor: const Color(0xFF7C3AED),
          indicatorWeight: 3,
          tabs: [
            const Tab(text: 'Overview', icon: Icon(Icons.dashboard, size: 20)),
            const Tab(text: 'Data Entry', icon: Icon(Icons.edit, size: 20)),
            Tab(
              child: Opacity(
                opacity: _hasFinancialData ? 1.0 : 0.4,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.analytics, 
                      size: 20,
                      color: _hasFinancialData ? null : Colors.grey[400],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Summary',
                      style: TextStyle(
                        color: _hasFinancialData ? null : Colors.grey[400],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Tab(text: 'Advisors', icon: Icon(Icons.people, size: 20)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildDataEntryTab(),
          _buildSummaryTab(),
          _buildAdvisorsTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeCard(),
          const SizedBox(height: 16),
          _buildQuickActions(),
          const SizedBox(height: 16),
          FinancialReportDownloadPage(
            clientId: widget.clientId,
            apiBaseUrl: widget.apiService.baseUrl,
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7C3AED), Color(0xFF9333EA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C3AED).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.account_balance_wallet,
            color: Colors.white,
            size: 32,
          ),
          const SizedBox(height: 12),
          const Text(
            'Welcome to Financial Planning',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Take control of your financial future with personalized planning and expert advice.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                'Enter Financial Data',
                'Start by adding your income, expenses, and assets',
                Icons.input,
                const Color(0xFF10B981),
                () => _tabController.animateTo(1),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                'View Summary',
                'See your financial overview and insights',
                Icons.analytics,
                const Color(0xFF3B82F6),
                () => _tabController.animateTo(2),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF64748B),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataEntryTab() {
    return FinancialDataForm(
      clientId: widget.clientId,
      financialService: _financialService,
      onDataSaved: _onDataSaved,
    );
  }

  Widget _buildSummaryTab() {
    return FinancialSummaryPage(
      clientId: widget.clientId,
      financialService: _financialService,
    );
  }

  Widget _buildAdvisorsTab() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _futureFPs,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7C3AED)),
                  strokeWidth: 3,
                ),
                SizedBox(height: 16),
                Text(
                  'Loading Financial Planners...',
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.2)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Color(0xFFEF4444),
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(
                      color: Color(0xFFEF4444),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        } else if (snapshot.data == null || snapshot.data!.isEmpty) {
          return Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.people_outline,
                    color: Color(0xFF64748B),
                    size: 48,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No Financial Planners Available',
                    style: TextStyle(
                      color: Color(0xFF1E293B),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Currently, there are no financial planners available. Please check back later.',
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        } else {
          final fpList = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: fpList.length,
            itemBuilder: (context, index) {
              final fp = fpList[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FPProfileFromClient(
                        apiService: widget.apiService,
                        fpData: fp,
                        clientId: widget.clientId,
                      ),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
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
                            radius: 24,
                            backgroundColor: const Color(0xFF7C3AED).withOpacity(0.1),
                            child: Text(
                              _getInitials(fp['full_name'] ?? 'FP'),
                              style: const TextStyle(
                                color: Color(0xFF7C3AED),
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  fp['full_name'] ?? 'Unknown',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  fp['email'] ?? '',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios,
                            color: Color(0xFF64748B),
                            size: 16,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoChip(
                              Icons.work,
                              'Experience',
                              fp['experience'] ?? 'Not specified',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildInfoChip(
                              Icons.phone,
                              'Phone',
                              fp['phone'] ?? 'Not provided',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }

  Widget _buildInfoChip(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: const Color(0xFF64748B),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF1E293B),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    List<String> names = name.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    } else if (names.isNotEmpty) {
      return names[0][0].toUpperCase();
    }
    return 'FP';
  }
}
