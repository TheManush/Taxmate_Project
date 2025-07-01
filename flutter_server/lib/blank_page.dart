import 'package:flutter/material.dart';
import 'api_service.dart';

class CAProfile extends StatelessWidget {
  final Map<String, dynamic> caData;
  final int clientId;
  final ApiService apiService;

  const CAProfile({
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
            Text("Name: ${caData['full_name'] ?? ''}",
                style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 10),
            Text("Email: ${caData['email'] ?? ''}"),
            Text("Phone: ${caData['phone'] ?? 'N/A'}"),
            Text("CA Certificate Number: ${caData['qualification'] ?? 'N/A'}"),
            Text("Experience: ${caData['experience'] ?? 'N/A'}"),
            const SizedBox(height: 20),

            // Replace the old ElevatedButton with FutureBuilder
            FutureBuilder<Map<String, dynamic>?>(
              future: apiService.checkExistingRequest(clientId, caData['id']),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error checking request status');
                } else {
                  final request = snapshot.data;

                  // If no request found, show "Request Service"
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
                          // Trigger rebuild to update the button state
                          if (context.mounted) {
                            (context as Element).markNeedsBuild();
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Failed: ${e.toString()}")),
                            );
                          }
                        }
                      },
                      child: const Text('Request Service'),
                    );
                  }

                  // If status is 'pending', disable button
                  if (request['status'] == 'pending') {
                    return const ElevatedButton(
                      onPressed: null,
                      child: Text('Request Pending'),
                    );
                  }

                  // If status is 'approved', show new button
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

                  // If status is 'rejected', hide widget entirely
                  return const SizedBox.shrink();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Temporary placeholder page
class BlankPageForNow extends StatelessWidget {
  const BlankPageForNow({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Service Approved')),
      body: const Center(child: Text('Service approved! Connect with your CA here.')),
    );
  }
}