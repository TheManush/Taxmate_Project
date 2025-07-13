import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FirebaseNotifications {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  static Future<void> initialize() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    await messaging.requestPermission();

    // Get FCM token
    String? token = await messaging.getToken();
    print("📱 FCM Token: $token");

    // Initialize flutter_local_notifications
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Listen for foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final data = message.data;
      final senderName = data['sender_name'] ?? 'Unknown';
      final msg = data['message'] ?? message.notification?.body ?? '';
      print("📩 Foreground message from: $senderName");
      print("📄 Message: $msg");
      // Show a local notification
      flutterLocalNotificationsPlugin.show(
        0,
        'Message from $senderName',
        msg,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'chat_channel',
            'Chat Messages',
            channelDescription: 'Channel for chat message notifications',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker',
          ),
        ),
      );
    });

    // Listen for background tap (when app is opened from notification)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      final data = message.data;
      final senderName = data['sender_name'] ?? 'Unknown';
      final msg = data['message'] ?? message.notification?.body ?? '';
      print("📲 Notification tapped. Sender: $senderName");
      print("📄 Message: $msg");
      // Navigate or update UI as needed
    });
  }

  static Future<void> backgroundHandler(RemoteMessage message) async {
    await Firebase.initializeApp();
    final data = message.data;
    final senderName = data['sender_name'] ?? 'Unknown';
    final msg = data['message'] ?? message.notification?.body ?? '';
    print("🔄 Background message from: $senderName");
    print("📄 Message: $msg");
  }
}
