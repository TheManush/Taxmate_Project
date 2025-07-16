import 'package:flutter/material.dart';
import 'api_service.dart';
import 'chat_page.dart';

class ClientPageFromFP extends StatefulWidget {
  final int clientId;
  final String clientName;
  final String clientEmail;
  final int plannerId;
  final String plannerName;
  final ApiService apiService;

  const ClientPageFromFP({
    super.key,
    required this.clientId,
    required this.clientName,
    required this.clientEmail,
    required this.plannerId,
    required this.plannerName,
    required this.apiService,
  });

  @override
  State<ClientPageFromFP> createState() => _ClientPageFromFPState();
}

class _ClientPageFromFPState extends State<ClientPageFromFP> {
  Map<String, dynamic>? clientDetails;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadClientDetails();
  }

  Future<void> _loadClientDetails() async {
    try {
      // You can add an API endpoint to get detailed client information
      // For now, we'll use the basic information provided
      setState(() {
        clientDetails = {
          'id': widget.clientId,
          'full_name': widget.clientName,
          'email': widget.clientEmail,
        };
        isLoading = false;
      });
    } catch (e) {
      print('Error loading client details: $e');
      setState(() => isLoading = false);
    }
  }

  void _openChat() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPage(
          senderId: widget.plannerId,
          receiverId: widget.clientId,
          receiverName: widget.clientName,
          apiService: widget.apiService,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Client: ${widget.clientName}'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.chat),
            onPressed: _openChat,
            tooltip: 'Chat with ${widget.clientName}',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Client Profile Card
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.purple[100],
                            child: Text(
                              widget.clientName[0].toUpperCase(),
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.purple[800],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            widget.clientName,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.clientEmail,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green[100],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Approved Client',
                              style: TextStyle(
                                color: Colors.green[800],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Financial Planning Services Section
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Financial Planning Services',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildServiceItem(
                            Icons.trending_up,
                            'Investment Planning',
                            'Help with portfolio management and investment strategies',
                          ),
                          _buildServiceItem(
                            Icons.home,
                            'Retirement Planning',
                            'Plan for a secure financial future',
                          ),
                          _buildServiceItem(
                            Icons.family_restroom,
                            'Insurance Planning',
                            'Life, health, and property insurance guidance',
                          ),
                          _buildServiceItem(
                            Icons.savings,
                            'Tax Planning',
                            'Optimize tax strategies and savings',
                          ),
                          _buildServiceItem(
                            Icons.school,
                            'Education Planning',
                            'Save and plan for educational expenses',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Communication Section
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Communication',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ListTile(
                            leading: const Icon(
                              Icons.chat,
                              color: Colors.purple,
                            ),
                            title: const Text('Start Chat'),
                            subtitle: Text('Chat with ${widget.clientName}'),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: _openChat,
                          ),
                          ListTile(
                            leading: const Icon(
                              Icons.email,
                              color: Colors.purple,
                            ),
                            title: const Text('Send Email'),
                            subtitle: Text(widget.clientEmail),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: () {
                              // You can implement email functionality here
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Email functionality coming soon'),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildServiceItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.purple, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
