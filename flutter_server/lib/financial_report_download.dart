import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class FinancialReportDownloadPage extends StatelessWidget {
  final int clientId;
  final String apiBaseUrl;
  const FinancialReportDownloadPage({required this.clientId, required this.apiBaseUrl, Key? key}) : super(key: key);

  Future<void> downloadReport(BuildContext context) async {
    final url = '$apiBaseUrl/financial-report/$clientId';
    
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text('Generating PDF report...'),
              ],
            ),
          );
        },
      );

      // Request storage permission
      await Permission.storage.request();
      
      final response = await http.get(Uri.parse(url));
      
      // Dismiss loading dialog
      Navigator.of(context).pop();
      
      if (response.statusCode == 200) {
        // Try to get Downloads directory first, fallback to external storage
        Directory? downloadsDir;
        
        if (Platform.isAndroid) {
          downloadsDir = Directory('/storage/emulated/0/Download');
          if (!await downloadsDir.exists()) {
            downloadsDir = await getExternalStorageDirectory();
          }
        } else {
          downloadsDir = await getApplicationDocumentsDirectory();
        }
        
        if (downloadsDir != null) {
          final fileName = 'TaxMate_Financial_Report_Client_$clientId.pdf';
          final file = File('${downloadsDir.path}/$fileName');
          await file.writeAsBytes(response.bodyBytes);
          
          if (context.mounted) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green),
                      SizedBox(width: 8),
                      Text('Success!'),
                    ],
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Your financial report has been downloaded successfully.'),
                      const SizedBox(height: 12),
                      const Text('File location:', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(
                        Platform.isAndroid ? '/Download/$fileName' : file.path,
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('OK'),
                    ),
                  ],
                );
              },
            );
          }
        } else {
          throw Exception('Unable to access storage directory');
        }
      } else {
        throw Exception('Failed to download report: ${response.statusCode}');
      }
    } catch (e) {
      // Dismiss loading dialog if still showing
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.error, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Download Failed'),
                ],
              ),
              content: Text('Error: $e'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: ListTile(
        leading: const Icon(Icons.picture_as_pdf, color: Colors.blue),
        title: const Text('Download Financial Report'),
        subtitle: const Text('Get a comprehensive PDF analysis of your financial data.'),
        trailing: IconButton(
          icon: const Icon(Icons.download, color: Colors.blue),
          onPressed: () => downloadReport(context),
        ),
      ),
    );
  }
}
