import 'package:flutter/material.dart';
import 'api_service.dart';

class CA_dashboard extends StatelessWidget {
  final String fullName;
  final String email;
  final String dob;
  final String gender;
  final String userType;
  final String? serviceProviderType;
  final ApiService apiService;

  const CAdashboard({
    super.key,
    required this.fullName,
    required this.email,
    required this.dob,
    required this.gender,
    required this.userType,
    this.serviceProviderType,
    required this.apiService,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${serviceProviderType ?? 'Service Provider'} Dashboard'),
        backgroundColor: Colors.green[800],
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {},
          ),
        ],
      ),
      drawer: _buildServiceProviderDrawer(context),
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
                  colors: [Colors.green[800]!, Colors.green[600]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome, ${_getFirstName()}!",
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Manage your clients and services",
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            // Main Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    children: _buildQuickActions(),
                  ),

                  const SizedBox(height: 30),

                  const Text(
                    'Recent Client Requests',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildClientRequestCard(
                    'John Doe',
                    'Tax Filing Assistance',
                    'Submitted 2 hours ago',
                    'New',
                    Colors.green,
                  ),
                  const SizedBox(height: 10),
                  _buildClientRequestCard(
                    'ABC Corp',
                    'Financial Planning',
                    'Submitted yesterday',
                    'In Progress',
                    Colors.orange,
                  ),
                  const SizedBox(height: 10),
                  _buildClientRequestCard(
                    'Jane Smith',
                    'Loan Application Review',
                    'Submitted 3 days ago',
                    'Completed',
                    Colors.blue,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  String _getFirstName() {
    return fullName.split(' ').first;
  }
  Widget _buildQuickActionCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 10),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  List<Widget> _buildQuickActions() {
    return [
      _buildQuickActionCard(
        icon: Icons.receipt_long,
        label: 'Tax Returns',
        color: Colors.blue,
        onTap: () {},
      ),
      _buildQuickActionCard(
        icon: Icons.account_balance,
        label: 'Audit Services',
        color: Colors.green,
        onTap: () {},
      ),
      _buildQuickActionCard(
        icon: Icons.calculate,
        label: 'Bookkeeping',
        color: Colors.orange,
        onTap: () {},
      ),
      _buildQuickActionCard(
        icon: Icons.business,
        label: 'Compliance',
        color: Colors.purple,
        onTap: () {},
      ),
    ];
  }
  Widget _buildClientRequestCard(
      String clientName,
      String serviceType,
      String timeStamp,
      String status,
      Color statusColor,
      ) {
    return Card(
      elevation: 1,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.1),
          child: Text(
            clientName[0].toUpperCase(),
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(clientName, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(serviceType),
            Text(timeStamp, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            status,
            style: TextStyle(
              color: statusColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        onTap: () {
          // Future: Show request details
        },
      ),
    );
  }
  Widget _buildServiceProviderDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green[800]!, Colors.green[600]!],
              ),
            ),
            accountName: Text(fullName),
            accountEmail: Text(email),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                _getFirstName()[0],
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.green[800],
                ),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("Logout"),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Return to login
            },
          ),
        ],
      ),
    );
  }

// Remaining methods unchanged (drawer, quick actions, dialogs, etc.)
// ...
}
