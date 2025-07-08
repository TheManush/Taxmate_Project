import 'package:flutter/material.dart';
import 'api_service.dart';
import 'file_upload_blo.dart';

class BLOProfileFromClient extends StatelessWidget {
  final Map<String, dynamic> bloData;
  final int clientId;
  final ApiService apiService;

  const BLOProfileFromClient({
    super.key,
    required this.bloData,
    required this.clientId,
    required this.apiService,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(bloData['full_name'] ?? 'BLO Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Name: ${bloData['full_name'] ?? ''}", style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 10),
            Text("Email: ${bloData['email'] ?? ''}"),
            Text("Phone: ${bloData['phone'] ?? 'N/A'}"),
            Text("Bank Certificate Number: ${bloData['qualification'] ?? 'N/A'}"),
            Text("Experience: ${bloData['experience'] ?? 'N/A'}"),
            const SizedBox(height: 20),
            FutureBuilder<Map<String, dynamic>?>(
              future: apiService.checkExistingRequest(clientId, null, bloData['id']),
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
                            bloId: bloData['id'],
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
                            builder: (context) => FileUploadBLOPage(
                              clientId: clientId,
                              bloId: bloData['id'],
                              apiService: apiService,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700],
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Continue with BLO'),
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
