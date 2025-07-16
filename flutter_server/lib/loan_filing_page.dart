import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'api_service.dart';
import 'send_status_update.dart';

class LoanFilingPage extends StatefulWidget {
  final int officerId;
  final int? clientId; // Optional - if provided, shows requests from specific client
  final ApiService apiService;

  const LoanFilingPage({
    super.key,
    required this.officerId,
    this.clientId,
    required this.apiService,
  });

  @override
  State<LoanFilingPage> createState() => _LoanFilingPageState();
}

class _LoanFilingPageState extends State<LoanFilingPage> {
  late Future<List<Map<String, dynamic>>> _loanRequestsFuture;

  @override
  void initState() {
    super.initState();
    _loanRequestsFuture = widget.apiService.getLoanRequestsForBLO(widget.officerId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.clientId != null 
          ? 'Client Loan Requests' 
          : 'All Loan Requests'),
        backgroundColor: Colors.deepPurple[800],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _loanRequestsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _loanRequestsFuture = widget.apiService.getLoanRequestsForBLO(widget.officerId);
                      });
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text(
                    'No loan requests found',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Loan applications will appear here when clients submit them',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          List<Map<String, dynamic>> loanRequests = snapshot.data!;
          
          // Filter by client if clientId is provided
          if (widget.clientId != null) {
            loanRequests = loanRequests.where((request) => 
              request['client_id'] == widget.clientId).toList();
          }

          if (loanRequests.isEmpty && widget.clientId != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text(
                    'No loan requests from this client',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Header Stats
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.deepPurple[800]!, Colors.deepPurple[600]!],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              '${loanRequests.length}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const Text(
                              'Total Requests',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                      Container(width: 1, height: 40, color: Colors.white24),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              '${loanRequests.where((r) => r['status'] == 'pending').length}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const Text(
                              'Pending',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Loan Requests List
                ...loanRequests.map((request) => _buildLoanRequestCard(request)).toList(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoanRequestCard(Map<String, dynamic> request) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with client info and status
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.deepPurple[800],
                  radius: 20,
                  child: Text(
                    request['full_name']?.substring(0, 1).toUpperCase() ?? 'U',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request['full_name'] ?? 'Unknown',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        request['email'] ?? '',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(request['status']),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    (request['status'] ?? 'pending').toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            const Divider(),
            
            // Loan Details
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem('Loan Type', request['loan_type'] ?? 'N/A'),
                ),
                Expanded(
                  child: _buildInfoItem('Amount', 'BDT ${_formatAmount(request['requested_amount'])}'),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem('Bank', request['preferred_bank'] ?? 'N/A'),
                ),
                Expanded(
                  child: _buildInfoItem('Tenure', request['loan_tenure'] ?? 'N/A'),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showLoanRequestDetails(request),
                    icon: const Icon(Icons.visibility, size: 16),
                    label: const Text('View Details'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.deepPurple[800],
                      side: BorderSide(color: Colors.deepPurple[800]!),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _downloadLoanRequest(request),
                    icon: const Icon(Icons.download, size: 16),
                    label: const Text('Download'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple[800],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Status Update Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _navigateToStatusUpdate(request),
                icon: const Icon(Icons.update, size: 16),
                label: const Text('Send Status Update'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.orange[700],
                  side: BorderSide(color: Colors.orange[700]!),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'under_review':
        return Colors.blue;
      case 'pending':
        return Colors.orange;
      case 'missing_info':
        return Colors.blue;
      default:
        return Colors.orange;
    }
  }

  String _formatAmount(dynamic amount) {
    if (amount == null) return '0';
    if (amount is String) {
      try {
        amount = double.parse(amount);
      } catch (e) {
        return amount;
      }
    }
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  void _showLoanRequestDetails(Map<String, dynamic> request) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => _buildDetailSheet(request, scrollController),
      ),
    );
  }

  Widget _buildDetailSheet(Map<String, dynamic> request, ScrollController scrollController) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        controller: scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Title
            Text(
              'Loan Request Details',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple[800],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Personal Information
            _buildDetailSection('Personal Information', [
              'Full Name: ${request['full_name'] ?? 'N/A'}',
              'Date of Birth: ${request['date_of_birth'] ?? 'N/A'}',
              'NID Number: ${request['nid_number'] ?? 'N/A'}',
              'Phone: ${request['phone_number'] ?? 'N/A'}',
              'Email: ${request['email'] ?? 'N/A'}',
              'Address: ${request['present_address'] ?? 'N/A'}',
            ]),
            
            // Business Information
            _buildDetailSection('Business Information', [
              'Employment Type: ${request['employment_type'] ?? 'N/A'}',
              if (request['company_name'] != null) 'Company: ${request['company_name']}',
              if (request['designation'] != null) 'Designation: ${request['designation']}',
              'Monthly Income: BDT ${_formatAmount(request['monthly_income'])}',
              'Length of Employment: ${request['length_of_employment'] ?? 'N/A'}',
            ]),
            
            // Loan Details
            _buildDetailSection('Loan Details', [
              'Loan Type: ${request['loan_type'] ?? 'N/A'}',
              'Requested Amount: BDT ${_formatAmount(request['requested_amount'])}',
              'Loan Tenure: ${request['loan_tenure'] ?? 'N/A'}',
              'Purpose: ${request['purpose_of_loan'] ?? 'N/A'}',
              'Preferred Bank: ${request['preferred_bank'] ?? 'N/A'}',
            ]),
            
            // Additional Information
            if (request['guarantor_name'] != null || 
                request['collateral_info'] != null || 
                request['notes_remarks'] != null)
              _buildDetailSection('Additional Information', [
                if (request['guarantor_name'] != null) 'Guarantor: ${request['guarantor_name']}',
                if (request['guarantor_nid'] != null) 'Guarantor NID: ${request['guarantor_nid']}',
                if (request['guarantor_phone'] != null) 'Guarantor Phone: ${request['guarantor_phone']}',
                if (request['collateral_info'] != null) 'Collateral: ${request['collateral_info']}',
                if (request['notes_remarks'] != null) 'Notes: ${request['notes_remarks']}',
              ]),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: items.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(item),
            )).toList(),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  void _downloadLoanRequest(Map<String, dynamic> request) {
    // Show PDF preview with save/print options
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PdfPreviewPage(
          request: request,
          formatAmount: _formatAmount,
        ),
      ),
    );
  }

  Future<pw.Document> _generatePDF(Map<String, dynamic> request) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Header
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'LOAN REQUEST DETAILS',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.purple700,
                    ),
                  ),
                  pw.Text(
                    'ID: ${request['id'] ?? 'N/A'}',
                    style: pw.TextStyle(fontSize: 12, color: PdfColors.grey600),
                  ),
                ],
              ),
            ),
            
            pw.SizedBox(height: 20),
            
            // Personal Information Section
            _buildPDFSection('PERSONAL INFORMATION', [
              ['Full Name', request['full_name'] ?? 'N/A'],
              ['Date of Birth', request['date_of_birth'] ?? 'N/A'],
              ['NID Number', request['nid_number'] ?? 'N/A'],
              ['Phone Number', request['phone_number'] ?? 'N/A'],
              ['Email', request['email'] ?? 'N/A'],
              ['Present Address', request['present_address'] ?? 'N/A'],
            ]),
            
            pw.SizedBox(height: 20),
            
            // Business Information Section
            _buildPDFSection('BUSINESS INFORMATION', [
              ['Employment Type', request['employment_type'] ?? 'N/A'],
              ['Company Name', request['company_name'] ?? 'N/A'],
              ['Designation', request['designation'] ?? 'N/A'],
              ['Monthly Income', 'BDT ${_formatAmount(request['monthly_income'])}'],
              ['Length of Employment', request['length_of_employment'] ?? 'N/A'],
            ]),
            
            pw.SizedBox(height: 20),
            
            // Loan Details Section
            _buildPDFSection('LOAN DETAILS', [
              ['Loan Type', request['loan_type'] ?? 'N/A'],
              ['Requested Amount', 'BDT ${_formatAmount(request['requested_amount'])}'],
              ['Loan Tenure', request['loan_tenure'] ?? 'N/A'],
              ['Purpose of Loan', request['purpose_of_loan'] ?? 'N/A'],
              ['Preferred Bank', request['preferred_bank'] ?? 'N/A'],
            ]),
            
            pw.SizedBox(height: 20),
            
            // Additional Information Section
            if (request['guarantor_name'] != null || 
                request['collateral_info'] != null || 
                request['notes_remarks'] != null)
              _buildPDFSection('ADDITIONAL INFORMATION', [
                if (request['guarantor_name'] != null) 
                  ['Guarantor Name', request['guarantor_name']],
                if (request['guarantor_nid'] != null) 
                  ['Guarantor NID', request['guarantor_nid']],
                if (request['guarantor_phone'] != null) 
                  ['Guarantor Phone', request['guarantor_phone']],
                if (request['collateral_info'] != null) 
                  ['Collateral Information', request['collateral_info']],
                if (request['notes_remarks'] != null) 
                  ['Notes/Remarks', request['notes_remarks']],
              ]),
            
            pw.SizedBox(height: 30),
            
            // Status Information
            _buildPDFSection('REQUEST STATUS', [
              ['Status', (request['status'] ?? 'pending').toUpperCase()],
              ['Submitted', request['created_at'] ?? 'N/A'],
              if (request['updated_at'] != null) 
                ['Last Updated', request['updated_at']],
            ]),
            
            pw.SizedBox(height: 40),
            
            // Footer
            pw.Divider(),
            pw.SizedBox(height: 10),
            pw.Center(
              child: pw.Text(
                'Generated by Taxmate App - BLO Dashboard\nDocument generated on ${DateTime.now().toString().split('.')[0]}',
                style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                textAlign: pw.TextAlign.center,
              ),
            ),
          ];
        },
      ),
    );

    return pdf;
  }

  pw.Widget _buildPDFSection(String title, List<List<String>> items) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.all(8),
          decoration: pw.BoxDecoration(
            color: PdfColors.purple50,
            border: pw.Border.all(color: PdfColors.purple200),
          ),
          child: pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.purple700,
            ),
          ),
        ),
        pw.Container(
          width: double.infinity,
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey300),
          ),
          child: pw.Table(
            children: items.map((item) => pw.TableRow(
              children: [
                pw.Container(
                  padding: const pw.EdgeInsets.all(8),
                  decoration: pw.BoxDecoration(
                    border: pw.Border(right: pw.BorderSide(color: PdfColors.grey300)),
                  ),
                  child: pw.Text(
                    item[0],
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
                  ),
                ),
                pw.Container(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text(
                    item[1],
                    style: const pw.TextStyle(fontSize: 12),
                  ),
                ),
              ],
            )).toList(),
          ),
        ),
      ],
    );
  }

  void _navigateToStatusUpdate(Map<String, dynamic> request) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SendStatusUpdatePage(
          loanRequest: request,
          apiService: widget.apiService,
        ),
      ),
    );
    
    // If status was updated successfully, refresh the page
    if (result == true) {
      setState(() {
        _loanRequestsFuture = widget.apiService.getLoanRequestsForBLO(widget.officerId);
      });
    }
  }
}

