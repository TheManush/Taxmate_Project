import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'api_service.dart';

class FileDownloadPage extends StatefulWidget {
  final int clientId;
  final int caId;
  final String clientName;
  final ApiService apiService;

  const FileDownloadPage({
    Key? key,
    required this.clientId,
    required this.caId,
    required this.clientName,
    required this.apiService,
  }) : super(key: key);

  @override
  State<FileDownloadPage> createState() => _FileDownloadPageState();
}

class _FileDownloadPageState extends State<FileDownloadPage> {
  final List<Map<String, dynamic>> docTypes = [
    {
      'name': 'TIN Certificate',
      'icon': Icons.receipt_long,
      'color': Colors.blue,
    },
    {
      'name': 'NID',
      'icon': Icons.credit_card,
      'color': Colors.green,
    },
    {
      'name': 'Salary Certificate',
      'icon': Icons.work,
      'color': Colors.orange,
    },
    {
      'name': 'Bank Statement',
      'icon': Icons.account_balance,
      'color': Colors.purple,
    },
  ];

  File? _auditFile;
  String? _uploadStatus;
  bool _isUploading = false;

  Future<void> downloadFile(BuildContext context, String docType) async {
    try {
      final url = await widget.apiService.getDownloadUrl(
        widget.clientId,
        widget.caId,
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

  Future<void> _pickAuditReport() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _auditFile = File(result.files.single.path!);
        _uploadStatus = null;
      });
    }
  }

  Future<void> _uploadAuditReport() async {
    if (_auditFile == null) return;

    setState(() {
      _isUploading = true;
      _uploadStatus = 'Uploading...';
    });

    try {
      final fileBytes = await _auditFile!.readAsBytes();
      final fileName = 'audit_report.pdf';
      final contentType = widget.apiService.getContentType(_auditFile!.path);

      final response = await widget.apiService.uploadFile(
        userId: widget.clientId,
        caId: widget.caId,
        fileBytes: fileBytes,
        fileName: fileName,
        contentType: contentType,
        docType: 'Audit Report',
      );

      setState(() {
        _uploadStatus = 'Uploaded successfully';
        _isUploading = false;
      });
    } catch (e) {
      setState(() {
        _uploadStatus = 'Upload failed: $e';
        _isUploading = false;
      });
    }
  }

  void _showSnackBar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
              'Documents',
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
            // Available Documents Section
            _buildSectionHeader('Available Documents', Icons.folder_open),
            const SizedBox(height: 16),
            _buildDocumentsList(),

            const SizedBox(height: 32),

            // Upload Section
            _buildSectionHeader('Upload Documents', Icons.cloud_upload),
            const SizedBox(height: 16),
            _buildUploadSection(),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue, size: 24),
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
                color: Colors.blue,
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

  Widget _buildUploadSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Audit Report',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Upload your audit report in PDF format',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),

          // File picker button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                side: BorderSide(
                  color: _auditFile != null ? Colors.green : Colors.grey,
                ),
              ),
              icon: Icon(
                _auditFile != null ? Icons.check_circle : Icons.attach_file,
                color: _auditFile != null ? Colors.green : Colors.grey,
              ),
              label: Text(
                _auditFile != null
                    ? 'File Selected: ${_auditFile!.path.split('/').last}'
                    : 'Choose PDF File',
                style: TextStyle(
                  color: _auditFile != null ? Colors.green : Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onPressed: _pickAuditReport,
            ),
          ),

          const SizedBox(height: 12),

          // Upload button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: _auditFile != null ? Colors.blue : Colors.grey,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: _isUploading
                  ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
                  : const Icon(Icons.cloud_upload),
              label: Text(
                _isUploading ? 'Uploading...' : 'Upload Report',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              onPressed: _auditFile != null && !_isUploading ? _uploadAuditReport : null,
            ),
          ),

          // Status message
          if (_uploadStatus != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _uploadStatus!.contains('successfully')
                    ? Colors.green.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    _uploadStatus!.contains('successfully')
                        ? Icons.check_circle
                        : Icons.error,
                    color: _uploadStatus!.contains('successfully')
                        ? Colors.green
                        : Colors.red,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _uploadStatus!,
                      style: TextStyle(
                        color: _uploadStatus!.contains('successfully')
                            ? Colors.green
                            : Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}