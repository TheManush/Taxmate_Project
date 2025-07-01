import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'landing_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storage = FlutterSecureStorage(
    aOptions: const AndroidOptions(encryptedSharedPreferences: true),
  );

  runApp(MyApp(storage: storage));
}

class MyApp extends StatelessWidget {
  final FlutterSecureStorage storage;
  final String apiBaseUrl = 'http://<YOUR_LOCAL_IP>:8000'; // For Android emulator

  const MyApp({super.key, required this.storage});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Financial & Tax Services',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: LandingPage(apiBaseUrl: apiBaseUrl),
      debugShowCheckedModeBanner: false,
    );
  }
}
