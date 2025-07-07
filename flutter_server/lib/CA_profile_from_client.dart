import 'package:flutter/material.dart';
import 'api_service.dart';
import 'file_upload.dart' ;
import 'package:url_launcher/url_launcher.dart';


class CA_profile extends StatefulWidget {
  final Map<String, dynamic> caData;
  final int clientId;
  final ApiService apiService;

  const CA_profile({
    Key? key,
    required this.caData,
    required this.clientId,
    required this.apiService,
  }) : super(key: key);

  @override
  State<CA_profile> createState() => _CA_profileState();
}

class _CA_profileState extends State<CA_profile> {
  late Future<Map<String, dynamic>?> _requestFuture;

  @override
  void initState() {
    super.initState();
    _requestFuture = widget.apiService.checkExistingRequest(widget.clientId, widget.caData['id']);
  }

  void refreshRequestStatus() {
    setState(() {
      _requestFuture = widget.apiService.checkExistingRequest(widget.clientId, widget.caData['id']);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.caData['full_name'] ?? 'Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Name: ${widget.caData['full_name'] ?? ''}", style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 10),
            Text("Email: ${widget.caData['email'] ?? ''}"),
            Text("Phone: ${widget.caData['phone'] ?? 'N/A'}"),
            Text("CA Certificate Number: ${widget.caData['qualification'] ?? 'N/A'}"),
            Text("Experience: ${widget.caData['experience'] ?? 'N/A'}"),
            const SizedBox(height: 20),

            // ⬇️ Use FutureBuilder tied to requestFuture
            FutureBuilder<Map<String, dynamic>?>(
              future: _requestFuture,
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
                          await widget.apiService.sendServiceRequest(
                            clientId: widget.clientId,
                            caId: widget.caData['id'],
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Request sent successfully")),
                          );
                          refreshRequestStatus(); // ✅ Re-fetch and rebuild
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
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => FileUploadPage(
                                  clientId: widget.clientId,
                                  caId: widget.caData['id'],
                                  apiService: widget.apiService,
                                ),
                              ),
                            );
                          },
                          child: const Text('Continue with CA'),
                        ),
                        const SizedBox(height: 10),
                        FutureBuilder<bool>(
                          future: widget.apiService.checkAuditReportExists(widget.clientId, widget.caData['id']),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            } else if (snapshot.hasError || snapshot.data == false) {
                              return const SizedBox.shrink();
                            } else {
                              return ElevatedButton.icon(
                                icon: Icon(Icons.download),
                                label: Text('Download Audit Report'),
                                onPressed: () async {
                                  try {
                                    final url = await widget.apiService.getDownloadUrl(
                                      widget.clientId,
                                      widget.caData['id'],
                                      'Audit Report',
                                    );
                                    final uri = Uri.parse(url);
                                    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);

                                    if (!launched) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Could not open audit report')),
                                      );
                                    }
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Audit Report not available')),
                                    );
                                  }
                                },
                              );
                            }
                          },
                        ),
                      ],
                    );
                  }

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