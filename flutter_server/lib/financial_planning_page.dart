import 'package:flutter/material.dart';
import 'api_service.dart';

class FinancialPlanningPage extends StatefulWidget {
  final int clientId;
  final ApiService apiService;

  const FinancialPlanningPage({
    super.key,
    required this.clientId,
    required this.apiService,
  });

  @override
  State<FinancialPlanningPage> createState() => _FinancialPlanningPageState();
}

class _FinancialPlanningPageState extends State<FinancialPlanningPage> {
  late Future<List<Map<String, dynamic>>> _financialPlanners;

  @override
  void initState() {
    super.initState();
    _financialPlanners = widget.apiService.fetchFinancialPlanners();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Planners'),
        backgroundColor: const Color(0xFF8B5CF6),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _financialPlanners,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No financial planners available'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final planner = snapshot.data![index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFEDE9FE),
                    child: Icon(Icons.person, color: Color(0xFF8B5CF6)),
                  ),
                  title: Text(planner['full_name']),
                  subtitle: Text(planner['email']),
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B5CF6),
                    ),
                    onPressed: () => _sendRequest(planner['id']),
                    child: const Text('Request Service'),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _sendRequest(int fpId) async {
    try {
      await widget.apiService.sendFPRequest(
        clientId: widget.clientId,
        fpId: fpId,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request sent successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send request: $e')),
      );
    }
  }
}