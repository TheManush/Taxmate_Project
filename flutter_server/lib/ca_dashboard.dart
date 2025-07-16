
import 'package:flutter/material.dart';
import 'api_service.dart';
import 'client_page_from_CA.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'landing_page.dart';
import 'ca_profile_page.dart';

class CAdashboard extends StatefulWidget {
  final int caId;
  final String fullName;
  final String email;
  final String dob;
  final String gender;
  final String userType;
  final String? serviceProviderType;
  final ApiService apiService;

  const CAdashboard({
    super.key,
    required this.caId,
    required this.fullName,
    required this.email,
    required this.dob,
    required this.gender,
    required this.userType,
    this.serviceProviderType,
    required this.apiService,
  });

  @override
  _CAdashboardState createState() => _CAdashboardState();
}

class _CAdashboardState extends State<CAdashboard> {
  late Future<List<Map<String, dynamic>>> _pendingRequests;
  bool _showOnlyPending = false;

  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  void _fetchRequests() {
    setState(() {
      _pendingRequests = widget.apiService.fetchCARequests(widget.caId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            '${widget.serviceProviderType ?? 'Service Provider'} Dashboard'),
        backgroundColor: Colors.deepPurple[500],
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {},
          ),
        ],
      ),
      drawer: _buildCADrawer(context),
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
                  colors: [Colors.deepPurple[500]!, Colors.deepPurple[400]!],
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

            // Main Content - Removed Profile Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          'Client Requests',
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

  Widget _buildRequestList() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _pendingRequests,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text('No pending requests.');
        }

        List<Map<String, dynamic>> requests = List.from(snapshot.data!);
        if (_showOnlyPending) {
          requests = requests.where((req) => req['status'] == 'pending').toList();
        }
        if (requests.isEmpty) {
          return const Text('No matching requests to display.');
        }

        return Column(
          children: requests.map((req) {
            return Card(
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 8),
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
                          backgroundColor: Colors.deepPurple[500],
                          child: Text(
                            (req['client']['full_name'] ?? 'U').substring(0, 1).toUpperCase(),
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
                              onPressed: () async {
                                await widget.apiService.updateRequestStatus(
                                    req['id'], 'approved');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Request accepted')),
                                );
                                _fetchRequests();
                              },
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
                              onPressed: () async {
                                await widget.apiService.updateRequestStatus(
                                    req['id'], 'rejected');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Request rejected')),
                                );
                                _fetchRequests();
                              },
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
      },
    );
  }

  String _getFirstName() {
    return widget.fullName.split(' ').first;
  }

  Widget _buildCADrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepPurple[500]!, Colors.deepPurple[400]!],
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
                  color: Colors.deepPurple[500],
                ),
              ),
            ),
          ),

          // 👉 Pending Requests (current page)
          ListTile(
            leading: const Icon(Icons.pending_actions),
            title: const Text("Pending Requests", style: TextStyle(fontWeight: FontWeight.bold)),
            selected: true, // Highlights the current page
            onTap: () {
              Navigator.pop(context); // Just close drawer
            },
          ),

          // 👉 Clients (navigates to new page)
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text("Clients", style: TextStyle(fontWeight: FontWeight.bold)),
            onTap: () {
              Navigator.of(context).pop(); // Close the drawer
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ClientsPage(
                    caId: widget.caId,
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
                final storage = FlutterSecureStorage();
                await storage.deleteAll(); // Clear all saved login info
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
}
