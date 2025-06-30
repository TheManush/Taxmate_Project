import 'package:flutter/material.dart';

class FinancialPlanningPage extends StatelessWidget {
  const FinancialPlanningPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Financial Planning')),
      body: const Center(child: Text('Welcome to Financial Planning')),
    );
  }
}
