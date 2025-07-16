import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'home_page.dart';
import 'api_service.dart';
import 'client_dashboard.dart';
import 'ca_dashboard.dart';
import 'blo_dashboard.dart';
import 'admin.dart';
import 'fp_dashboard.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'recovery_pass.dart';   //add this extra line for password recovery

class LoginPage extends StatefulWidget {
  final VoidCallback onToggle;
  final String apiBaseUrl;

  const LoginPage({
    super.key,
    required this.onToggle,
    required this.apiBaseUrl,
  });

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  void initState() {
    super.initState();
    _requestNotificationPermission();
    _setupFcmTokenRefreshListener();
  }

  // Request notification permission for Android 13+
  Future<void> _requestNotificationPermission() async {
    final messaging = FirebaseMessaging.instance;
    await messaging.requestPermission();
  }

  // Listen for FCM token refresh and update backend
  void _setupFcmTokenRefreshListener() {
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      // Get userId from secure storage
      String? userId = await _secureStorage.read(key: 'id');
      if (userId != null) {
        try {
          await http.post(
            Uri.parse('${widget.apiBaseUrl}/register_fcm_token/'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'user_id': int.tryParse(userId),
              'fcm_token': newToken,
            }),
          );
        } catch (e) {
          // Optionally handle error
        }
      }
    });
  }
  Future<void> _registerFcmToken(int userId) async {
    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null) {
        await http.post(
          Uri.parse('${widget.apiBaseUrl}/register_fcm_token/'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'user_id': userId,
            'fcm_token': fcmToken,
          }),
        );
      }
    } catch (e) {
      // Optionally handle error
    }
  }
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() => _errorMessage = 'Please fill in all fields');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.post(
        Uri.parse('${widget.apiBaseUrl}/login/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _emailController.text,
          'password': _passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        try {
          final responseData = jsonDecode(utf8.decode(response.bodyBytes));
          if (responseData is Map<String, dynamic> &&
              responseData.containsKey('data')) {
            final data = responseData['data'];

            // Store login info for persistence
            await _secureStorage.write(key: 'id', value: data['id'].toString());
            await _secureStorage.write(key: 'full_name', value: data['full_name'] ?? data['fullName'] ?? '');
            await _secureStorage.write(key: 'email', value: data['email'] ?? '');
            await _secureStorage.write(key: 'dob', value: data['dob'] ?? '');
            await _secureStorage.write(key: 'gender', value: data['gender'] ?? '');
            await _secureStorage.write(key: 'user_type', value: data['user_type'] ?? data['userType'] ?? '');
            await _secureStorage.write(key: 'client_type', value: data['client_type'] ?? data['clientType'] ?? '');
            await _secureStorage.write(key: 'service_provider_type', value: data['service_provider_type'] ?? data['serviceProviderType'] ?? '');

            // Register/update FCM token after login
            await _registerFcmToken(data['id']);

            // Navigate based on user type
            _navigateBasedOnUserType(data);

          } else {
            throw Exception('Invalid response format');
          }
        } catch (e) {
          setState(() {
            _errorMessage = 'Failed to parse server response';
          });
        }
      } else {
        final errorResponse = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          _errorMessage =
              errorResponse['detail'] ?? 'Login failed. Status code: ${response.statusCode}';
        });
      }
    } on http.ClientException catch (e) {
      setState(() {
        _errorMessage = 'Network error: ${e.message}';
      });
    } on FormatException {
      setState(() {
        _errorMessage = 'Invalid server response format';
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'An unexpected error occurred';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _navigateBasedOnUserType(Map<String, dynamic> userData) {
    final ApiService apiService = ApiService(widget.apiBaseUrl);
    final int userId = userData['id'];
    final String fullName = userData['full_name'] ?? userData['fullName'] ?? 'User';
    final String email = userData['email'] ?? '';
    final String dob = userData['dob'] ?? '';
    final String gender = userData['gender'] ?? '';
    final String userType = userData['user_type'] ?? userData['userType'] ?? '';
    final String? serviceProviderType = userData['service_provider_type'] ?? userData['serviceProviderType'];

    if (userType.toLowerCase() == 'client') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ClientDashboard(
            clientId: userId,
            fullName: fullName,
            email: email,
            dob: dob,
            gender: gender,
            userType: userType,
            clientType: userData['client_type'] ?? userData['clientType'],
            apiService: apiService,
          ),
        ),
      );
    } else if (userType.toLowerCase() == 'admin') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AdminDashboard(
            adminId: userId,
            fullName: fullName,
            email: email,
            dob: dob,
            gender: gender,
            userType: userType,
            serviceProviderType: serviceProviderType,
            apiService: apiService,
          ),
        ),
      );
    }else if (userType.toLowerCase() == 'service_provider') {
        // Normalize the service provider type for comparison
        final normalizedType = serviceProviderType?.toLowerCase().replaceAll(' ', '_');
        
        if (normalizedType == 'chartered_accountant') {
          Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => CAdashboard(
              caId: userId,
              fullName: fullName,
              email: email,
              dob: dob,
              gender: gender,
              userType: userType,
              serviceProviderType: serviceProviderType,
              apiService: apiService,
            ),
          ),
        );
      } else if (normalizedType == 'bank_loan_officer') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => BankLoanOfficerDashboard(
              officerId: userId,
              fullName: fullName,
              email: email,
              dob: dob,
              gender: gender,
              userType: userType,
              serviceProviderType: serviceProviderType,
              apiService: apiService,
            ),
          ),
        );
      } /////fb
      else if (normalizedType == 'financial_planner') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => FPDashboard(
            fpId: userId,
            fullName: fullName,
            email: email,
            dob: dob,
            gender: gender,
            userType: userType,
            serviceProviderType: serviceProviderType,
            apiService: apiService,
          ),
        ),
      );
    } 
       else {
        _showErrorDialog('Unsupported service provider type: $serviceProviderType');
      }
    } else {
        if (userType.isEmpty) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => WelcomePage(
                fullName: fullName,
                email: email,
                dob: dob,
                gender: gender,
                apiService: apiService,
              ),
            ),
          );
        } else {
          _showErrorDialog('Unknown user type: $userType');
        }
  }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          children: <Widget>[
            // Top Background Image
            Stack(
              children: [
                Container(
                  height: 400,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/background.png'),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                Positioned(
                  top: 40,
                  left: 10,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const Positioned.fill(
                  child: Align(
                    alignment: Alignment(0, -0.6),
                    child: Text(
                      "Login",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Login Form
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                children: <Widget>[
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color.fromRGBO(143, 148, 251, 1)),
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromRGBO(143, 148, 251, .2),
                          blurRadius: 20.0,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: <Widget>[
                        Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Color.fromRGBO(143, 148, 251, 1),
                              ),
                            ),
                          ),
                          child: TextField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "Email Address",
                              hintStyle: TextStyle(color: Colors.grey[700]),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "Password",
                              hintStyle: TextStyle(color: Colors.grey[700]),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Login Button
                  GestureDetector(
                    onTap: _login,
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: const LinearGradient(
                          colors: [
                            Color.fromRGBO(155, 100, 255, 1),
                            Color.fromRGBO(130, 80, 220, 1),
                          ],
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          "Login",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 70),

                  // Forgot Password
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RecoveryPass(apiBaseUrl: widget.apiBaseUrl),
                        ),
                      );
                    },
                    child: const Text(
                      "Forgot Password?",
                      style: TextStyle(
                        color: Color.fromRGBO(155, 100, 255, 1),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: widget.onToggle,
                    child: const Text("Don't have an account? Sign Up"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
