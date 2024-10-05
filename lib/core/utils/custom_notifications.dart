import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class CustomNotifications {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  Future<void> initInfo() async {
    // Initialization settings for Android
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('notifications_logo'); // Change to your app's logo

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    // Initialize the FlutterLocalNotificationsPlugin
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Listen to Firebase Messaging onMessage
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print('..................onMessage...................');
      print(
          'onMessage: ${message.notification?.title}/${message.notification?.body}');

      // Show the notification using flutter_local_notifications
      await showNotification(message);
    });
  }

  Future<void> showNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'Pay Mobile', // channel ID
      'Pay Mobile', // channel Name
      channelDescription: 'Notification channel for Pay Mobile',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      icon: 'notifications_logo', // Change to your app's logo
      largeIcon: DrawableResourceAndroidBitmap('notifications_logo'), // Use largeIcon for notifications
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      0, // Notification ID
      message.notification?.title, // Notification Title
      message.notification?.body, // Notification Body
      platformChannelSpecifics,
    );
  }

void requestPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print("User declined or has accepted permission");
    }
  }
}
