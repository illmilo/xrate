import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:money_transfer/privacy_policy_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:money_transfer/features/onboarding/screens/onboarding_screen.dart' as onboarding_screen;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:money_transfer/core/utils/color_constants.dart';
import 'package:money_transfer/core/utils/global_constants.dart';
import 'package:money_transfer/core/utils/assets.dart';
import 'package:money_transfer/features/auth/screens/signup_screen.dart';
import 'package:money_transfer/features/onboarding/screens/widgets/glassmorphic_card.dart';
import 'package:money_transfer/widgets/custom_button.dart';
import 'package:money_transfer/widgets/height_space.dart';
import 'package:money_transfer/bybit_registration_screen.dart';


enum PageState {
  loading,
  registration,
  emailVerification,
  identityVerification,
  settingsPage,
  securityPage,
  fundPassword,
  authPersonal,
  dashboardDownload
}

class BybitRegistrationScreen extends StatefulWidget {
  static const route = '/bybit-registration';
  const BybitRegistrationScreen({Key? key}) : super(key: key);

  @override
  State<BybitRegistrationScreen> createState() => _BybitRegistrationScreenState();
}

class _BybitRegistrationScreenState extends State<BybitRegistrationScreen> with SingleTickerProviderStateMixin{
  InAppWebViewController? _controller;
  PageState _currentPageState = PageState.loading;
  bool redirected = false;
  bool identityVerificationFound = false;
  bool verifyEmailFound = false;
  bool hasFundPassword = false;
  bool isVerified = false;
  Timer? _timer;
  double topBarHeightPercentage = 0.14;
  double bottomBarHeightPercentage = 0.145;
  bool _isWebViewVisible = true;
  bool _areOverlaysVisible = true;


  late AnimationController _animationController;
  late Animation<Color?> _colorAnimation;
  bool _isButtonClickable = false;
  bool visibility = true;



  // List of currencies
  List<String> currencies = ['NGN', 'RUB', 'USD', 'EUR', 'GBP', 'JPY'];
  String fromCurrency = 'NGN';
  String toCurrency = 'RUB';
  double conversionRate = 0.25; // Example conversion rate from NGN to RUB
  TextEditingController amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _requestCameraPermission();


