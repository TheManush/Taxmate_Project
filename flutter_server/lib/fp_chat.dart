// fp_chat.dart
import 'package:flutter/material.dart';

class FPChat extends StatelessWidget {
  final List<Map<String, String>> clients;

  const FPChat({super.key, required this.clients});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat with Clients'),
        backgroundColor: Colors.deepPurple,
      ),
      body: ListView.builder(
        itemCount: clients.length,
        itemBuilder: (context, index) {
          final client = clients[index];
          return ListTile(
            leading: const Icon(Icons.person),
            title: Text(client['name']!),
            trailing: ElevatedButton(
              onPressed: () {
                // TODO: Navigate to real-time chat screen
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
              child: const Text('Chat', style: TextStyle(color: Colors.white)),
            ),
          );
        },
      ),
    );
  }
}
