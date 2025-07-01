import 'package:flutter/material.dart';
import 'api_service.dart';
import 'CA_profile_from_client.dart';

class TaxAuditPage extends StatefulWidget {
  final ApiService apiService;
  final int clientId;
  const TaxAuditPage({super.key, required this.apiService,required this.clientId});

  @override
  State<TaxAuditPage> createState() => _TaxAuditPageState();
}

class _TaxAuditPageState extends State<TaxAuditPage> {
  late Future<List<Map<String, dynamic>>> _futureCAs;

  @override
  void initState() {
    super.initState();
    _futureCAs = widget.apiService.getCharteredAccountants();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chartered Accountants')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _futureCAs,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.data == null || snapshot.data!.isEmpty) {
            return const Center(child: Text('No Chartered Accountants found.'));
          } else {
            final caList = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: caList.length,
              itemBuilder: (context, index) {
                final ca = caList[index];
                return GestureDetector(
                  onTap: () {
                    // Navigate to profile page (to be implemented)
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CA_profile(
                          caData: ca,
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
                            ca['full_name'] ?? 'Unknown',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(ca['email'] ?? 'No Email'),
                          const SizedBox(height: 6),
                          Text("Qualification: ${ca['qualification'] ?? 'N/A'}"),
                          const SizedBox(height: 6),
                          Text("Experience: ${ca['experience'] ?? 'N/A'}"),
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
