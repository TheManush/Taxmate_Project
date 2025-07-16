// fp_dashboard.dart
import 'package:flutter/material.dart';
import 'api_service.dart';
import 'fp_clients_page.dart';
import 'file_download_fp.dart';
import 'fp_chat.dart';
import 'fp_contact.dart';
import 'fp_profile_page.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'landing_page.dart';

class FPDashboard extends StatefulWidget {
  final int fpId;
  final String fullName;
  final String email;
  final String dob;
  final String gender;
  final String userType;
  final String? serviceProviderType;
  final ApiService apiService;

  const FPDashboard({
    super.key,
    required this.fpId,
    required this.fullName,
    required this.email,
    required this.dob,
    required this.gender,
    required this.userType,
    this.serviceProviderType,
    required this.apiService,
  });

  @override
  _FPDashboardState createState() => _FPDashboardState();
}

class _FPDashboardState extends State<FPDashboard> {
  late Future<List<Map<String, dynamic>>> _pendingRequests;
  bool _showOnlyPending = false;
  final _storage = const FlutterSecureStorage();

  final List<Map<String, String>> dummyClients = const [
    {
      'name': 'Towhid Hridoy',
      'email': 'towhid@example.com',
      'phone': '+8801765432101',
    },
    {
      'name': 'Jakir Ali',
      'email': 'jakir@example.com',
      'phone': '+8801812345678',
    },
  ];

  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  void _fetchRequests() {
    setState(() {
      _pendingRequests = widget.apiService.fetchFPRequests(widget.fpId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Planner Dashboard'),
        backgroundColor: const Color(0xFF7C3AED),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: _showNotifications,
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(30),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF7C3AED), Color(0xFF8B5CF6)],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome, ${_getFirstName()}!",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Manage client portfolios and financial plans",
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Client Requests',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          const Text("Pending Only"),
                          Switch(
                            value: _showOnlyPending,
                            onChanged: (val) => setState(() => _showOnlyPending = val),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildRequestList(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Quick Actions',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionCard(
                          icon: Icons.people,
                          label: 'My Clients',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => FPClientsPage(
                                fpId: widget.fpId,
                                apiService: widget.apiService,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildActionCard(
                          icon: Icons.description,
                          label: 'Documents',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => FileDownloadFPPage(
                                clientId: 0,
                                fpId: widget.fpId,
                                clientName: 'Client Documents',
                                apiService: widget.apiService,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionCard(
                          icon: Icons.chat_bubble_outline,
                          label: 'Chat',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => FPChat(clients: dummyClients),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildActionCard(
                          icon: Icons.contact_phone_outlined,
                          label: 'Contact',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => FPContact(clients: dummyClients),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestList() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _pendingRequests,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) return Text('Error: ${snapshot.error}');
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text('No requests found');
        }

        final requests = _showOnlyPending
            ? snapshot.data!.where((r) => r['status'] == 'pending').toList()
            : snapshot.data!;

        return Column(
          children: requests.map((request) {
            return Card(
              child: ListTile(
                title: Text(request['client']['full_name']),
                subtitle: Text('Service: ${request['service_type']}'),
                trailing: request['status'] == 'pending'
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.check, color: Colors.green),
                            onPressed: () =>
                                _handleRequest(request['id'], 'approved'),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.red),
                            onPressed: () =>
                                _handleRequest(request['id'], 'rejected'),
                          ),
                        ],
                      )
                    : null,
                onTap: () => _viewClientDetails(request['client']['id']),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, size: 32, color: const Color(0xFF7C3AED)),
              const SizedBox(height: 8),
              Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF7C3AED), Color(0xFF8B5CF6)],
              ),
            ),
            accountName: Text(widget.fullName),
            accountEmail: Text(widget.email),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                _getInitials(),
                style: const TextStyle(color: Color(0xFF7C3AED)),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('My Clients'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FPClientsPage(
                    fpId: widget.fpId,
                    apiService: widget.apiService,
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FPProfilePage(
                    fpId: widget.fpId,
                    fullName: widget.fullName,
                    email: widget.email,
                    dob: widget.dob,
                    gender: widget.gender,
                    userType: widget.userType,
                    serviceProviderType: widget.serviceProviderType,
                    apiService: widget.apiService,
                  ),
                ),
              );
            },
          ),
          const Spacer(),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () => _logout(context),
          ),
        ],
      ),
    );
  }

  String _getFirstName() => widget.fullName.split(' ').first;

  String _getInitials() {
    final names = widget.fullName.split(' ');
    return names.length > 1 ? '${names[0][0]}${names[1][0]}' : names[0][0];
  }

  Future<void> _handleRequest(int requestId, String status) async {
    try {
      await widget.apiService.updateFPRequestStatus(requestId, status);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Request $status')),
      );
      _fetchRequests();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _viewClientDetails(int clientId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FPClientsPage(
          fpId: widget.fpId,
          apiService: widget.apiService,
          focusedClientId: clientId,
        ),
      ),
    );
  }

  void _showNotifications() {
    // Notification logic placeholder
  }

  Future<void> _logout(BuildContext context) async {
    await _storage.deleteAll();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => LandingPage(apiBaseUrl: widget.apiService.baseUrl),
      ),
      (route) => false,
    );
  }
}
