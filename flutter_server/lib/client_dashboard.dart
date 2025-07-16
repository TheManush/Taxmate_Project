import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_service.dart';
import 'tax_audit_page.dart';
import 'bank_loan_page.dart';
import 'financial_planning_page.dart';
import 'enhanced_financial_planning_page.dart';
import 'client_profile_page.dart';
import 'landing_page.dart';

class ClientDashboard extends StatefulWidget {
  final int clientId;
  final String fullName;
  final String email;
  final String dob;
  final String gender;
  final String userType;
  final String? clientType;
  final ApiService apiService;

  const ClientDashboard({
    super.key,
    required this.clientId,
    required this.fullName,
    required this.email,
    required this.dob,
    required this.gender,
    required this.userType,
    this.clientType,
    required this.apiService,
  });

  @override
  _ClientDashboardState createState() => _ClientDashboardState();
}

class _ClientDashboardState extends State<ClientDashboard> {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Getters to access widget properties easily
  int get clientId => widget.clientId;
  String get fullName => widget.fullName;
  String get email => widget.email;
  String get dob => widget.dob;
  String get gender => widget.gender;
  String get userType => widget.userType;
  String? get clientType => widget.clientType;
  ApiService get apiService => widget.apiService;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Dashboard', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.deepPurple[700],
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // Handle notifications
            },
          ),
        ],
      ),
      drawer: _buildClientDrawer(context),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.deepPurple[700]!, Colors.deepPurple[600]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome back, ${_getFirstName()}!",
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    clientType == 'Individual'
                        ? "Manage your personal finances with ease"
                        : "Streamline your business financial operations",
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            // Services Section
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Our Services',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Comprehensive financial solutions at your fingertips',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 25),

                  // Service Cards
                  _buildServiceCard(
                    icon: Icons.receipt_long_outlined,
                    title: 'Tax Audit Report',
                    description: 'Connect with certified CAs, send necessary documents, and get professional audit reports delivered seamlessly',
                    color: const Color(0xFF10B981),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TaxAuditPage(
                            apiService: apiService,
                            clientId: clientId,
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  _buildServiceCard(
                    icon: Icons.trending_up_outlined,
                    title: 'Financial Planning',
                    description: 'Comprehensive financial planning services to help you secure your future and achieve your life goals',
                    color: const Color(0xFF8B5CF6),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EnhancedFinancialPlanningPage(
                            apiService: apiService,
                            clientId: clientId,
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  _buildServiceCard(
                    icon: Icons.account_balance_outlined,
                    title: 'Bank Loan Service',
                    description: 'Connect with experienced loan officers who will handle all paperwork and bank negotiations for you',
                    color: const Color(0xFFF59E0B),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => BankLoanServicePage(apiService: apiService, clientId: clientId)),
                      );
                    },
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClientDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepPurple[700]!, Colors.deepPurple[600]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            accountName: Text(
              fullName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            accountEmail: Text("$email • Client"),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                _getInitials(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  context,
                  Icons.dashboard_outlined,
                  'Dashboard',
                      () => Navigator.pop(context),
                ),
                _buildDrawerItem(
                  context,
                  Icons.person_outline,
                  'My Profile',
                      () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ClientProfilePage(
                          clientId: clientId,
                          fullName: fullName,
                          email: email,
                          dob: dob,
                          gender: gender,
                          userType: userType,
                          clientType: clientType,
                          apiService: apiService,
                        ),
                      ),
                    );
                  },
                ),
                _buildDrawerItem(
                  context,
                  Icons.receipt_long_outlined,
                  'Tax Audit Service',
                      () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TaxAuditPage(
                          apiService: apiService,
                          clientId: clientId,
                        ),
                      ),
                    );
                  },
                ),
                _buildDrawerItem(
                  context,
                  Icons.trending_up_outlined,
                  'Financial Planning',
                      () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>  EnhancedFinancialPlanningPage(
                          apiService: apiService,
                          clientId: clientId,
                        ),
                      ),
                    );
                  },
                ),
                _buildDrawerItem(
                  context,
                  Icons.account_balance_outlined,
                  'Bank Loan Service',
                      () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => BankLoanServicePage(apiService: apiService, clientId: clientId)),
                    );
                  },
                ),
                const Divider(height: 30),
                _buildDrawerItem(
                  context,
                  Icons.logout_outlined,
                  'Logout',
                      () {
                    Navigator.pop(context);
                    _showLogoutDialog(context);
                  },
                  isLogout: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
      BuildContext context,
      IconData icon,
      String title,
      VoidCallback onTap, {
        bool isLogout = false,
      }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isLogout ? Colors.red : const Color(0xFF6B7280),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isLogout ? Colors.red : const Color(0xFF1F2937),
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Widget _buildServiceCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey[400],
                  size: 16,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods
  String _getFirstName() {
    return fullName.split(' ').first;
  }

  String _getInitials() {
    List<String> names = fullName.split(' ');
    String initials = '';
    for (int i = 0; i < names.length && i < 2; i++) {
      if (names[i].isNotEmpty) {
        initials += names[i][0].toUpperCase();
      }
    }
    return initials.isEmpty ? 'U' : initials;
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Logout',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();

                // Clear stored credentials
                await _secureStorage.deleteAll();

                // Navigate to LandingPage, removing all previous routes
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => LandingPage(apiBaseUrl: apiService.baseUrl),
                  ),
                      (route) => false,
                );
              },
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}
