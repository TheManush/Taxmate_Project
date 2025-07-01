import 'package:flutter/material.dart';
import 'api_service.dart';

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
        title: Text('${widget.serviceProviderType ?? 'Service Provider'} Dashboard'),
        backgroundColor: Colors.green[800],
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Client Requests',
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
                  _buildRequestList(), // Added request list widget
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
              child: ListTile(
                title: Text('Client: ${req['client']['full_name']}'),
                subtitle: Text('Status: ${req['status']}'),
                trailing: req['status'] == 'pending'
                    ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check, color: Colors.green),
                      onPressed: () async {
                        await widget.apiService.updateRequestStatus(req['id'], 'approved');
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Request accepted')),
                        );
                        _fetchRequests();
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () async {
                        await widget.apiService.updateRequestStatus(req['id'], 'rejected');
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Request rejected')),
                        );
                        _fetchRequests();
                      },
                    ),
                  ],
                )
                    : null,
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
      child: ListView(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green[800]!, Colors.green[600]!],
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
}