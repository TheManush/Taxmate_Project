import 'package:flutter/material.dart';
import 'api_service.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
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
                    trailing: ElevatedButton(
                      onPressed: () => _approveUser(user['id']),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      child: const Text("Approve"),
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
