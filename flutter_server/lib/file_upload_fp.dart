import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'api_service.dart';

class FileUploadFPPage extends StatefulWidget {
  final int clientId;
  final int fpId;
  final ApiService apiService;

  const FileUploadFPPage({
    Key? key,
    required this.clientId,
    required this.fpId,
    required this.apiService,
  }) : super(key: key);

  @override
  State<FileUploadFPPage> createState() => _FileUploadFPPageState();
}

class _FileUploadFPPageState extends State<FileUploadFPPage> {
  final Map<String, File?> _files = {};
  final Map<String, String?> _uploadStatus = {};
  final List<String> _docTypes = [
    'Financial Plan',
    'Investment Portfolio',
    'Tax Strategy',
    'Retirement Plan'
  ];

  Future<void> _pickFile(String docType) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'xlsx'],
      );
      if (result != null && result.files.single.path != null) {
        setState(() {
          _files[docType] = File(result.files.single.path!);
          _uploadStatus[docType] = null;
        });
      }
    } catch (e) {
      setState(() {
        _uploadStatus[docType] = 'Failed to pick file: $e';
      });
    }
  }

  Future<void> _uploadFile(String docType) async {
    final file = _files[docType];
    if (file == null) return;

    setState(() {
      _uploadStatus[docType] = 'Uploading...';
    });

    try {
      final fileBytes = await file.readAsBytes();
      final fileName = file.path.split('/').last;
      final contentType = widget.apiService.getContentType(file.path);

      await widget.apiService.uploadFileToFP(
        userId: widget.clientId,
        fpId: widget.fpId,
        fileBytes: fileBytes,
        fileName: fileName,
        contentType: contentType,
        docType: docType,
      );

      setState(() {
        _uploadStatus[docType] = 'Uploaded successfully';
      });
    } catch (e) {
      setState(() {
        _uploadStatus[docType] = 'Upload failed: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Financial Documents'),
        backgroundColor: const Color(0xFF7C3AED), // FP purple color
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _docTypes.length,
        itemBuilder: (context, index) {
          final docType = _docTypes[index];
          final file = _files[docType];
          final status = _uploadStatus[docType];

          return Card(
            margin: const EdgeInsets.only(bottom: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    docType,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF7C3AED)), // FP purple color
                  ),
                  const SizedBox(height: 10),
                  if (file != null)
                    Text(
                      '📄 ${file.path.split('/').last}',
                      style: const TextStyle(fontStyle: FontStyle.italic),
                    ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF7C3AED)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: () => _pickFile(docType),
                          child: const Text('Select File'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7C3AED),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: file != null ? () => _uploadFile(docType) : null,
                          child: const Text('Upload'),
                        ),
                      ),
                    ],
                  ),
                  if (status != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      status,
                      style: TextStyle(
                        color: status.contains('successfully') 
                            ? Colors.green 
                            : Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}