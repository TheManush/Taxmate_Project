import 'package:flutter/material.dart';
import 'api_service.dart';
import 'file_download_fp.dart';
import 'file_upload_fp.dart';
import 'chat_page.dart';

class FPClientsPage extends StatefulWidget {
  final int fpId;
  final ApiService apiService;
  final int? focusedClientId; // Optional parameter for direct navigation

  const FPClientsPage({
    super.key,
    required this.fpId,
    required this.apiService,
    this.focusedClientId,
  });

  @override
  State<FPClientsPage> createState() => _FPClientsPageState();
}

class _FPClientsPageState extends State<FPClientsPage> {
  late Future<List<Map<String, dynamic>>> _clientsFuture;

  @override
  void initState() {
    super.initState();
    _clientsFuture = widget.apiService.fetchApprovedClientsForFP(widget.fpId);
  }

  void _navigateToClientDetails(BuildContext context, Map<String, dynamic> client) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _buildClientDetailSheet(client),
    );
  }

  Widget _buildClientDetailSheet(Map<String, dynamic> client) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildClientHeader(client),
          const SizedBox(height: 16),
          _buildActionButtons(client),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildClientHeader(Map<String, dynamic> client) {
    return Row(
      children: [
        const CircleAvatar(
          backgroundColor: Color(0xFFEDE9FE),
          child: Icon(Icons.person, color: Color(0xFF7C3AED)),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                client['full_name'],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              Text(
                client['email'],
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(Map<String, dynamic> client) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionButton(
          icon: Icons.folder_open,
          label: 'Documents',
          onPressed: () {
            Navigator.pop(context); // Close the bottom sheet
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => FileDownloadFPPage(
                  clientId: client['id'],
                  fpId: widget.fpId,
                  clientName: client['full_name'],
                  apiService: widget.apiService,
                ),
              ),
            );
          },
        ),
        _buildActionButton(
          icon: Icons.upload,
          label: 'Upload',
          onPressed: () {
            Navigator.pop(context); // Close the bottom sheet
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => FileUploadFPPage(
                  clientId: client['id'],
                  fpId: widget.fpId,
                  apiService: widget.apiService,
                ),
              ),
            );
          },
        ),
        _buildActionButton(
          icon: Icons.chat,
          label: 'Chat',
          onPressed: () {
            Navigator.pop(context); // Close the bottom sheet
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatPage(
                  senderId: widget.fpId,
                  receiverId: client['id'],
                  receiverName: client['full_name'],
                  apiService: widget.apiService,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionButton({required IconData icon, required String label, required VoidCallback onPressed}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(icon, size: 28),
          color: const Color(0xFF7C3AED),
          onPressed: onPressed,
        ),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Clients'),
        backgroundColor: const Color(0xFF7C3AED),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _clientsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No approved clients yet.'));
          }

          final clients = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: clients.length,
            itemBuilder: (context, index) {
              final client = clients[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => _navigateToClientDetails(context, client),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: _buildClientHeader(client),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}