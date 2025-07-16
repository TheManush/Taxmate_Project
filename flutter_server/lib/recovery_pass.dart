import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RecoveryPass extends StatefulWidget {
  final String apiBaseUrl;
  const RecoveryPass({super.key, required this.apiBaseUrl});

  @override
  _RecoveryPassState createState() => _RecoveryPassState();
}

class _RecoveryPassState extends State<RecoveryPass> {
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _newPassController = TextEditingController();
  final _confirmPassController = TextEditingController();

  bool _isSending = false;
  int _secondsRemaining = 0;
  Timer? _timer;

  Future<void> _sendOtp() async {
    if (_emailController.text.isEmpty) return;

    setState(() {
      _isSending = true;
      _secondsRemaining = 300; // 5 minutes
    });

    try {
      final response = await http.post(
        Uri.parse('${widget.apiBaseUrl}/recovery/send-otp/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"email": _emailController.text}),
      );

      final data = jsonDecode(response.body);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(data['message'])));

      _startTimer();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error sending OTP. Try again.')));
      setState(() => _isSending = false);
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        timer.cancel();
        setState(() => _isSending = false);
      }
    });
  }

  Future<void> _verifyOtpAndReset() async {
    if (_otpController.text.isEmpty ||
        _newPassController.text.isEmpty ||
        _confirmPassController.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Fill all fields')));
      return;
    }

    final response = await http.post(
      Uri.parse('${widget.apiBaseUrl}/recovery/verify-otp/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "email": _emailController.text,
        "otp": _otpController.text,
        "new_password": _newPassController.text,
        "confirm_password": _confirmPassController.text
      }),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Password updated successfully")));
      Navigator.pop(context); // go back to login
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['detail'] ?? 'Error occurred')));
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _emailController.dispose();
    _otpController.dispose();
    _newPassController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            // Background Image + Title
            Stack(
              children: [
                Container(
                  height: 300,
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
                    icon: const Icon(Icons.arrow_back,
                        color: Colors.white, size: 30),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const Positioned.fill(
                  child: Align(
                    alignment: Alignment(0, -0.6),
                    child: Text(
                      "Recover Password",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: const Color.fromRGBO(143, 148, 251, 1)),
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
                        _buildTextField(_emailController, "Email Address"),
                        _buildTextField(_otpController, "OTP"),
                        _buildTextField(_newPassController, "New Password",
                            obscure: true),
                        _buildTextField(_confirmPassController,
                            "Confirm Password",
                            obscure: true),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Send OTP Button
                  GestureDetector(
                    onTap: _isSending ? null : _sendOtp,
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
                      child: Center(
                        child: Text(
                          _isSending
                              ? "Wait ${_secondsRemaining ~/ 60}:${(_secondsRemaining % 60).toString().padLeft(2, '0')}"
                              : "Send Code",
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Reset Password Button
                  GestureDetector(
                    onTap: _verifyOtpAndReset,
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
                          "Reset Password",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hintText,
      {bool obscure = false}) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color.fromRGBO(143, 148, 251, 1)),
        ),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[700]),
        ),
      ),
    );
  }
}
