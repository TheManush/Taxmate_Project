import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'api_service.dart';
import 'client_page_from_BLO.dart'; // You should create this page similar to client_page_from_CA
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'landing_page.dart';
import 'blo_profile_page.dart';
class BankLoanOfficerDashboard extends StatefulWidget {
  final int officerId;
  final String fullName;
  final String email;
  final String dob;
  final String gender;
  final String userType;
  final String? serviceProviderType;
  final ApiService apiService;

  const BankLoanOfficerDashboard({
    super.key,
    required this.officerId,
    required this.fullName,
    required this.email,
    required this.dob,
    required this.gender,
    required this.userType,
    this.serviceProviderType,
    required this.apiService,
  });

  @override
  _BankLoanOfficerDashboardState createState() => _BankLoanOfficerDashboardState();
}

class _BankLoanOfficerDashboardState extends State<BankLoanOfficerDashboard> {
  late Future<List<Map<String, dynamic>>> _pendingRequests;
  bool _showOnlyPending = false;

  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  void _fetchRequests() {
    setState(() {
      _pendingRequests = widget.apiService.fetchBankLoanOfficerRequests(widget.officerId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.serviceProviderType ?? 'Bank Loan Officer'} Dashboard'),
        backgroundColor: Colors.deepPurple[800],
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {},
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.deepPurple[800]!, Colors.deepPurple[600]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome, ${_getFirstName()}!",
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Check your loan filling requests",
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          'Client Requests',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text("Only Pending", 
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Transform.scale(
                              scale: 0.8,
                              child: Switch(
                                value: _showOnlyPending,
                                onChanged: (val) {
                                  setState(() {
                                    _showOnlyPending = val;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _buildRequestList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestList() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _pendingRequests,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text('No pending requests.');
        }

        List<Map<String, dynamic>> requests = List.from(snapshot.data!);
        if (_showOnlyPending) {
          requests = requests.where((req) => req['status'] == 'pending').toList();
        }
        if (requests.isEmpty) {
          return const Text('No matching requests to display.');
        }

        return Column(
          children: requests.map((req) {
            return Card(
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Client Avatar
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.deepPurple[700],
                          child: Text(
                            (req['client']['full_name'] ?? 'U').substring(0, 1).toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Client Name and Status
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                req['client']['full_name'],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                req['client']['email'] ?? '',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Status
                        Expanded(
                          flex: 1,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: req['status'] == 'pending'
                                  ? Colors.orange[100]
                                  : req['status'] == 'approved'
                                      ? Colors.green[100]
                                      : Colors.red[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              req['status'].toString().toUpperCase(),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: req['status'] == 'pending'
                                    ? Colors.orange[700]
                                    : req['status'] == 'approved'
                                        ? Colors.green[700]
                                        : Colors.red[700],
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Action Buttons for Pending Requests
                    if (req['status'] == 'pending') ...[
                      const SizedBox(height: 12),
                      const Divider(),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                await widget.apiService.updateBankLoanRequestStatus(
                                    req['id'], 'approved');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Request accepted')),
                                );
                                _fetchRequests();
                              },
                              icon: const Icon(Icons.check, size: 16),
                              label: const Text('Accept', style: TextStyle(fontSize: 12)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green[600],
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 8),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                await widget.apiService.updateBankLoanRequestStatus(
                                    req['id'], 'rejected');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Request rejected')),
                                );
                                _fetchRequests();
                              },
                              icon: const Icon(Icons.close, size: 16),
                              label: const Text('Reject', style: TextStyle(fontSize: 12)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red[600],
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  String _getFirstName() {
    return widget.fullName.split(' ').first;
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepPurple[800]!, Colors.deepPurple[600]!],
              ),
            ),
            accountName: Text(widget.fullName),
            accountEmail: Text(widget.email),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                _getFirstName()[0],
                style: TextStyle(fontSize: 24, color: Colors.deepPurple[800]),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.pending_actions),
            title: const Text("Pending Requests", style: TextStyle(fontWeight: FontWeight.bold)),
            selected: true,
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text("Clients", style: TextStyle(fontWeight: FontWeight.bold)),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ClientsPageFromBLO(
                    officerId: widget.officerId,
                    apiService: widget.apiService,
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text("My Profile", style: TextStyle(fontWeight: FontWeight.bold)),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => BLOProfilePage(
                    officerId: widget.officerId,
                    fullName: widget.fullName,
                    email: widget.email,
                    dob: widget.dob,
                    gender: widget.gender,
                    userType: widget.userType,
                    serviceProviderType: widget.serviceProviderType,
                    apiService: widget.apiService,
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.account_balance),
            title: const Text("Banks", style: TextStyle(fontWeight: FontWeight.bold)),
            onTap: () {
              Navigator.of(context).pop();
              _showBankOptions(context);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Logout", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            onTap: () async {
              final shouldLogout = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      child: const Text('Cancel'),
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                    TextButton(
                      child: const Text('Logout',
                          style: TextStyle(color: Colors.red)),
                      onPressed: () => Navigator.of(context).pop(true),
                    ),
                  ],
                ),
              );
              if (shouldLogout == true) {
                final storage = FlutterSecureStorage();
                await storage.deleteAll(); // Clear all saved login info
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) =>
                        LandingPage(apiBaseUrl: widget.apiService.baseUrl),
                  ),
                      (Route<dynamic> route) => false,
                );
              }
            },
          ),
        ],
      ),
    );
  }

