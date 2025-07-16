
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  Future<void> _launchEmail(String email, BuildContext context) async {
    try {
      // For Samsung devices, we'll use a more direct approach
      // Try different email intents that work better on Samsung
      
      // 1. Try Samsung Email app
      final Uri samsungEmailUri = Uri.parse('samsungemail://compose?to=$email');
      if (await canLaunchUrl(samsungEmailUri)) {
        await launchUrl(samsungEmailUri, mode: LaunchMode.externalApplication);
        return;
      }
      
      // 2. Try Gmail app with different intent
      final Uri gmailIntentUri = Uri.parse('intent://compose?to=$email#Intent;scheme=googlegmail;package=com.google.android.gm;end');
      if (await canLaunchUrl(gmailIntentUri)) {
        await launchUrl(gmailIntentUri, mode: LaunchMode.externalApplication);
        return;
      }
      
      // 3. Try standard mailto but without checking canLaunchUrl first (Samsung issue)
      final Uri emailUri = Uri(scheme: 'mailto', path: email);
      try {
        await launchUrl(emailUri, mode: LaunchMode.externalApplication);
        return;
      } catch (e) {
        print('Mailto failed: $e');
      }
      
      // 4. Try opening Gmail web with platform view
      final Uri gmailWebUri = Uri.parse('https://mail.google.com/mail/?view=cm&fs=1&to=$email');
      try {
        await launchUrl(gmailWebUri, mode: LaunchMode.inAppWebView);
        return;
      } catch (e) {
        print('Gmail web failed: $e');
      }
      
      // 5. Final fallback - show dialog with email address
      _showEmailDialog(email, context);
      
    } catch (e) {
      print('Error launching email: $e');
      _showEmailDialog(email, context);
    }
  }
  
  void _showEmailDialog(String email, BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Contact Information'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Email address:'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: SelectableText(
                  email,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Long press the email above to copy it, then paste it in:',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              const Text(
                '• Gmail app\n• Samsung Email\n• Any other email app',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'About Us',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color.fromRGBO(130, 80, 220, 1),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromRGBO(130, 80, 220, 1),
              Color.fromRGBO(155, 100, 255, 1),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                const SizedBox(height: 20),

                // Team Section
                const Text(
                  'Meet Our Team',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),

                // Team Members
                Expanded(
                  child: ListView(
                    children: [
                      _buildDeveloperCard(
                        context: context,
                        name: "Ahnaf",
                        email: "ahnaf@example.com",
                        imagePath: "assets/images/nah_id_win.jpg",
                      ),
                      const SizedBox(height: 15),
                      _buildDeveloperCard(
                        context: context,
                        name: "Sakafy",
                        email: "sakafy@example.com",
                        imagePath: "assets/images/nah_id_win.jpg",
                      ),
                      const SizedBox(height: 15),
                      _buildDeveloperCard(
                        context: context,
                        name: "Rabbani",
                        email: "rabbani@example.com",
                        imagePath: "assets/images/nah_id_win.jpg",
                      ),
                      const SizedBox(height: 15),
                      _buildDeveloperCard(
                        context: context,
                        name: "Arafat",
                        email: "arafat@example.com",
                        imagePath: "assets/images/nah_id_win.jpg",
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Footer
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Column(
                    children: [
                      Text(
                        'Version 1.0.0',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        '© 2024 TaxMate Team. All rights reserved.',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeveloperCard({
    required BuildContext context,
    required String name,
    required String email,
    required String imagePath,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
            ),
            child: ClipOval(
              child: Image.asset(
                imagePath,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 60,
                    height: 60,
                    color: Colors.white.withOpacity(0.2),
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 30,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => _launchEmail(email, context),
                  child: Text(
                    email,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.lightBlueAccent,
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.underline,
                    ),
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
