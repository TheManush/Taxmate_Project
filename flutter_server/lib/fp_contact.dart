// fp_contact.dart
import 'package:flutter/material.dart';

class FPContact extends StatelessWidget {
  final List<Map<String, String>> clients;

  const FPContact({super.key, required this.clients});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Client Contacts'),
        backgroundColor: Colors.deepPurple,
      ),
      body: ListView.builder(
        itemCount: clients.length,
        itemBuilder: (context, index) {
          final client = clients[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: const Icon(Icons.person_outline),
              title: Text(client['name']!),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Email: ${client['email']}'),
                  Text('Phone: ${client['phone']}'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
