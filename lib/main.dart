import 'package:flutter/foundation.dart';
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
import 'package:flutter_inappwebview/flutter_inappwebview.dart';


Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    print("Handling a background message ${message.messageId}");
  }
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
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  static const String route = '/my-app'; // Define the route here

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeManager().darkTheme,
      debugShowCheckedModeBanner: false,
      home: const BybitRegistrationScreen(), // Directly navigate to the BybitRegistrationScreen
    );
  }
}


class BybitRegistrationScreen extends StatefulWidget {
  const BybitRegistrationScreen({super.key});

  @override
  State<BybitRegistrationScreen> createState() => _BybitRegistrationScreenState();
}

class _BybitRegistrationScreenState extends State<BybitRegistrationScreen> {
  InAppWebViewController? _controller;
  String emailInput = "";
  String passwordInput = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Bybit Registration")),
      body: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(
              url: WebUri.uri(Uri.parse("https://www.bybit.com/en/register?redirect_url=https%3A%2F%2Fwww.bybit.com%2Fen%2F")),
            ),
            onWebViewCreated: (InAppWebViewController controller) {
              _controller = controller;
            },
            onLoadError: (InAppWebViewController controller, Uri? url, int code, String message) {
              print("Failed to load URL: $url, Error code: $code, Message: $message");
            },
            onLoadStop: (InAppWebViewController controller, Uri? url) async {
              await _handlePageLoad(controller);
            },
          ),
          // Top overlay
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.15,
            child: Container(
              color: Colors.black.withOpacity(0.99),
              child: const Center(
                child: Text(
                  'Overlay Top',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            ),
          ),
          // Bottom overlay
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.09,
            child: Container(
              color: Colors.black.withOpacity(0.99),
              child: const Center(
                child: Text(
                  'Bybit signup creates an XRate account',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handlePageLoad(InAppWebViewController controller) async {
    // Commented out the cookie acceptance part
    // await _injectClickJavascript(controller, '.style_accpet-cookie-btn__WgSmq');

    emailInput = await _retrieveInputValue(controller, 'input[name="email"]');
    passwordInput = await _retrieveInputValue(controller, 'input[name="password"]');

    await _waitForTextAndScroll(controller, "Verify");
    await _handleRedirectAndClickVerify(controller);

    print("Email Input: $emailInput");
    print("Password Input: $passwordInput");
  }

  Future<void> _injectClickJavascript(InAppWebViewController controller, String selector) async {
    await controller.evaluateJavascript(source: '''
      var button = document.querySelector('$selector');
      if (button) {
        button.click();
      }
    ''');
  }

  Future<String> _retrieveInputValue(InAppWebViewController controller, String selector) async {
    return await controller.evaluateJavascript(source: '''
      var inputField = document.querySelector('$selector');
      if (inputField) {
        inputField.value;
      } else {
        null;
      }
    ''') ?? "";
  }

  Future<void> _waitForTextAndScroll(InAppWebViewController controller, String text) async {
    while (true) {
      bool exists = await controller.evaluateJavascript(source: '''
        document.body.innerText.includes('$text');
      ''');

      if (exists) {
        await controller.evaluateJavascript(source: '''
          window.scrollTo(0, document.body.scrollHeight * -0.55);
        ''');

        break;
      }
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  Future<void> _handleRedirectAndClickVerify(InAppWebViewController controller) async {
    while (true) {
      bool exists = await controller.evaluateJavascript(source: '''
        document.body.innerText.includes('Verify');
      ''');

      if (!exists) {
        WebUri? currentUrl = await controller.getUrl();

        // Convert Uri to WebUri if necessary
        if (currentUrl != null && currentUrl.toString() != "https://www.bybit.com/user/accounts/auth/personal") {
          final webUri = WebUri.uri(Uri.parse(currentUrl.toString())); // Convert to WebUri
          await controller.loadUrl(urlRequest: URLRequest(url: webUri));
        } else {
          await _injectClickJavascript(controller, 'button.moly-btn:contains("Verify Now")');
        }
        break;
      }
      await Future.delayed(const Duration(seconds: 1));
    }
  }
}

