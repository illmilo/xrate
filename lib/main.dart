//ATTENTION!!!!!
/*
1. Please refer to lib/constants/global_constants.dart
2. Refer to lib/widgets to see custom made widgets that were used throughout the app.
3. Refer to lib/router.dart to see the navigation routes for the app
4. Refer to lib/providers/user_provider to see app's state manager for the users data
5. Refer to money_transfer_server to see the nodejs code controlling the backend
*/

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:money_transfer/config/routes/custom_push_navigators.dart';
import 'package:money_transfer/config/theme/theme_manager.dart';
import 'package:money_transfer/core/utils/utils.dart';
import 'package:money_transfer/core/utils/custom_notifications.dart';
import 'package:money_transfer/features/auth/screens/login_pin_screen.dart';
import 'package:money_transfer/features/auth/screens/login_screen.dart';
import 'package:money_transfer/features/auth/services/auth_service.dart';
import 'package:money_transfer/features/onboarding/screens/onboarding_screen.dart';
import 'package:money_transfer/features/profile/providers/chat_provider.dart';
import 'package:money_transfer/firebase_options.dart';
import 'package:money_transfer/initialization_screen.dart';
import 'package:money_transfer/no_internet_screen.dart';
import 'package:money_transfer/features/auth/providers/auth_provider.dart';
import 'package:money_transfer/features/auth/providers/user_provider.dart';
import 'package:money_transfer/config/routes/router.dart';
import 'package:money_transfer/widgets/main_app.dart';
import 'package:provider/provider.dart';
// he
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message ${message.messageId}");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseMessaging.instance.getInitialMessage();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => UserProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => AuthProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => ChatProvider(),
        )
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  static const String route = "/my-app";
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ThemeManager themeManager = ThemeManager();
  final AuthService authService = AuthService();
  final CustomNotifications customNotificatins = CustomNotifications();
  late Future _future;
  bool check = true;

  @override
// Initialize the FlutterLocalNotificationsPlugin instance
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  void initState() {
    super.initState();
    _future = obtainTokenAndUserData(context);
    checkInternetConnection();

    // Request notification permissions and initialize notifications
    customNotificatins.requestPermission();
    customNotificatins.initInfo();
    _initializeNotifications();
  }

  void _initializeNotifications() async {
    // Request permission to show notifications (if needed)
    final bool granted = await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestPermission() ?? false;

    if (granted) {
      // Set up the notification settings here
      const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
      const InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);

      await flutterLocalNotificationsPlugin.initialize(initializationSettings);
    }
  }

  obtainTokenAndUserData(BuildContext context) async {
    await authService.obtainTokenAndUserData(context);
  }

  checkInternetConnection() async {
    check = await InternetConnectionChecker().hasConnection;
    return check;
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    final user = Provider.of<UserProvider>(context).user;
    return MaterialApp(
      theme: themeManager.darkTheme,
      darkTheme: themeManager.darkTheme,
      debugShowCheckedModeBanner: false,
      onGenerateRoute: (settings) => appRoutes(settings),
      home: FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return check == true
                ? user.isVerified != false
                ? user.token.isNotEmpty
                ? user.pin.isNotEmpty
                ? const LoginPinScreen()
                : MainApp(
              currentPage: 0,
            )
                : const OnBoardingScreen()
                : const LoginScreen()
                : NoInternetScreen(onTap: () {
              checkInternetConnection();
              obtainTokenAndUserData(context);
              if (check == true) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  MyApp.route,
                      (route) => false,
                );
              } else {
                showDialogLoader(context);
                Future.delayed(const Duration(seconds: 5), () {
                  popNav(context);
                });
              }
            });
          } else {}

          return const InitializationScreen();
        },
      ),
    );
  }
}
