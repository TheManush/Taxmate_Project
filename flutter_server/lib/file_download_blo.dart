import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'api_service.dart';
import 'loan_filing_page.dart';

class FileDownloadBLOPage extends StatelessWidget {
  final int clientId;
  final int bloId;
  final String clientName;
  final String clientEmail;
  final ApiService apiService;

  FileDownloadBLOPage({
    Key? key,
    required this.clientId,
    required this.bloId,
    required this.clientName,
    required this.clientEmail,
    required this.apiService,
  }) : super(key: key);

  final List<String> docTypes = [
    'TIN Certificate',
    'NID',
    'Salary Certificate',
    'Bank Statement',
  ];

  Future<void> downloadFile(BuildContext context, String docType) async {
    try {
      final url = await apiService.getDownloadUrlForBLO(clientId, bloId, docType);
      print("Download URL: $url");

      final uri = Uri.parse(url);
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);

      if (!launched) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch file')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error downloading $docType: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text("Files from $clientName"),
        backgroundColor: Colors.deepPurple[800],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Client Info Header
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.deepPurple[800],
                        child: Text(
                          clientName.substring(0, 1).toUpperCase(),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              clientName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              clientEmail,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Available Documents Section
              Row(
                children: [
                  Icon(Icons.folder_open, color: Colors.deepPurple[800], size: 28),
                  const SizedBox(width: 12),
                  Text(
                    'Available Documents',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple[800],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Document Cards
              ...docTypes.map((doc) => _buildDocumentCard(context, doc)).toList(),
              
              const SizedBox(height: 24),
              
              // Pending Loan Filing Request Section
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.account_balance,
                            size: 32,
                            color: Colors.deepPurple[800],
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Pending Loan Filing Request',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepPurple[800],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Check loan applications from this client',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LoanFilingPage(
                                  officerId: bloId,
                                  clientId: clientId,
                                  apiService: apiService,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.assignment, size: 20),
                          label: const Text('View Loan Requests'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple[800],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentCard(BuildContext context, String docType) {
    IconData getDocIcon(String docType) {
      switch (docType.toLowerCase()) {
        case 'tin certificate':
          return Icons.verified_user;
        case 'nid':
          return Icons.badge;
        case 'salary certificate':
          return Icons.work;
        case 'bank statement':
          return Icons.account_balance;
        default:
          return Icons.description;
      }
    }

    Color getDocColor(String docType) {
      switch (docType.toLowerCase()) {
        case 'tin certificate':
          return Colors.green;
        case 'nid':
          return Colors.blue;
        case 'salary certificate':
          return Colors.orange;
        case 'bank statement':
          return Colors.deepPurple;
        default:
          return Colors.grey;
      }
    }

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Document Icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: getDocColor(docType).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                getDocIcon(docType),
                color: getDocColor(docType),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            // Document Name
            Expanded(
              child: Text(
                docType,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            // Download Button
            ElevatedButton.icon(
              onPressed: () => downloadFile(context, docType),
              icon: const Icon(Icons.download, size: 18),
              label: const Text('Download'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple[800],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
