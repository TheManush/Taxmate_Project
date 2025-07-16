import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'api_service.dart';

class FileDownloadFPPage extends StatefulWidget {
  final int clientId;
  final int fpId;
  final String clientName;
  final ApiService apiService;

  const FileDownloadFPPage({
    Key? key,
    required this.clientId,
    required this.fpId,
    required this.clientName,
    required this.apiService,
  }) : super(key: key);

  @override
  State<FileDownloadFPPage> createState() => _FileDownloadFPPageState();
}

class _FileDownloadFPPageState extends State<FileDownloadFPPage> {
  final List<Map<String, dynamic>> docTypes = [
    {
      'name': 'Financial Plan',
      'icon': Icons.attach_money,
      'color': Colors.green,
    },
    {
      'name': 'Investment Portfolio',
      'icon': Icons.trending_up,
      'color': Colors.blue,
    },
    {
      'name': 'Tax Strategy',
      'icon': Icons.receipt_long,
      'color': Colors.purple,
    },
    {
      'name': 'Retirement Plan',
      'icon': Icons.work_outline,
      'color': Colors.orange,
    },
  ];

  Future<void> downloadFile(BuildContext context, String docType) async {
    try {
      final url = await widget.apiService.getDownloadUrlForFP(
        widget.clientId,
        widget.fpId,
        docType,
      );
      print("Download URL: $url");

      final uri = Uri.parse(url);
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);

      if (!launched) {
        _showSnackBar(context, 'Could not launch file', isError: true);
      }
    } catch (e) {
      _showSnackBar(context, 'Error downloading $docType: $e', isError: true);
    }
  }

  void _showSnackBar(BuildContext context, String message, {bool isError = false}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: isError ? Colors.red : Colors.green,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Financial Documents',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              widget.clientName,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Available Documents', Icons.folder_open),
            const SizedBox(height: 16),
            _buildDocumentsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF7C3AED)),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentsList() {
    return Column(
      children: docTypes.map((doc) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: doc['color'].withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                doc['icon'],
                color: doc['color'],
                size: 24,
              ),
            ),
            title: Text(
              doc['name'],
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            subtitle: const Text(
              'PDF Document',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
            trailing: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF7C3AED),
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                icon: const Icon(Icons.download, color: Colors.white),
                onPressed: () => downloadFile(context, doc['name']),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}