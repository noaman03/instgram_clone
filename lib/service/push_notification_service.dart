import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PushNotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> initialize() async {
    // Request permission
    await _fcm.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    // Get FCM token
    String? token = await _fcm.getToken();

    // Save token to Firestore if available
    if (token != null && _auth.currentUser != null) {
      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .update({'fcmToken': token});
    }

    // Listen for token refresh
    _fcm.onTokenRefresh.listen((newToken) {
      if (_auth.currentUser != null) {
        _firestore
            .collection('users')
            .doc(_auth.currentUser!.uid)
            .update({'fcmToken': newToken});
      }
    });

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }
    });

    // Handle background message clicks
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      // Navigate to relevant screen based on message data
    });
  }
}
