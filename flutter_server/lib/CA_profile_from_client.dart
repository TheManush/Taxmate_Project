import 'package:flutter/material.dart';
import 'api_service.dart';
import 'blank_page.dart';

class CA_profile extends StatelessWidget {
  final Map<String, dynamic> caData;
  final int clientId; // NEW
  final ApiService apiService; // NEW

  const CA_profile({
    super.key,
    required this.caData,
    required this.clientId,
    required this.apiService,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(caData['full_name'] ?? 'Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Name: ${caData['full_name'] ?? ''}", style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 10),
            Text("Email: ${caData['email'] ?? ''}"),
            Text("Phone: ${caData['phone'] ?? 'N/A'}"),
            Text("CA Certificate Number: ${caData['qualification'] ?? 'N/A'}"),
            Text("Experience: ${caData['experience'] ?? 'N/A'}"),
            const SizedBox(height: 20),
            FutureBuilder<Map<String, dynamic>?>(
              future: apiService.checkExistingRequest(clientId, caData['id']),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  final request = snapshot.data;

                  if (request == null) {
                    return ElevatedButton(
                      onPressed: () async {
                        try {
                          await apiService.sendServiceRequest(
                            clientId: clientId,
                            caId: caData['id'],
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Request sent successfully")),
                          );
                          (context as Element).reassemble(); // refresh widget
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Failed: ${e.toString()}")),
                          );
                        }
                      },
                      child: const Text('Request Service'),
                    );
                  }

                  if (request['status'] == 'pending') {
                    return const ElevatedButton(
                      onPressed: null,
                      child: Text('Request Pending'),
                    );
                  }

                  if (request['status'] == 'approved') {
                    return ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const BlankPageForNow(),
                          ),
                        );
                      },
                      child: const Text('Continue with CA'),
                    );
                  }

                  // If rejected or unknown status, hide
                  return const SizedBox.shrink();
                }
              },
            )

          ],
        ),
      ),
    );
  }
}
