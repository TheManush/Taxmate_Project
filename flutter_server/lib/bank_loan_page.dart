import 'package:flutter/material.dart';
import 'dart:convert';
import 'api_service.dart';
import 'BLO_profile_from_client.dart';

class BankLoanServicePage extends StatefulWidget {
  final int clientId;
  final ApiService apiService;

  const BankLoanServicePage({
    Key? key,
    required this.clientId,
    required this.apiService,
  }) : super(key: key);

  @override
  State<BankLoanServicePage> createState() => _BankLoanServicePageState();
}

class _BankLoanServicePageState extends State<BankLoanServicePage> {
  late Future<List<Map<String, dynamic>>> _futureBLOs;

  @override
  void initState() {
    super.initState();
    _futureBLOs = widget.apiService.get("bank_loan_officers").then((res) {
      if (res.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(res.body));
      } else {
        throw Exception("Failed to load officers");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bank Loan Officers'),
        backgroundColor: Colors.deepPurple[700],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _futureBLOs,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.data == null || snapshot.data!.isEmpty) {
            return const Center(child: Text('No Bank Loan Officers found.'));
          } else {
            final bloList = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: bloList.length,
              itemBuilder: (context, index) {
                final blo = bloList[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BLOProfileFromClient(
                          bloData: blo,
                          clientId: widget.clientId,
                          apiService: widget.apiService,
                        ),
                      ),
                    );
                  },
                  child: Card(
                    elevation: 6,
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white,
                            Colors.deepPurple[50]!,
                          ],
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            // Profile Header Row
                            Row(
                              children: [
                                // Profile Avatar
                                CircleAvatar(
                                  radius: 30,
                                  backgroundColor: Colors.deepPurple[700],
                                  child: Text(
                                    (blo['full_name'] ?? 'U').substring(0, 1).toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Name and Email
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        blo['full_name'] ?? 'Unknown',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey[800],
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.email,
                                            size: 16,
                                            color: Colors.grey[600],
                                          ),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              blo['email'] ?? 'No Email',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[600],
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                // Arrow Icon
                                Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.deepPurple[700],
                                  size: 20,
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Qualification and Experience Cards
                            Row(
                              children: [
                                // Qualification Card
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.green[100],
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.green[200]!,
                                        width: 1,
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.verified_user,
                                          color: Colors.green[700],
                                          size: 20,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Qualification',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.green[700],
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          blo['qualification'] ?? 'N/A',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey[700],
                                          ),
                                          textAlign: TextAlign.center,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Experience Card
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.orange[100],
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.orange[200]!,
                                        width: 1,
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.work_history,
                                          color: Colors.orange[700],
                                          size: 20,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Experience',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.orange[700],
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          blo['experience'] ?? 'N/A',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey[700],
                                          ),
                                          textAlign: TextAlign.center,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}