  void _showBankOptions(BuildContext context) {
    final banks = [
      {
        'name': 'Dutch-Bangla Bank Limited (DBBL)',
        'shortName': 'DBBL',
        'url': 'https://www.dutchbanglabank.com',
        'email': 'info@dutchbanglabank.com',
        'color': Colors.blue[700],
      },
      {
        'name': 'BRAC Bank Limited',
        'shortName': 'BRAC Bank',
        'url': 'https://www.bracbank.com',
        'email': 'contact@bracbank.com',
        'color': Colors.green[700],
      },
      {
        'name': 'City Bank Limited',
        'shortName': 'City Bank',
        'url': 'https://www.thecitybank.com',
        'email': 'info@thecitybank.com',
        'color': Colors.red[700],
      },
      {
        'name': 'Eastern Bank Limited',
        'shortName': 'Eastern Bank',
        'url': 'https://www.ebl.com.bd',
        'email': 'info@ebl.com.bd',
        'color': Colors.orange[700],
      },
      {
        'name': 'Standard Chartered Bank',
        'shortName': 'Standard Chartered',
        'url': 'https://www.sc.com/bd',
        'email': 'bangladesh.info@sc.com',
        'color': Colors.indigo[700],
      },
    ];

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(Icons.account_balance, color: Colors.deepPurple[700], size: 28),
                  const SizedBox(width: 12),
                  const Text(
                    'Select Bank',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.red),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ...banks.map((bank) => _buildBankCard(context, bank)).toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBankCard(BuildContext context, Map<String, dynamic> bank) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: bank['color'],
          child: Text(
            bank['shortName'].substring(0, 1),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          bank['shortName'],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          bank['name'],
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.pop(context);
          _showBankDetails(context, bank);
        },
      ),
    );
  }

  void _showBankDetails(BuildContext context, Map<String, dynamic> bank) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Bank Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: bank['color'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: bank['color'],
                      radius: 24,
                      child: Text(
                        bank['shortName'].substring(0, 1),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            bank['shortName'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            bank['name'],
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Bank Details
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.web, color: Colors.grey[600], size: 20),
                        const SizedBox(width: 8),
                        const Text('Website:', style: TextStyle(fontWeight: FontWeight.w500)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(bank['url'], style: TextStyle(color: Colors.blue[700])),
                    
                    const SizedBox(height: 12),
                    
                    Row(
                      children: [
                        Icon(Icons.email, color: Colors.grey[600], size: 20),
                        const SizedBox(width: 8),
                        const Text('Email:', style: TextStyle(fontWeight: FontWeight.w500)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(bank['email'], style: TextStyle(color: Colors.grey[700])),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, size: 18, color: Colors.red),
                      label: const Text('Close', style: TextStyle(color: Colors.red)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: Colors.red),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: () => _launchBankPortal(bank['url']),
                      icon: const Icon(Icons.open_in_browser, size: 18),
                      label: const Text('Open Bank Portal'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: bank['color'],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 2,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchBankPortal(String url) async {
    try {
      // Ensure URL has proper scheme
      String formattedUrl = url;
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        formattedUrl = 'https://$url';
      }
      
      final uri = Uri.parse(formattedUrl);
      print('Attempting to launch: $formattedUrl'); // Debug print
      
      // Check if URL can be launched
      final canLaunch = await canLaunchUrl(uri);
      print('Can launch URL: $canLaunch'); // Debug print
      
      if (!canLaunch) {
        throw 'Cannot launch this URL. Your device may not have a web browser installed.';
      }
      
      // Try different launch modes in sequence
      bool launched = false;
      
      try {
        // Try platform default first (usually most reliable)
        launched = await launchUrl(uri, mode: LaunchMode.platformDefault);
        print('Platform default launch: $launched');
      } catch (e) {
        print('Platform default failed: $e');
      }
      
      if (!launched) {
        try {
          // Try external application
          launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
          print('External app launch: $launched');
        } catch (e) {
          print('External app failed: $e');
        }
      }
      
      if (!launched) {
        try {
          // Try in-app web view as last resort
          launched = await launchUrl(uri, mode: LaunchMode.inAppWebView);
          print('In-app web view launch: $launched');
        } catch (e) {
          print('In-app web view failed: $e');
        }
      }
      
      if (!launched) {
        throw 'Failed to open $formattedUrl in any browser mode. Please try copying the URL and opening it manually.';
      }
      
    } catch (e) {
      print('Launch error: $e'); // Debug print
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Copy URL',
              textColor: Colors.white,
              onPressed: () {
                Clipboard.setData(ClipboardData(text: url));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Bank URL copied to clipboard - paste in your browser'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 3),
                  ),
                );
              },
            ),
          ),
        );
      }
    }
  }
}
