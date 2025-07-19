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
    final firstName = widget.fullName.split(' ').first;
    return firstName.isNotEmpty ? firstName : 'User';
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
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    // Client Avatar
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.deepPurple[600],
                      child: Text(
                        (req['client']['full_name']?.isNotEmpty == true) 
                            ? req['client']['full_name'].substring(0, 1).toUpperCase()
                            : 'C',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Client Name and Status
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            req['client']['full_name'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            req['client']['email'] ?? '',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Status
                    Expanded(
                      flex: 1,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: req['status'] == 'pending'
                              ? Colors.orange[100]
                              : req['status'] == 'approved'
                                  ? Colors.green[100]
                                  : Colors.red[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          req['status'].toString().toUpperCase(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: req['status'] == 'pending'
                                ? Colors.orange[700]
                                : req['status'] == 'approved'
                                    ? Colors.green[700]
                                    : Colors.red[700],
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ),
                  ],
                ),
                // Action Buttons for Pending Requests
                if (req['status'] == 'pending') ...[
                  const SizedBox(height: 12),
                  const Divider(),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _handleRequestAction(req['id'], 'approved'),
                          icon: const Icon(Icons.check, size: 16),
                          label: const Text('Accept', style: TextStyle(fontSize: 12)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[600],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _handleRequestAction(req['id'], 'rejected'),
                          icon: const Icon(Icons.close, size: 16),
                          label: const Text('Reject', style: TextStyle(fontSize: 12)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[600],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
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
                colors: [Colors.deepPurple[700]!, Colors.deepPurple[500]!],
              ),
            ),
            accountName: Text(widget.fullName),
            accountEmail: Text(widget.email),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                _getFirstName().isNotEmpty ? _getFirstName()[0] : 'F',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.deepPurple[700],
                ),
              ),
            ),
          ),

          // Profile option
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text("My Profile", style: TextStyle(fontWeight: FontWeight.bold)),
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
            title: const Text("Service Requests", style: TextStyle(fontWeight: FontWeight.bold)),
            selected: true,
            onTap: () {
              Navigator.pop(context);
            },
          ),

          // Clients page
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text("Approved Clients", style: TextStyle(fontWeight: FontWeight.bold)),
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

          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              "Logout",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
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
        backgroundColor: Colors.deepPurple[700],
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
                  colors: [Colors.deepPurple[700]!, Colors.deepPurple[500]!],
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
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          'Service Requests',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text("Only Pending", 
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Transform.scale(
                              scale: 0.8,
                              child: Switch(
                                value: _showOnlyPending,
                                onChanged: (val) {
                                  setState(() {
                                    _showOnlyPending = val;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
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
