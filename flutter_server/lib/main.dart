import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'landing_page.dart';
import 'api_service.dart';
import 'client_dashboard.dart';
import 'admin.dart';
import 'ca_dashboard.dart';
import 'blo_dashboard.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_notifications.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(FirebaseNotifications.backgroundHandler);

  await FirebaseNotifications.initialize();
  final storage = FlutterSecureStorage(
    aOptions: const AndroidOptions(encryptedSharedPreferences: true),
  );

  runApp(MyApp(storage: storage));
}

class MyApp extends StatelessWidget {
  final FlutterSecureStorage storage;
  //final String apiBaseUrl = 'http://192.168.0.101:8000';
  final String apiBaseUrl = 'http://10.0.2.2:8000';
  const MyApp({super.key, required this.storage});

  Future<Widget> _determineStartScreen() async {
    String? id = await storage.read(key: 'id');
    String? fullName = await storage.read(key: 'full_name');
    String? email = await storage.read(key: 'email');
    String? dob = await storage.read(key: 'dob');
    String? gender = await storage.read(key: 'gender');
    String? userType = await storage.read(key: 'user_type');
    String? clientType = await storage.read(key: 'client_type');
    String? serviceProviderType = await storage.read(key: 'service_provider_type');

    final apiService = ApiService(apiBaseUrl);

    if (id != null && fullName != null && email != null && userType != null) {
      int userId = int.tryParse(id) ?? -1;

      if (userType == 'client') {
        return ClientDashboard(
          clientId: userId,
          fullName: fullName,
          email: email,
          dob: dob ?? '',
          gender: gender ?? '',
          userType: userType,
          clientType: clientType ?? '',
          apiService: apiService,
        );
      } else if (userType == 'admin') {
        return AdminDashboard(
          adminId: userId,
          fullName: fullName,
          email: email,
          dob: dob ?? '',
          gender: gender ?? '',
          userType: userType,
          serviceProviderType: serviceProviderType,
          apiService: apiService,
        );
      } else if (userType == 'service_provider') {
        final normalized = (serviceProviderType ?? '').toLowerCase().replaceAll(' ', '_');
        if (normalized == 'chartered_accountant') {
          return CAdashboard(
            caId: userId,
            fullName: fullName,
            email: email,
            dob: dob ?? '',
            gender: gender ?? '',
            userType: userType,
            serviceProviderType: serviceProviderType,
            apiService: apiService,
          );
        } else if (normalized == 'bank_loan_officer') {
          return BankLoanOfficerDashboard(
            officerId: userId,
            fullName: fullName,
            email: email,
            dob: dob ?? '',
            gender: gender ?? '',
            userType: userType,
            serviceProviderType: serviceProviderType,
            apiService: apiService,
          );
        }
      }
    }

    // If no saved user or error, show landing page
    return LandingPage(apiBaseUrl: apiBaseUrl);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Financial & Tax Services',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<Widget>(
        future: _determineStartScreen(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return snapshot.data!;
          } else {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
        },
      ),
    );
  }
}
