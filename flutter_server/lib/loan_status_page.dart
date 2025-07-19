import 'package:flutter/material.dart';
import 'api_service.dart';

class LoanStatusPage extends StatelessWidget {
  final Map<String, dynamic> loanStatus;
  final int clientId;
  final Map<String, dynamic> bloData;
  final ApiService apiService;

  const LoanStatusPage({
    super.key,
    required this.loanStatus,
    required this.clientId,
    required this.bloData,
    required this.apiService,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Loan Status'),
        backgroundColor: Colors.purple[700],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Status Header
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.purple[100],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  children: [
                    // Status Box (similar to profile avatar)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: _getStatusColor(loanStatus['status']),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Icon(
                            _getStatusIcon(loanStatus['status']),
                            size: 60,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _getStatusDisplayName(loanStatus['status']),
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Status description outside the box
                    Text(
                      _getStatusDescription(loanStatus['status']),
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.purple[800],
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Loan Details Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.account_balance, color: Colors.purple[700], size: 28),
                          const SizedBox(width: 12),
                          const Text(
                            'Loan Details',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 20),
                      
                      _buildDetailRow(
                        'Last Updated',
                        _formatDate(loanStatus['updated_at']),
                        Icons.schedule,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      _buildDetailRow(
                        'Bank',
                        loanStatus['preferred_bank'] ?? 'Not specified',
                        Icons.business,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      _buildDetailRow(
                        'Loan Amount',
                        'BDT ${_formatAmount(loanStatus['requested_amount'])}',
                        Icons.monetization_on,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      _buildDetailRow(
                        'Purpose',
                        loanStatus['purpose_of_loan'] ?? 'Not specified',
                        Icons.description,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      _buildDetailRow(
                        'Tenure',
                        loanStatus['loan_tenure'] ?? 'Not specified',
                        Icons.timer,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Status & Note Card
            const SizedBox(height: 16),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _getStatusIcon(loanStatus['status']),
                            color: _getStatusColor(loanStatus['status']),
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Status & Notes',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Status
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _getStatusColor(loanStatus['status']).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _getStatusColor(loanStatus['status']).withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.flag,
                                  color: _getStatusColor(loanStatus['status']),
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Status',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _getStatusDisplayName(loanStatus['status']),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: _getStatusColor(loanStatus['status']),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Note Section
                      if (loanStatus['message'] != null && loanStatus['message'].toString().isNotEmpty) ...[
                        const SizedBox(height: 16),
                        
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.blue[200]!),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.note, color: Colors.blue[700], size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Note from Bank Loan Officer',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                loanStatus['message'].toString(),
                                style: const TextStyle(
                                  fontSize: 16,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        const SizedBox(height: 16),
                        
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.note_outlined, color: Colors.grey[400], size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'No additional notes provided',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[600], size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatAmount(dynamic amount) {
    if (amount == null) return '0';
    final num amountNum = num.tryParse(amount.toString()) ?? 0;
    return amountNum.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Not updated';
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);
      
      if (difference.inDays == 0) {
        return 'Today';
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return 'Invalid date';
    }
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'approved': return Colors.green;
      case 'rejected': return Colors.red;
      case 'pending': return Colors.orange;
      case 'missing_info': return Colors.blue;
      default: return Colors.grey;
    }
  }

  IconData _getStatusIcon(String? status) {
    switch (status) {
      case 'approved': return Icons.check_circle;
      case 'rejected': return Icons.cancel;
      case 'pending': return Icons.schedule;
      case 'missing_info': return Icons.info;
      default: return Icons.help;
    }
  }

  String _getStatusDisplayName(String? status) {
    switch (status) {
      case 'approved': return 'Approved';
      case 'rejected': return 'Rejected';
      case 'pending': return 'Pending';
      case 'missing_info': return 'Missing Information';
      default: return 'Unknown Status';
    }
  }

  String _getStatusDescription(String? status) {
    switch (status) {
      case 'approved': return 'Your loan application has been approved by the bank';
      case 'rejected': return 'Your loan application has been rejected by the bank';
      case 'pending': return 'Your application is being processed by the bank';
      case 'missing_info': return 'Additional information is required to process your application';
      default: return 'Status information is not available';
    }
  }
}
