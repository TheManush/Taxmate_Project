import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';

class SignUpPage extends StatefulWidget {
  final VoidCallback onToggleLogin;
  final String apiBaseUrl;

  const SignUpPage({
    required this.onToggleLogin,
    required this.apiBaseUrl,
  });

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedUserType;
  String? _selectedClientType;
  String? _selectedServiceProviderType;
  String? _selectedBusinessType;
  String? _gender;
  DateTime? _selectedDate;

  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _professionController = TextEditingController();
  final _enterpriseNameController = TextEditingController();
  final _tinController = TextEditingController();
  final _experienceController = TextEditingController();
  final _degreeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  void _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        final response = await http.post(
          Uri.parse('${widget.apiBaseUrl}/signup/'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'user_type': _selectedUserType,
            'client_type': _selectedClientType,
            'service_provider_type': _selectedServiceProviderType,
            'full_name': _fullNameController.text,
            'email': _emailController.text,
            'phone': _phoneController.text,
            'address': _addressController.text,
            'password': _passwordController.text,
            'profession': _professionController.text,
            'gender': _gender,
            'dob': _selectedDate?.toIso8601String(),
            'enterprise_name': _enterpriseNameController.text,
            'tin_number': _tinController.text,
            'business_type': _selectedBusinessType,
            'experience': _experienceController.text,
            'qualification': _degreeController.text,
          }),
        );

        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registration successful! Please login.')),
          );
          widget.onToggleLogin();
        } else {
          final error = jsonDecode(response.body)['detail'];
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $error')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Sign Up'),
        backgroundColor: Colors.blue[800],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Create Account',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Select your account type to get started',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 20),

              // User Type Dropdown
              DropdownButtonFormField<String>(
                value: _selectedUserType,
                decoration: InputDecoration(
                  labelText: "I am a",
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                ),
                isExpanded: true,
                items: ['Client', 'Service Provider', 'Admin'].map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedUserType = value;
                    _selectedClientType = null;
                    _selectedServiceProviderType = null;
                  });
                },
                validator: (value) => value == null ? "Please select user type" : null,
              ),
              const SizedBox(height: 16),

              // Conditional Fields based on User Type
              if (_selectedUserType == 'Client')
                DropdownButtonFormField<String>(
                  value: _selectedClientType,
                  decoration: InputDecoration(
                    labelText: "Client Type",
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  ),
                  isExpanded: true,
                  items: ['Individual', 'Enterprise'].map((type) {
                    return DropdownMenuItem(value: type, child: Text(type));
                  }).toList(),
                  onChanged: (value) => setState(() => _selectedClientType = value),
                  validator: (value) => value == null ? "Please select client type" : null,
                ),
              
              if (_selectedUserType == 'Client' && _selectedClientType != null)
                const SizedBox(height: 16),

              if (_selectedUserType == 'Service Provider')
                DropdownButtonFormField<String>(
                  value: _selectedServiceProviderType,
                  decoration: InputDecoration(
                    labelText: "Service Provider Type",
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  ),
                  isExpanded: true,
                  items: [
                    'Chartered Accountant',
                    'Financial Planner',
                    'Bank Loan Officer'
                  ].map((type) {
                    return DropdownMenuItem(value: type, child: Text(type));
                  }).toList(),
                  onChanged: (value) => setState(() => _selectedServiceProviderType = value),
                  validator: (value) => value == null ? "Please select type" : null,
                ),
              
              if (_selectedUserType == 'Service Provider' && _selectedServiceProviderType != null)
                const SizedBox(height: 16),

              // Common Fields
              if (_selectedUserType != null) ...[
                _buildTextField(_fullNameController, "Full Name", Icons.person),
                _buildTextField(_emailController, "Email", Icons.email),
                _buildTextField(_phoneController, "Phone Number", Icons.phone, keyboardType: TextInputType.phone),
                _buildTextField(_addressController, "Address", Icons.location_on),
              ],

              // Individual Client Fields
              if (_selectedUserType == 'Client' && _selectedClientType == 'Individual') ...[
                _buildTextField(_professionController, "Profession", Icons.work),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _gender,
                  decoration: InputDecoration(
                    labelText: "Gender",
                    prefixIcon: Icon(Icons.transgender),
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  ),
                  isExpanded: true,
                  items: ["Male", "Female", "Other"].map((gender) {
                    return DropdownMenuItem(value: gender, child: Text(gender));
                  }).toList(),
                  onChanged: (value) => setState(() => _gender = value),
                  validator: (value) => value == null ? "Select gender" : null,
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: _pickDate,
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: "Date of Birth",
                      prefixIcon: Icon(Icons.calendar_today),
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    ),
                    child: Text(
                      _selectedDate == null
                          ? "Select Date"
                          : DateFormat('MMM dd, yyyy').format(_selectedDate!),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Enterprise Client Fields
              if (_selectedUserType == 'Client' && _selectedClientType == 'Enterprise') ...[
                _buildTextField(_enterpriseNameController, "Enterprise Name", Icons.business),
                _buildTextField(_tinController, "TIN Number", Icons.numbers, keyboardType: TextInputType.number),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedBusinessType,
                  decoration: InputDecoration(
                    labelText: "Business Type",
                    prefixIcon: Icon(Icons.category),
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  ),
                  isExpanded: true,
                  items: [
                    'Retail', 'Wholesale', 'Manufacturing',
                    'Service', 'IT', 'Healthcare', 'Education',
                    'Finance', 'Real Estate', 'Other'
                  ].map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
                  onChanged: (value) => setState(() => _selectedBusinessType = value),
                  validator: (value) => value == null ? "Select business type" : null,
                ),
                const SizedBox(height: 16),
              ],

              // Service Provider Fields
              if (_selectedUserType == 'Service Provider') ...[
                _buildTextField(_experienceController, "Years of Experience", Icons.timeline,
                    keyboardType: TextInputType.number),
                _buildTextField(
                  _degreeController,
                  _selectedServiceProviderType == 'Chartered Accountant'
                      ? "CA Certificate Number"
                      : "Degree/Certification",
                  Icons.school,
                ),
              ],

              // Password Fields
              if (_selectedUserType != null) ...[
                _buildPasswordField(_passwordController, "Password"),
                _buildPasswordField(_confirmPasswordController, "Confirm Password",
                    validator: (value) {
                      if (value != _passwordController.text) {
                        return "Passwords don't match";
                      }
                      return null;
                    }),
              ],

              // Submit Button
              if (_selectedUserType != null) ...[
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[800],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Sign Up",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],

              // Sign In Link
              const SizedBox(height: 20),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account?"),
                    TextButton(
                      onPressed: widget.onToggleLogin,
                      child: const Text('Sign In'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller, 
    String label, 
    IconData icon, {
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        ),
        validator: (value) => value != null && value.isNotEmpty ? null : "Required",
      ),
    );
  }

  Widget _buildPasswordField(
    TextEditingController controller, 
    String label, {
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        obscureText: true,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.lock),
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        ),
        validator: validator ??
            (value) => value != null && value.length >= 6 ? null : "Minimum 6 characters",
      ),
    );
  }
}