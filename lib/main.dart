import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:money_transfer/features/home/screens/home_screen.dart';
import 'package:money_transfer/firebase_options.dart';
import 'package:money_transfer/features/auth/providers/auth_provider.dart';
import 'package:money_transfer/features/auth/providers/user_provider.dart';
import 'package:money_transfer/initialization_screen.dart';
import 'package:money_transfer/privacy_policy_screen.dart';
import 'package:provider/provider.dart';
import 'bybit_registration_screen.dart';
import 'features/onboarding/screens/onboarding_screen.dart';
import 'no_internet_screen.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    print("Handling a background message ${message.messageId}");
  }
}

Future<void> clearAppData() async {
  const platform = MethodChannel('com.example.money_transfer/clearData');
  try {
    await platform.invokeMethod('clearAppData');
  } on PlatformException catch (e) {
    print("Failed to clear app data: '${e.message}'.");
  }
}


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase and other initial services
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseMessaging.instance.getInitialMessage();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserProvider()),
        ChangeNotifierProvider(create: (context) => AuthProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  static const String route = '/my-app';

  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light(), // Replace with your theme manager if needed
      debugShowCheckedModeBanner: false,
      // home: HomeScreen(),
      routes: {
        HomeScreen.route: (context) => const HomeScreen(),
        BybitRegistrationScreen.route: (context) => const BybitRegistrationScreen(),
        PrivacyPolicyScreen.route: (context) => const PrivacyPolicyScreen(),
        // we can add other routes as needed
      },
      // initialRoute: HomeScreen.route,
      initialRoute: BybitRegistrationScreen.route, // Set the initial route
    );
  }
}