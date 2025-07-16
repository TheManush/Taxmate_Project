import 'package:flutter/material.dart';
import 'api_service.dart';
import 'landing_page.dart';

class AdminDashboard extends StatefulWidget {
  final int adminId;
  final String fullName;
  final String email;
  final String dob;
  final String gender;
  final String userType;
  final String? serviceProviderType;
  final ApiService apiService;

  const AdminDashboard({
    super.key,
    required this.adminId,
    required this.fullName,
    required this.email,
    required this.dob,
    required this.gender,
    required this.userType,
    required this.serviceProviderType,
    required this.apiService,
  });

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  late Future<List<dynamic>> _pendingProviders;

  @override
  void initState() {
    super.initState();
    _pendingProviders = widget.apiService.fetchPendingServiceProviders();
  }

  void _approveUser(int userId) async {
    try {
      await widget.apiService.approveServiceProvider(userId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User approved successfully')),
      );
      setState(() {
        _pendingProviders = widget.apiService.fetchPendingServiceProviders();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Approval failed: ${e.toString()}')),
      );
    }
  }

  void _rejectUser(int userId) async {
    try {
      await widget.apiService.rejectServiceProvider(userId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User rejected successfully')),
      );
      setState(() {
        _pendingProviders = widget.apiService.fetchPendingServiceProviders();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Rejection failed: ${e.toString()}')),
      );
    }
  }

  void _goBack(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => LandingPage(apiBaseUrl: widget.apiService.baseUrl),
      ),
      (route) => false,
    );
  }

  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Logout'),
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => LandingPage(apiBaseUrl: widget.apiService.baseUrl),
                  ),
                  (route) => false,
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => _goBack(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<dynamic>>(
          future: _pendingProviders,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.data!.isEmpty) {
              return const Center(child: Text('No pending service providers'));
            }

            final providers = snapshot.data!;
            return ListView.builder(
              itemCount: providers.length,
              itemBuilder: (context, index) {
                final user = providers[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: Text(user['full_name']),
                    subtitle: Text('${user['email']} • ${user['service_provider_type']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton(
                          onPressed: () => _approveUser(user['id']),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                          child: const Text("Approve"),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () => _rejectUser(user['id']),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                          child: const Text("Reject"),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