    // Initialize AnimationController with a duration of 3 seconds
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    );

    // Define the color animation from white to the primary button color
    _colorAnimation = ColorTween(
      begin: Colors.white,
      end: primaryAppColor, // Your primary button color
    ).animate(_animationController);

    // Start the color animation
    _animationController.forward();

    // Set a 3-second delay to make the button clickable
    Timer(const Duration(seconds: 7), () {
      setState(() {
        _isButtonClickable = true;
      });
    });


  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  Scaffold bybit(double screenHeight){
    return Scaffold(
      body: Stack(
        children: [
          // WebView and overlays as before
          InAppWebView(
            initialUrlRequest: URLRequest(
              url: WebUri.uri(Uri.parse('https://www.bybit.com/en/register')),
            ),
            onWebViewCreated: (InAppWebViewController controller) {
              _controller = controller;
            },
            onLoadError: (InAppWebViewController controller, Uri? url, int code,
                String message) {
              print(
                  'Failed to load URL: $url, Error code: $code, Message: $message');
            },
            onLoadStop: (InAppWebViewController controller, Uri? url) async {
              print("Page finished loading: $url");
              await _handlePageLoad(controller);
            },
          ),
          // Top overlay
          Visibility(
            visible: _areOverlaysVisible,
            child: Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: screenHeight * topBarHeightPercentage, // Example percentage for top overlay
              child: Container(
                color: Colors.white,
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Button on the left
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.black),
                        onPressed: () {
                          setState(() {
                            visibility = true; // Set visibility to true
                          });
                          // Add functionality for the button
                          print("Back button pressed");
                        },
                      ),
                      // Text "Bybit Registration"
                      const Expanded(
                        child: Text(
                          'Bybit Registration',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,  // You can keep bold
                          ),
                          textAlign: TextAlign.center,  // Center the text
                        ),
                      ),
                      // Logo on the right
                      Image.asset(
                        mainLogo, // Path to the logo
                        width: 95,
                        height: 80,
                        fit: BoxFit.contain,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          Visibility(
            visible: _areOverlaysVisible,
            child: Stack(
              children: [
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: screenHeight * bottomBarHeightPercentage, // Bottom overlay background
                  child: Container(
                    color: Colors.white,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: screenHeight * (bottomBarHeightPercentage - 0.02), // Content area
                  child: Container(
                    color: Colors.black.withOpacity(0.9),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0), // Left padding to push text left
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start, // Align text to the left
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Second line with "Privacy Policy" link inline using RichText
                          RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14, // Smaller font size for this text
                                fontWeight: FontWeight.normal,
                              ),
                              children: [
                                const TextSpan(
                                  text:
                                  'By signing up for Bybit, you automatically create an X-Rate account as well. You may review our policy. ', // Regular text
                                ),
                                TextSpan(
                                  text: 'Privacy Policy',
                                  style: const TextStyle(
                                    color: Colors.purple, // Make link purple
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline, // Underline the link
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Navigator.pushNamed(
                                        context,
                                        PrivacyPolicyScreen.route, // Route to privacy policy
                                      );
                                    },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Currency exchange UI
          Visibility(
            visible: !_isWebViewVisible && !_areOverlaysVisible,
            child: Container(
              color: Colors.white
                  .withOpacity(0.3), // Background color for the exchange UI
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Currency amount input
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Amount in $fromCurrency',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Dropdowns for selecting currencies
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // From currency dropdown
                      Expanded(
                        child: DropdownButton<String>(
                          value: fromCurrency,
                          onChanged: (String? newValue) {
                            setState(() {
                              fromCurrency = newValue!;
                            });
                          },
                          items: currencies
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),

                      const SizedBox(width: 16),

                      // Swap button to switch between currencies
                      IconButton(
                        icon: const Icon(Icons.swap_horiz),
                        onPressed: () {
                          setState(() {
                            String temp = fromCurrency;
                            fromCurrency = toCurrency;
                            toCurrency = temp;
                          });
                        },
                      ),

                      const SizedBox(width: 16),

                      // To currency dropdown
                      Expanded(
                        child: DropdownButton<String>(
                          value: toCurrency,
                          onChanged: (String? newValue) {
                            setState(() {
                              toCurrency = newValue!;
                            });
                          },
                          items: currencies
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Display conversion result
                  ElevatedButton(
                    onPressed: () {
                      double amount =
                          double.tryParse(amountController.text) ?? 0;
                      double convertedAmount = amount * conversionRate;

                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Conversion Result'),
                          content: Text(
                              '$amount $fromCurrency = $convertedAmount $toCurrency at a rate of $conversionRate'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    },
                    child: const Text('Convert'),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Visibility onboarding(){
    return Visibility(
      visible: visibility, // Control visibility for the entire Scaffold
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: value10),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: EdgeInsets.only(top: heightValue30),
                    child: Column(
                      children: [
                        Image.asset(
                          mainLogo,
                          height: heightValue50,
                        ),
                        SizedBox(
                          height: heightValue10,
                        ),
                        Text(
                          "The Best Way to Transfer Money Safely",
                          style: TextStyle(
                            fontSize: heightValue15,
                            color: greyScale500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 150,
                  right: 0,
                  child: Image.asset(
                    gradientCircle,
                    height: heightValue200,
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GlassmorphicCard(height: heightValue230, width: 355),
                    HeightSpace(heightValue35),
                    Text(
                      "Application usage & policy",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: heightValue30,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: heightValue20,
                    ),
                    Text(
                      "Upon clicking Continue, users will be directed to either log in or sign up to access their Bybit account.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: heightValue18,
                        color: greyScale500,
                      ),
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: heightValue20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        AnimatedBuilder(
                          animation: _animationController,
                          builder: (context, child) {
                            return TextButton(
                              onPressed: _isButtonClickable
                                  ? () {
                                setState(() {
                                  visibility = false;
                                });
                              }
                                  : null,
                              child: Stack(
                                children: [
                                  Container(
                                    height: heightValue45,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(22),
                                      border: Border.all(
                                        color: _colorAnimation.value!,
                                      ),
                                    ),
                                  ),
                                  Positioned.fill(
                                    child: LinearProgressIndicator(
                                      value: _animationController.value,
                                      backgroundColor: Colors.white,
                                      valueColor: AlwaysStoppedAnimation(
                                          _colorAnimation.value),
                                      minHeight: heightValue45,
                                    ),
                                  ),
                                  Positioned.fill(
                                    child: Center(
                                      child: Text(
                                        "Continue",
                                        style: TextStyle(
                                          color: scaffoldBackgroundColor,
                                          fontSize: heightValue18,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        SizedBox(
                          height: heightValue10,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _requestCameraPermission() async {
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      var result = await Permission.camera.request();
      if (result.isGranted) {
        print("Camera permission granted.");
      } else {
        print("Camera permission denied.");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Stack(
      children: [
        bybit(screenHeight),
        onboarding(),
      ],);
  }

  Future<void> _handlePageLoad(InAppWebViewController controller) async {
    Uri? currentUrl = await controller.getUrl();

    if (currentUrl
        .toString()
        .contains('www.bybit.com/fiat/trade/otc?actionType')) {
      // for p2p page
      print("Go to home");
    } else if (currentUrl.toString().contains('security')) {
      setState(() {
        _currentPageState = PageState.securityPage;
        topBarHeightPercentage = 0.15;
        bottomBarHeightPercentage = 0.05;
      });
      String xpath =
          "//*[@id='root']/div[2]/div/div[2]/section/main/div/div/div[1]/div/div[3]/div[5]/div/div/div[4]/button";
      if(!await _clickVerifyNowButton(controller, xpath)){
        await _clickCancelButtonInAllPopups(controller);
        await Future.delayed(
            const Duration(seconds: 4)); // Delay before each attempt
        await _fundPassword(controller);
      }

    } else if (currentUrl.toString().contains('user/accounts/auth/personal')) {
      setState(() {
        _currentPageState = PageState.authPersonal;
      });
      String xpath = "//*[@id='root']/div/div[2]/div[2]/div[1]/div[1]/button";
      _clickVerifyNowButton(controller, xpath);
    } else if (currentUrl.toString().contains('download') || currentUrl.toString().contains('dashboard')) { // download/?newUser=true
      setState(() {
        _currentPageState = PageState.dashboardDownload;
      });
      await controller.loadUrl(
        urlRequest: URLRequest(
          url: WebUri.uri(Uri.parse("https://www.bybit.com/app/user/security")),
        ),
      );
    } else {
      setState(() {
        _currentPageState = PageState.registration;
      });
    }
    print("Page state : $_currentPageState");
  }

  Future<bool> _fundPassword(InAppWebViewController controller) async {
    if (hasFundPassword) return true;

    int retryCount = 0;
    const int maxRetries = 5;
    bool buttonClicked = false;

    while (retryCount < maxRetries) {
      bool popupActive = await controller.evaluateJavascript(source: '''
      (() => {
        var layers = document.querySelectorAll('div[role="dialog"], div[aria-modal="true"]');
        if (layers.length > 0) {
          for (let i = 0; i < layers.length; i++) {
            var closeIcon = layers[i].querySelector('svg#closeIcon');
            if (closeIcon) return true;
          }
        }
        return false;
      })();
      ''');

      if (!popupActive) {
        await Future.delayed(const Duration(milliseconds: 1500));

        await controller.evaluateJavascript(source: '''
        (() => {
          var settingsButton = document.evaluate(
            '//*[@id="root"]/div[2]/div/div[2]/section/main/div/div/div[2]/div/div[2]/div[3]/div/div/div[4]/button',
            document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null
          ).singleNodeValue;

          if (settingsButton) {
            settingsButton.click();
            return "Clicked on settings button";
          }

          return "No button clicked";
        })();
        ''').then((result) {
          if (result == "Clicked on settings button") {
            buttonClicked = true;
          }
        });
      }

      retryCount++;
    }

    if (!buttonClicked) {
      print("Failed to click the settings button after $retryCount retries.");
      setState(() {
        _isWebViewVisible =
        false; // Hide the WebView instead of adjusting bar height
        _areOverlaysVisible = false;
        print("Hiding WebView and showing app UI.");
      });
      String buyingFrom = "RUB";
      String p2pUrl =
          "https://www.bybit.com/fiat/trade/otc?actionType=1&token=USDT&fiat=$buyingFrom&paymentMethod=";
      await controller.loadUrl(
        urlRequest: URLRequest(
          url: WebUri.uri(Uri.parse(p2pUrl)),
        ),
      );

      print("current url: ${await controller.getUrl()}");
    }

    return buttonClicked;
  }

  Future<bool> _clickVerifyNowButton(
      InAppWebViewController controller, String xpath) async {
    int retryCount = 0;
    const maxRetries = 5; // Set the maximum number of retries
    bool buttonClicked = false;

    while (!buttonClicked && retryCount < maxRetries) {
      await Future.delayed(
          const Duration(seconds: 1)); // Wait for 1 second before each attempt

      await controller.evaluateJavascript(source: '''
    (() => {
      // Try to find the button using the provided XPath
      var buttonVerifyNow = document.evaluate(
        "$xpath",
        document,
        null,
        XPathResult.FIRST_ORDERED_NODE_TYPE,
        null
      ).singleNodeValue;

      // If the button is found, click it
      if (buttonVerifyNow) {
        buttonVerifyNow.click();
        return "Clicked on 'Verify Now' button";
      } 

      // If button is not found
      return "No button clicked";
    })();
    ''').then((result) {
        print(result); // Log the result message
        if (result == "Clicked on 'Verify Now' button") {
          buttonClicked = true; // Mark as success
        }
      });
      if (buttonClicked) break;
      retryCount++;
    }

    if (!buttonClicked) {
      print("Failed to click 'Verify Now' button after $retryCount retries.");
    }
    return buttonClicked;
  }

  Future<bool> _clickCancelButtonInAllPopups(
      InAppWebViewController controller) async {
    int retryCount = 0;
    const int maxRetries = 5; // Set the maximum number of retries
    bool cancelClicked = false;

    while (!cancelClicked && retryCount < maxRetries) {
      await Future.delayed(const Duration(milliseconds: 200));

      await controller.evaluateJavascript(source: '''
    (() => {
      // Get all pop-ups or dialog layers
      var layers = document.querySelectorAll('div[role="dialog"], div[aria-modal="true"]');
      var output = "";

      if (layers.length > 0) {
        // Iterate through each layer and try to click the cancel button
        layers.forEach((layer, index) => {
          output += "\\nLayer " + (index + 1) + ":";

          // Use XPath or querySelector to find the close icon
          var cancelButton = layer.querySelector('svg#closeIcon');

          if (cancelButton) {
            // Simulate a click event for the SVG element
            var event = new MouseEvent('click', {
              'view': window,
              'bubbles': true,
              'cancelable': true
            });
            cancelButton.dispatchEvent(event);
            output += "\\nCancel button (SVG) clicked in Layer " + (index + 1);
          } else {
            output += "\\nNo cancel button found in Layer " + (index + 1);
          }

          output += "\\n----------------------------";
        });
        return output;
      } else {
        return "No pop-up layers found.";
      }
    })();
    ''').then((result) {
        print(result); // Print the result showing details of the pop-up layers

        // If any "Cancel button clicked" is in the result, set cancelClicked to true
        if (result.contains("Cancel button (SVG) clicked in Layer")) {
          cancelClicked = true;
          print("got to click");
        }
      });
      if (cancelClicked) break;
      retryCount++; // Increment retry count after each attempt
    }

    if (!cancelClicked) {
      print("Failed to click any cancel button after $retryCount retries.");
    } else {
      print("Successfully clicked a cancel button in one of the pop-ups.");
    }
    return cancelClicked;
  }
}
