import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'api_service.dart';

class LoanRequestFormPage extends StatefulWidget {
  final Map<String, dynamic> bloData;
  final int clientId;
  final ApiService apiService;

  const LoanRequestFormPage({
    super.key,
    required this.bloData,
    required this.clientId,
    required this.apiService,
  });

  @override
  State<LoanRequestFormPage> createState() => _LoanRequestFormPageState();
}

class _LoanRequestFormPageState extends State<LoanRequestFormPage> {
  final _formKey = GlobalKey<FormState>();
  
  // Personal Info Controllers
  final _nameController = TextEditingController();
  final _dobController = TextEditingController();
  final _nidController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  
  // Business Info Controllers
  String _employmentType = 'salaried';
  final _companyNameController = TextEditingController();
  final _designationController = TextEditingController();
  final _monthlyIncomeController = TextEditingController();
  final _employmentLengthController = TextEditingController();
  
  // Loan Details Controllers
  final _loanTypeController = TextEditingController();
  final _requestedAmountController = TextEditingController();
  final _loanTenureController = TextEditingController();
  final _purposeController = TextEditingController();
  String _preferredBank = 'DBBL';
  
  // Additional Info Controllers
  final _guarantorNameController = TextEditingController();
  final _guarantorNidController = TextEditingController();
  final _guarantorPhoneController = TextEditingController();
  final _collateralController = TextEditingController();
  final _notesController = TextEditingController();

  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Loan Request Form'),
        backgroundColor: Colors.purple[700],
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.account_balance, 
                           color: Colors.purple[700], size: 32),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Loan Application',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Bank Loan Officer: ${widget.bloData['full_name']}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // 1. Personal Information
              _buildSection(
                title: 'Personal Info',
                icon: Icons.person,
                children: [
                  _buildTextField('Full Name', _nameController, required: true),
                  _buildDateField('Date of Birth', _dobController, required: true),
                  _buildTextField('NID Number', _nidController, required: true),
                  _buildTextField('Phone Number', _phoneController, 
                                 keyboardType: TextInputType.phone, required: true),
                  _buildTextField('Email', _emailController, 
                                 keyboardType: TextInputType.emailAddress, required: true),
                  _buildTextField('Present Address', _addressController, 
                                 maxLines: 3, required: true),
                ],
              ),
              
              // 2. Business Information
              _buildSection(
                title: 'Business Info',
                icon: Icons.work,
                children: [
                  _buildDropdown(
                    'Employment Type',
                    _employmentType,
                    ['salaried', 'self-employed', 'business owner', 'freelancer'],
                    (value) => setState(() => _employmentType = value!),
                  ),
                  if (_employmentType == 'salaried') 
                    _buildTextField('Company Name', _companyNameController),
                  if (_employmentType == 'salaried') 
                    _buildTextField('Designation', _designationController),
                  _buildTextField('Monthly Income (BDT)', _monthlyIncomeController, 
                                 keyboardType: TextInputType.number, required: true),
                  _buildTextField('Length of Employment', _employmentLengthController, 
                                 hintText: 'e.g., 2 years 6 months', required: true),
                ],
              ),
              
              // 3. Loan Details
              _buildSection(
                title: 'Loan Details',
                icon: Icons.money,
                children: [
                  _buildTextField('Loan Type', _loanTypeController, 
                                 hintText: 'e.g., Personal Loan, Home Loan', required: true),
                  _buildTextField('Requested Amount (BDT)', _requestedAmountController, 
                                 keyboardType: TextInputType.number, required: true),
                  _buildTextField('Loan Tenure', _loanTenureController, 
                                 hintText: 'e.g., 5 years', required: true),
                  _buildTextField('Purpose of Loan', _purposeController, 
                                 maxLines: 2, required: true),
                  _buildDropdown(
                    'Preferred Bank',
                    _preferredBank,
                    ['DBBL', 'BRAC Bank', 'Eastern Bank', 'City Bank', 'Standard Chartered'],
                    (value) => setState(() => _preferredBank = value!),
                  ),
                ],
              ),
              
              // 4. Additional Information
              _buildSection(
                title: 'Additional Info (Optional)',
                icon: Icons.info,
                children: [
                  _buildTextField('Guarantor Name', _guarantorNameController),
                  _buildTextField('Guarantor NID', _guarantorNidController),
                  _buildTextField('Guarantor Phone', _guarantorPhoneController, 
                                 keyboardType: TextInputType.phone),
                  _buildTextField('Collateral Information', _collateralController, 
                                 maxLines: 2),
                  _buildTextField('Notes/Remarks', _notesController, maxLines: 3),
                ],
              ),
              
              const SizedBox(height: 30),
              
              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _submitForm,
                  icon: _isSubmitting 
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send),
                  label: Text(_isSubmitting ? 'Submitting...' : 'Submit Loan Request'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple[700],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.purple[700], size: 24),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children.map((child) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: child,
            )).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    TextInputType? keyboardType,
    int maxLines = 1,
    String? hintText,
    bool required = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      validator: required ? (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        return null;
      } : null,
    );
  }

  Widget _buildDateField(String label, TextEditingController controller, {bool required = false}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
        hintText: 'YYYY-MM-DD',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        suffixIcon: const Icon(Icons.calendar_today),
      ),
      readOnly: true,
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: DateTime.now().subtract(const Duration(days: 6570)), // 18 years ago
          firstDate: DateTime(1950),
          lastDate: DateTime.now(),
        );
        if (date != null) {
          controller.text = date.toString().split(' ')[0];
        }
      },
      validator: required ? (value) {
        if (value == null || value.isEmpty) {
          return 'Please select $label';
        }
        return null;
      } : null,
    );
  }

  Widget _buildDropdown(
    String label,
    String value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      items: items.map((item) => DropdownMenuItem(
        value: item,
        child: Text(item),
      )).toList(),
      onChanged: onChanged,
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final loanRequest = {
        'blo_id': widget.bloData['id'],
        'full_name': _nameController.text,
        'date_of_birth': _dobController.text,
        'nid_number': _nidController.text,
        'phone_number': _phoneController.text,
        'email': _emailController.text,
        'present_address': _addressController.text,
        'employment_type': _employmentType,
        'company_name': _companyNameController.text.isNotEmpty ? _companyNameController.text : null,
        'designation': _designationController.text.isNotEmpty ? _designationController.text : null,
        'monthly_income': double.parse(_monthlyIncomeController.text),
        'length_of_employment': _employmentLengthController.text,
        'loan_type': _loanTypeController.text,
        'requested_amount': double.parse(_requestedAmountController.text),
        'loan_tenure': _loanTenureController.text,
        'purpose_of_loan': _purposeController.text,
        'preferred_bank': _preferredBank,
        'guarantor_name': _guarantorNameController.text.isNotEmpty ? _guarantorNameController.text : null,
        'guarantor_nid': _guarantorNidController.text.isNotEmpty ? _guarantorNidController.text : null,
        'guarantor_phone': _guarantorPhoneController.text.isNotEmpty ? _guarantorPhoneController.text : null,
        'collateral_info': _collateralController.text.isNotEmpty ? _collateralController.text : null,
        'notes_remarks': _notesController.text.isNotEmpty ? _notesController.text : null,
      };

      final response = await widget.apiService.submitLoanRequest(widget.clientId, loanRequest);
      
      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Loan request submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        throw Exception('Failed to submit loan request');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    _nidController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _companyNameController.dispose();
    _designationController.dispose();
    _monthlyIncomeController.dispose();
    _employmentLengthController.dispose();
    _loanTypeController.dispose();
    _requestedAmountController.dispose();
    _loanTenureController.dispose();
    _purposeController.dispose();
    _guarantorNameController.dispose();
    _guarantorNidController.dispose();
    _guarantorPhoneController.dispose();
    _collateralController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
