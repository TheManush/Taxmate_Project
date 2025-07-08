import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'api_service.dart';

class FileDownloadPage extends StatelessWidget {
  final int clientId;
  final int caId;
  final String clientName;
  final ApiService apiService;

  FileDownloadPage({
    Key? key,
    required this.clientId,
    required this.caId,
    required this.clientName,
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
      final url = await apiService.getDownloadUrl(clientId, caId, docType);
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Files from $clientName")),

      // ⬇️ TEMP test button
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.link),
        onPressed: () async {
          const testUrl = "https://alxtxsmnyjkbjcjhgsqu.supabase.co/storage/v1/object/public/hello/bank_statement.pdf";
          final uri = Uri.parse(testUrl);
          final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
          if (!launched) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Could not launch test URL')),
            );
          }
        },
      ),

      // ⬇️ Your actual document list
      body: ListView.builder(
        itemCount: docTypes.length,
        itemBuilder: (context, index) {
          final doc = docTypes[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
              title: Text(doc),
              trailing: IconButton(
                icon: const Icon(Icons.download, color: Colors.blue),
                onPressed: () => downloadFile(context, doc),
              ),
            ),
          );
        },
      ),
    );
  }

}
