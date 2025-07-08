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
      appBar: AppBar(title: const Text('Bank Loan Officers')),
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
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            blo['full_name'] ?? 'Unknown',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(blo['email'] ?? 'No Email'),
                          const SizedBox(height: 6),
                          Text("Qualification: ${blo['qualification'] ?? 'N/A'}"),
                          const SizedBox(height: 6),
                          Text("Experience: ${blo['experience'] ?? 'N/A'}"),
                        ],
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