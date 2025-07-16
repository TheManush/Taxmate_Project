import 'package:flutter/material.dart';
import 'api_service.dart';

class SendStatusUpdatePage extends StatefulWidget {
  final Map<String, dynamic> loanRequest;
  final ApiService apiService;

  const SendStatusUpdatePage({
    super.key,
    required this.loanRequest,
    required this.apiService,
  });

  @override
  State<SendStatusUpdatePage> createState() => _SendStatusUpdatePageState();
}

class _SendStatusUpdatePageState extends State<SendStatusUpdatePage> {
  String? _selectedStatus;
  final TextEditingController _noteController = TextEditingController();
  bool _isLoading = false;

  final List<Map<String, dynamic>> _statusOptions = [
    {
      'value': 'approved',
      'label': 'Approved',
      'icon': Icons.check_circle,
      'color': Colors.green,
      'description': 'Loan application has been approved'
    },
    {
      'value': 'rejected',
      'label': 'Rejected',
      'icon': Icons.cancel,
      'color': Colors.red,
      'description': 'Loan application has been rejected'
    },
    {
      'value': 'pending',
      'label': 'Pending',
      'icon': Icons.schedule,
      'color': Colors.orange,
      'description': 'Loan application is under review'
    },
    {
      'value': 'missing_info',
      'label': 'Missing Info',
      'icon': Icons.info_outline,
      'color': Colors.blue,
      'description': 'Additional information required'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Send Status Update'),
        backgroundColor: Colors.purple[700],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Loan Request Info Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.account_balance, color: Colors.purple[700], size: 24),
                        const SizedBox(width: 10),
                        Text(
                          'Loan Request Details',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    _buildInfoRow('Client', widget.loanRequest['full_name'] ?? 'N/A'),
                    const SizedBox(height: 8),
                    _buildInfoRow('Bank', widget.loanRequest['preferred_bank'] ?? 'N/A'),
                    const SizedBox(height: 8),
                    _buildInfoRow('Amount', '₹${_formatAmount(widget.loanRequest['requested_amount']?.toString() ?? '0')}'),
                    const SizedBox(height: 8),
                    _buildInfoRow('Purpose', widget.loanRequest['purpose_of_loan'] ?? 'N/A'),
                    const SizedBox(height: 8),
                    _buildInfoRow('Tenure', '${widget.loanRequest['loan_tenure'] ?? 'N/A'}'),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Status Selection Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.assignment_turned_in, color: Colors.purple[700], size: 24),
                        const SizedBox(width: 10),
                        Text(
                          'Select Status',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    ...(_statusOptions.map((option) => _buildStatusOption(option))),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Note Section Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.note_add, color: Colors.purple[700], size: 24),
                        const SizedBox(width: 10),
                        Text(
                          'Add Note',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: _noteController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Enter additional notes or comments...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.purple[700]!, width: 2),
                        ),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Send Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedStatus != null && !_isLoading ? _sendStatusUpdate : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  disabledBackgroundColor: Colors.grey[400],
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Send Status Update',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusOption(Map<String, dynamic> option) {
    final isSelected = _selectedStatus == option['value'];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedStatus = option['value'];
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? option['color'] : Colors.grey[300]!,
              width: isSelected ? 2 : 1,
            ),
            color: isSelected ? option['color'].withOpacity(0.1) : Colors.white,
          ),
          child: Row(
            children: [
              Radio<String>(
                value: option['value'],
                groupValue: _selectedStatus,
                onChanged: (value) {
                  setState(() {
                    _selectedStatus = value;
                  });
                },
                activeColor: option['color'],
              ),
              const SizedBox(width: 12),
              Icon(
                option['icon'],
                color: isSelected ? option['color'] : Colors.grey[600],
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option['label'],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? option['color'] : Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      option['description'],
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatAmount(String amount) {
    try {
      final num = double.parse(amount);
      if (num >= 10000000) {
        return '${(num / 10000000).toStringAsFixed(1)} Cr';
      } else if (num >= 100000) {
        return '${(num / 100000).toStringAsFixed(1)} L';
      } else if (num >= 1000) {
        return '${(num / 1000).toStringAsFixed(1)} K';
      } else {
        return num.toStringAsFixed(0);
      }
    } catch (e) {
      return amount;
    }
  }

  void _sendStatusUpdate() async {
    if (_selectedStatus == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await widget.apiService.updateLoanStatus(
        widget.loanRequest['id'],
        _selectedStatus!,
        _noteController.text.trim().isEmpty ? '' : _noteController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Status updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating status: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }
}
