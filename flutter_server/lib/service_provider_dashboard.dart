import 'package:flutter/material.dart';
import 'api_service.dart';

class ServiceProviderDashboard extends StatelessWidget {
  final String fullName;
  final String email;
  final String dob;
  final String gender;
  final String userType;
  final String? serviceProviderType;
  final ApiService apiService;

  const ServiceProviderDashboard({
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
            onPressed: () {
              // Handle notifications
            },
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

            // Stats Cards
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Active Clients',
                      '12',
                      Icons.people,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _buildStatCard(
                      'Pending Requests',
                      '5',
                      Icons.pending_actions,
                      Colors.orange,
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

                  // Recent Client Requests
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

  Widget _buildServiceProviderDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green[800]!, Colors.green[600]!],
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
            accountEmail: Text("$email • ${serviceProviderType ?? 'Service Provider'}"),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                _getInitials(),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800],
                ),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('My Profile'),
            onTap: () {
              Navigator.pop(context);
              _showProfileDialog(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('My Clients'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to clients list
            },
          ),
          ListTile(
            leading: const Icon(Icons.assignment),
            title: const Text('Service Requests'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to service requests
            },
          ),
          ListTile(
            leading: const Icon(Icons.schedule),
            title: const Text('My Schedule'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to schedule
            },
          ),
          ListTile(
            leading: const Icon(Icons.attach_money),
            title: const Text('Earnings'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to earnings
            },
          ),
          ListTile(
            leading: const Icon(Icons.star),
            title: const Text('Reviews & Ratings'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to reviews
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Help & Support'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              _showLogoutDialog(context);
            },
          ),
        ],
      ),
    );
  }

  List<Widget> _buildQuickActions() {
    if (serviceProviderType == 'Chartered Accountant') {
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
    } else if (serviceProviderType == 'Financial Planner') {
      return [
        _buildQuickActionCard(
          icon: Icons.trending_up,
          label: 'Investment Planning',
          color: Colors.blue,
          onTap: () {},
        ),
        _buildQuickActionCard(
          icon: Icons.savings,
          label: 'Retirement Planning',
          color: Colors.green,
          onTap: () {},
        ),
        _buildQuickActionCard(
          icon: Icons.security,
          label: 'Insurance Planning',
          color: Colors.orange,
          onTap: () {},
        ),
        _buildQuickActionCard(
          icon: Icons.pie_chart,
          label: 'Portfolio Review',
          color: Colors.purple,
          onTap: () {},
        ),
      ];
    } else if (serviceProviderType == 'Bank Loan Officer') {
      return [
        _buildQuickActionCard(
          icon: Icons.home,
          label: 'Home Loans',
          color: Colors.blue,
          onTap: () {},
        ),
        _buildQuickActionCard(
          icon: Icons.business,
          label: 'Business Loans',
          color: Colors.green,
          onTap: () {},
        ),
        _buildQuickActionCard(
          icon: Icons.credit_card,
          label: 'Personal Loans',
          color: Colors.orange,
          onTap: () {},
        ),
        _buildQuickActionCard(
          icon: Icons.assessment,
          label: 'Loan Assessment',
          color: Colors.purple,
          onTap: () {},
        ),
      ];
    } else {
      return [
        _buildQuickActionCard(
          icon: Icons.work,
          label: 'Services',
          color: Colors.blue,
          onTap: () {},
        ),
        _buildQuickActionCard(
          icon: Icons.people,
          label: 'Clients',
          color: Colors.green,
          onTap: () {},
        ),
      ];
    }
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 30, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
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
          // Navigate to request details
        },
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

  void _showProfileDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Profile Information'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileRow('Full Name', fullName),
              _buildProfileRow('Email', email),
              _buildProfileRow('User Type', 'Service Provider'),
              if (serviceProviderType != null)
                _buildProfileRow('Service Type', serviceProviderType!),
              if (dob.isNotEmpty) _buildProfileRow('Date of Birth', dob),
              if (gender.isNotEmpty) _buildProfileRow('Gender', gender),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Navigate to edit profile page
              },
              child: const Text('Edit Profile'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProfileRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pop(context); // Go back to login
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}