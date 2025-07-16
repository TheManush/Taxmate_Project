import 'package:flutter/material.dart';
import 'api_service.dart';
import 'dart:convert';

class BLOProfilePage extends StatefulWidget {
  final int officerId;
  final String fullName;
  final String email;
  final String dob;
  final String gender;
  final String userType;
  final String? serviceProviderType;
  final ApiService apiService;

  const BLOProfilePage({
    super.key,
    required this.officerId,
    required this.fullName,
    required this.email,
    required this.dob,
    required this.gender,
    required this.userType,
    this.serviceProviderType,
    required this.apiService,
  });

  @override
  State<BLOProfilePage> createState() => _BLOProfilePageState();
}

class _BLOProfilePageState extends State<BLOProfilePage> {
  Map<String, dynamic>? profileData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  Future<void> _fetchProfileData() async {
    try {
      // Fetch BLO data from the bank_loan_officers endpoint
      print('Fetching profile data for officer ID: ${widget.officerId}');
      final response = await widget.apiService.get("bank_loan_officers/");
      print('Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final List<dynamic> bloList = json.decode(response.body);
        print('Total BLOs found: ${bloList.length}');
        
        // Find the current BLO in the list
        final currentBLO = bloList.firstWhere(
          (blo) => blo['id'] == widget.officerId,
          orElse: () => null,
        );
        
        print('Current BLO data: $currentBLO');
        setState(() {
          profileData = currentBLO;
          isLoading = false;
        });
      } else {
        print('Failed to fetch profile data: ${response.statusCode}');
        setState(() {
          profileData = null;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching profile data: $e');
      setState(() {
        profileData = null;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: Colors.purple[700],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.purple[700],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  children: [
                    // Profile Avatar
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.white,
                      child: Text(
                        widget.fullName.substring(0, 1).toUpperCase(),
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple[700],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Full Name
                    Text(
                      widget.fullName,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Bank Loan Officer',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Profile Information Cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  if (isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else
                    // Professional Information Card
                    _buildInfoCard(
                      icon: Icons.work,
                      title: 'Professional Information',
                      children: [
                        _buildInfoRow(Icons.email, 'Email', widget.email),
                        const SizedBox(height: 12),
                        _buildInfoRow(Icons.badge, 'User Type', widget.userType),
                        const SizedBox(height: 12),
                        _buildInfoRow(Icons.business, 'Service Provider Type', widget.serviceProviderType ?? 'Bank Loan Officer'),
                        const SizedBox(height: 12),
                        _buildInfoRow(Icons.timeline, 'Years of Experience', profileData?['experience'] ?? 'N/A'),
                        const SizedBox(height: 12),
                        _buildInfoRow(Icons.verified, 'Qualification', profileData?['qualification'] ?? 'N/A'),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Account Status Card
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Icon(Icons.verified_user, color: Colors.green, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Status',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.green[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    'Account Verified',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.purple[700], size: 24),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[600], size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
