import 'package:flutter/material.dart';
import 'login_page.dart';
import 'signup_page.dart';

class LandingPage extends StatelessWidget {
  final String apiBaseUrl;

  const LandingPage({super.key, required this.apiBaseUrl});

  void _showAboutUs(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("About Us"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDeveloperCard(
                  name: "Ahnaf",
                  email: "ahnaf@example.com",
                  imagePath: "assets/images/nah_id_win.jpg",
                ),
                _buildDeveloperCard(
                  name: "Sakafy",
                  email: "sakafy@example.com",
                  imagePath: "assets/images/nah_id_win.jpg",
                ),
                _buildDeveloperCard(
                  name: "Rabbani",
                  email: "rabbani@example.com",
                  imagePath: "assets/images/nah_id_win.jpg",
                ),
                _buildDeveloperCard(
                  name: "Arafat",
                  email: "arafat@example.com",
                  imagePath: "assets/images/nah_id_win.jpg",
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Close"),
            ),
          ],
        );
      },
    );
  }

  static Widget _buildDeveloperCard({
    required String name,
    required String email,
    required String imagePath,
  }) {
    return Card(
      child: ListTile(
        leading: Image.asset(imagePath, width: 40, height: 40),
        title: Text(name),
        subtitle: Text(email),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "TaxMate",
                    style: TextStyle(
                      fontFamily: 'RusticRoadway',
                      color: Colors.white,
                      fontSize: 50,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Welcome",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 50),
                  _buildGradientButton(
                    text: "Login",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LoginPage(
                            onToggle: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => SignUpPage(
                                    onToggleLogin: () {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => LandingPage(apiBaseUrl: apiBaseUrl),
                                        ),
                                      );
                                    },
                                    apiBaseUrl: apiBaseUrl,
                                  ),
                                ),
                              );
                            },
                            apiBaseUrl: apiBaseUrl,
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 20),
                  _buildGradientButton(
                    text: "Sign Up",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SignUpPage(
                            onToggleLogin: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => LoginPage(
                                    onToggle: () {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => LandingPage(apiBaseUrl: apiBaseUrl),
                                        ),
                                      );
                                    },
                                    apiBaseUrl: apiBaseUrl,
                                  ),
                                ),
                              );
                            },
                            apiBaseUrl: apiBaseUrl,
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 20),
                  TextButton(
                    onPressed: () => _showAboutUs(context),
                    child: Text(
                      "About Us",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradientButton({required String text, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: LinearGradient(
            colors: [
              Color.fromRGBO(155, 100, 255, 1),
              Color.fromRGBO(130, 80, 220, 1),
            ],
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }
}
