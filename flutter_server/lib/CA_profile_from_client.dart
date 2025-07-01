import 'package:flutter/material.dart';
import 'api_service.dart';

class CAprofile extends StatelessWidget {
  final Map<String, dynamic> caData;
  final int clientId; // NEW
  final ApiService apiService; // NEW
  const CAprofile ({super.key, required this.caData});

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
            ElevatedButton(
              onPressed: () async {
                try {
                  await apiService.sendServiceRequest(
                    clientId: clientId,
                    caId: caData['id'],
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Request sent successfully")),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Failed: ${e.toString()}")),
                  );
                }
              },
              child: const Text('Request Service'),
            ),
          ],
        ),
      ),
    );
  }
}
