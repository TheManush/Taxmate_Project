import 'package:flutter/material.dart';
import 'login_page.dart';
import 'signup_page.dart';
import 'about_us.dart';

class LandingPage extends StatelessWidget {
  final String apiBaseUrl;

  const LandingPage({super.key, required this.apiBaseUrl});

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
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AboutUsPage(),
                        ),
                      );
                    },
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