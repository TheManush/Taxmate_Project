import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_service.dart';
import 'client_page_from_FP.dart';
import 'landing_page.dart';
import 'fp_profile_page.dart';
import 'fp_clients_page.dart';

class FinancialPlannerDashboard extends StatefulWidget {
  final int plannerId;
  final String fullName;
  final String email;
  final String dob;
  final String gender;
  final String userType;
  final String? serviceProviderType;
  final ApiService apiService;

  const FinancialPlannerDashboard({
    super.key,
    required this.plannerId,
    required this.fullName,
    required this.email,
    required this.dob,
    required this.gender,
    required this.userType,
    required this.serviceProviderType,
    required this.apiService,
  });

  @override
  State<FinancialPlannerDashboard> createState() => _FinancialPlannerDashboardState();
}

class _FinancialPlannerDashboardState extends State<FinancialPlannerDashboard> {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  List<Map<String, dynamic>> serviceRequests = [];
  List<Map<String, dynamic>> approvedClients = [];
  bool isLoading = true;
  bool _showOnlyPending = false;


  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    try {
      await Future.wait([
        _loadServiceRequests(),
        _loadApprovedClients(),
      ]);
    } catch (e) {
      print('Error loading data: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _loadServiceRequests() async {
    try {
      final requests = await widget.apiService.getFinancialPlannerRequests(widget.plannerId);
      setState(() {
        serviceRequests = requests;
      });
    } catch (e) {
      print('Error loading service requests: $e');
    }
  }

  Future<void> _loadApprovedClients() async {
    try {
      final clients = await widget.apiService.getApprovedClientsForFP(widget.plannerId);
      setState(() {
        approvedClients = clients;
      });
    } catch (e) {
      print('Error loading approved clients: $e');
    }
  }

  Future<void> _handleRequestAction(int requestId, String action) async {
    try {
      await widget.apiService.updateServiceRequestStatus(requestId, action);
      await _loadData(); // Refresh data
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Request ${action}d successfully'),
          backgroundColor: action == 'approved' ? Colors.green : Colors.orange,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating request: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
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
                    builder: (context) => LandingPage(apiBaseUrl: widget.apiService.baseUrl),
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

  String _getFirstName() {
    return widget.fullName.split(' ').first;
  }

  Widget _buildRequestList() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    List<Map<String, dynamic>> requests = List.from(serviceRequests);
    if (_showOnlyPending) {
      requests = requests.where((req) => req['status'] == 'pending').toList();
    }

    if (requests.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.request_page_outlined,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No matching requests to display.',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: requests.map((req) {
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.purple[100],
              child: Text(
                req['client']['full_name'][0].toUpperCase(),
                style: TextStyle(
                  color: Colors.purple[800],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text('Client: ${req['client']['full_name']}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Status: ${req['status']}'),
                Text('Service: Financial Planning'),
              ],
            ),
            trailing: req['status'] == 'pending'
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check, color: Colors.green),
                        onPressed: () => _handleRequestAction(req['id'], 'approved'),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () => _handleRequestAction(req['id'], 'rejected'),
                      ),
                    ],
                  )
                : Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(req['status']),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      req['status'].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFPDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple[800]!, Colors.purple[600]!],
              ),
            ),
            accountName: Text(widget.fullName),
            accountEmail: Text(widget.email),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                _getFirstName()[0],
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.purple[800],
                ),
              ),
            ),
          ),

          // Profile option
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text("My Profile"),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FPProfilePage(
                    fpId: widget.plannerId,
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

          // Service Requests (current page)
          ListTile(
            leading: const Icon(Icons.pending_actions),
            title: const Text("Service Requests"),
            selected: true,
            onTap: () {
              Navigator.pop(context);
            },
          ),

          // Clients page
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text("Approved Clients"),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FPClientsPage(
                    fpId: widget.plannerId,
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
            title: const Text(
              "Logout",
              style: TextStyle(color: Colors.red),
            ),
            onTap: () async {
              final shouldLogout = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      child: const Text('Cancel'),
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                    TextButton(
                      child: const Text('Logout',
                          style: TextStyle(color: Colors.red)),
                      onPressed: () => Navigator.of(context).pop(true),
                    ),
                  ],
                ),
              );
              if (shouldLogout == true) {
                await _secureStorage.deleteAll();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) =>
                        LandingPage(apiBaseUrl: widget.apiService.baseUrl),
                  ),
                  (Route<dynamic> route) => false,
                );
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.serviceProviderType ?? 'Financial Planner'} Dashboard'),
        backgroundColor: Colors.purple[800],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {},
          ),
        ],
      ),
      drawer: _buildFPDrawer(context),
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
                  colors: [Colors.purple[800]!, Colors.purple[600]!],
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
                    "Manage your clients and financial planning services",
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Service Requests',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      Row(
                        children: [
                          const Text("Only Pending"),
                          Switch(
                            value: _showOnlyPending,
                            onChanged: (val) {
                              setState(() {
                                _showOnlyPending = val;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _buildRequestList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