// PDF Preview Page
class PdfPreviewPage extends StatelessWidget {
  final Map<String, dynamic> request;
  final String Function(dynamic) formatAmount;

  const PdfPreviewPage({
    super.key,
    required this.request,
    required this.formatAmount,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Loan Request PDF'),
        backgroundColor: Colors.deepPurple[800],
        foregroundColor: Colors.white,
      ),
      body: PdfPreview(
        build: (format) => _generatePDF(),
        allowPrinting: true,
        allowSharing: true,
        canChangePageFormat: false,
        canChangeOrientation: false,
        canDebug: false,
        actions: [
          PdfPreviewAction(
            icon: const Icon(Icons.copy),
            onPressed: (context, build, pageFormat) async {
              final text = _generateTextVersion();
              await Clipboard.setData(ClipboardData(text: text));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Loan request data copied to clipboard'),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<Uint8List> _generatePDF() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Header
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'LOAN REQUEST DETAILS',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.purple700,
                  ),
                ),
                pw.Text(
                  'ID: ${request['id'] ?? 'N/A'}',
                  style: pw.TextStyle(fontSize: 12, color: PdfColors.grey600),
                ),
              ],
            ),
            
            pw.SizedBox(height: 20),
            
            // Personal Information Section
            _buildPDFSection('PERSONAL INFORMATION', [
              ['Full Name', request['full_name'] ?? 'N/A'],
              ['Date of Birth', request['date_of_birth'] ?? 'N/A'],
              ['NID Number', request['nid_number'] ?? 'N/A'],
              ['Phone Number', request['phone_number'] ?? 'N/A'],
              ['Email', request['email'] ?? 'N/A'],
              ['Present Address', request['present_address'] ?? 'N/A'],
            ]),
            
            pw.SizedBox(height: 20),
            
            // Business Information Section
            _buildPDFSection('BUSINESS INFORMATION', [
              ['Employment Type', request['employment_type'] ?? 'N/A'],
              ['Company Name', request['company_name'] ?? 'N/A'],
              ['Designation', request['designation'] ?? 'N/A'],
              ['Monthly Income', 'BDT ${formatAmount(request['monthly_income'])}'],
              ['Length of Employment', request['length_of_employment'] ?? 'N/A'],
            ]),
            
            pw.SizedBox(height: 20),
            
            // Loan Details Section
            _buildPDFSection('LOAN DETAILS', [
              ['Loan Type', request['loan_type'] ?? 'N/A'],
              ['Requested Amount', 'BDT ${formatAmount(request['requested_amount'])}'],
              ['Loan Tenure', request['loan_tenure'] ?? 'N/A'],
              ['Purpose of Loan', request['purpose_of_loan'] ?? 'N/A'],
              ['Preferred Bank', request['preferred_bank'] ?? 'N/A'],
            ]),
            
            pw.SizedBox(height: 20),
            
            // Additional Information Section
            if (request['guarantor_name'] != null || 
                request['collateral_info'] != null || 
                request['notes_remarks'] != null)
              _buildPDFSection('ADDITIONAL INFORMATION', [
                if (request['guarantor_name'] != null) 
                  ['Guarantor Name', request['guarantor_name']],
                if (request['guarantor_nid'] != null) 
                  ['Guarantor NID', request['guarantor_nid']],
                if (request['guarantor_phone'] != null) 
                  ['Guarantor Phone', request['guarantor_phone']],
                if (request['collateral_info'] != null) 
                  ['Collateral Information', request['collateral_info']],
                if (request['notes_remarks'] != null) 
                  ['Notes/Remarks', request['notes_remarks']],
              ]),
            
            pw.SizedBox(height: 30),
            
            // Status Information
            _buildPDFSection('REQUEST STATUS', [
              ['Status', (request['status'] ?? 'pending').toUpperCase()],
              ['Submitted', request['created_at'] ?? 'N/A'],
              if (request['updated_at'] != null) 
                ['Last Updated', request['updated_at']],
            ]),
            
            pw.SizedBox(height: 40),
            
            // Footer
            pw.Divider(),
            pw.SizedBox(height: 10),
            pw.Center(
              child: pw.Text(
                'Generated by Taxmate App - BLO Dashboard\nDocument generated on ${DateTime.now().toString().split('.')[0]}',
                style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                textAlign: pw.TextAlign.center,
              ),
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildPDFSection(String title, List<List<String>> items) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.all(8),
          decoration: pw.BoxDecoration(
            color: PdfColors.purple50,
            border: pw.Border.all(color: PdfColors.purple200),
          ),
          child: pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.purple700,
            ),
          ),
        ),
        pw.Container(
          width: double.infinity,
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey300),
          ),
          child: pw.Table(
            children: items.map((item) => pw.TableRow(
              children: [
                pw.Container(
                  padding: const pw.EdgeInsets.all(8),
                  decoration: pw.BoxDecoration(
                    border: pw.Border(right: pw.BorderSide(color: PdfColors.grey300)),
                  ),
                  child: pw.Text(
                    item[0],
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
                  ),
                ),
                pw.Container(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text(
                    item[1],
                    style: const pw.TextStyle(fontSize: 12),
                  ),
                ),
              ],
            )).toList(),
          ),
        ),
      ],
    );
  }

  String _generateTextVersion() {
    return '''
LOAN REQUEST DETAILS
==========================================

PERSONAL INFORMATION:
---------------------
Full Name: ${request['full_name'] ?? 'N/A'}
Date of Birth: ${request['date_of_birth'] ?? 'N/A'}
NID Number: ${request['nid_number'] ?? 'N/A'}
Phone Number: ${request['phone_number'] ?? 'N/A'}
Email: ${request['email'] ?? 'N/A'}
Present Address: ${request['present_address'] ?? 'N/A'}

BUSINESS INFORMATION:
--------------------
Employment Type: ${request['employment_type'] ?? 'N/A'}
Company Name: ${request['company_name'] ?? 'N/A'}
Designation: ${request['designation'] ?? 'N/A'}
Monthly Income: BDT ${formatAmount(request['monthly_income'])}
Length of Employment: ${request['length_of_employment'] ?? 'N/A'}

LOAN DETAILS:
-------------
Loan Type: ${request['loan_type'] ?? 'N/A'}
Requested Amount: BDT ${formatAmount(request['requested_amount'])}
Loan Tenure: ${request['loan_tenure'] ?? 'N/A'}
Purpose of Loan: ${request['purpose_of_loan'] ?? 'N/A'}
Preferred Bank: ${request['preferred_bank'] ?? 'N/A'}

ADDITIONAL INFORMATION:
----------------------
Guarantor Name: ${request['guarantor_name'] ?? 'N/A'}
Guarantor NID: ${request['guarantor_nid'] ?? 'N/A'}
Guarantor Phone: ${request['guarantor_phone'] ?? 'N/A'}
Collateral Information: ${request['collateral_info'] ?? 'N/A'}
Notes/Remarks: ${request['notes_remarks'] ?? 'N/A'}

REQUEST STATUS:
--------------
Status: ${request['status'] ?? 'pending'}
Submitted: ${request['created_at'] ?? 'N/A'}

==========================================
Generated by Taxmate App - BLO Dashboard
==========================================
''';
  }
}
