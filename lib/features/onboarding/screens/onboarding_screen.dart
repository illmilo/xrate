// // FILE IS NOT BEING USED! BUT DO NOT DELETE
// library money_transfer.onboarding_screen;
// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:money_transfer/core/utils/color_constants.dart';
// import 'package:money_transfer/core/utils/global_constants.dart';
// import 'package:money_transfer/core/utils/assets.dart';
// import 'package:money_transfer/features/auth/screens/signup_screen.dart';
// import 'package:money_transfer/features/onboarding/screens/widgets/glassmorphic_card.dart';
// import 'package:money_transfer/widgets/custom  _button.dart';
// import 'package:money_transfer/widgets/height_space.dart';
// import 'package:money_transfer/bybit_registration_screen.dart';
//
//
//
// bool visibility = true;
//
// class OnBoardingScreen extends StatefulWidget {
//   static const String route = "/onboarding-screen";
//   const OnBoardingScreen({super.key});
//
//   @override
//   State<OnBoardingScreen> createState() => _OnBoardingScreenState();
// }
//
// class _OnBoardingScreenState extends State<OnBoardingScreen>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _animationController;
//   late Animation<Color?> _colorAnimation;
//   bool _isButtonClickable = false;
//   @override
//   void initState() {
//     super.initState();
//
//     // Initialize AnimationController with a duration of 3 seconds
//     _animationController = AnimationController(
//       vsync: this,
//       duration: const Duration(seconds: 7),
//     );
//
//     // Define the color animation from white to the primary button color
//     _colorAnimation = ColorTween(
//       begin: Colors.white,
//       end: primaryAppColor, // Your primary button color
//     ).animate(_animationController);
//
//     // Start the color animation
//     _animationController.forward();
//
//     // Set a 3-second delay to make the button clickable
//     Timer(const Duration(seconds: 7), () {
//       setState(() {
//         _isButtonClickable = true;
//       });
//     });
//   }
//
//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//
//     return Visibility(
//       visible: visibility, // Control visibility for the entire Scaffold
//       child: Scaffold(
//         body: SafeArea(
//           child: Padding(
//             padding: EdgeInsets.symmetric(horizontal: value10),
//             child: Stack(
//               children: [
//                 Align(
//                   alignment: Alignment.topCenter,
//                   child: Padding(
//                     padding: EdgeInsets.only(top: heightValue30),
//                     child: Column(
//                       children: [
//                         Image.asset(
//                           mainLogo,
//                           height: heightValue50,
//                         ),
//                         SizedBox(
//                           height: heightValue10,
//                         ),
//                         Text(
//                           "The Best Way to Transfer Money Safely",
//                           style: TextStyle(
//                             fontSize: heightValue15,
//                             color: greyScale500,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 Positioned(
//                   top: 150,
//                   right: 0,
//                   child: Image.asset(
//                     gradientCircle,
//                     height: heightValue200,
//                   ),
//                 ),
//                 Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     GlassmorphicCard(height: heightValue230, width: 355),
//                     HeightSpace(heightValue35),
//                     Text(
//                       "Application usage & policy",
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: heightValue30,
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                     SizedBox(
//                       height: heightValue20,
//                     ),
//                     Text(
//                       "Upon clicking Continue, users will be directed to either log in or sign up to access their Bybit account.",
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                         fontSize: heightValue18,
//                         color: greyScale500,
//                       ),
//                     ),
//                   ],
//                 ),
//                 Align(
//                   alignment: Alignment.bottomCenter,
//                   child: Padding(
//                     padding: EdgeInsets.only(bottom: heightValue20),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.end,
//                       children: [
//                         AnimatedBuilder(
//                           animation: _animationController,
//                           builder: (context, child) {
//                             return TextButton(
//                               onPressed: _isButtonClickable
//                                   ? () {
//                                 setState(() {
//                                   visibility = false;
//                                 });
//                               }
//                                   : null,
//                               child: Stack(
//                                 children: [
//                                   Container(
//                                     height: heightValue45,
//                                     width: double.infinity,
//                                     decoration: BoxDecoration(
//                                       color: Colors.white,
//                                       borderRadius: BorderRadius.circular(22),
//                                       border: Border.all(
//                                         color: _colorAnimation.value!,
//                                       ),
//                                     ),
//                                   ),
//                                   Positioned.fill(
//                                     child: LinearProgressIndicator(
//                                       value: _animationController.value,
//                                       backgroundColor: Colors.white,
//                                       valueColor: AlwaysStoppedAnimation(
//                                           _colorAnimation.value),
//                                       minHeight: heightValue45,
//                                     ),
//                                   ),
//                                   Positioned.fill(
//                                     child: Center(
//                                       child: Text(
//                                         "Continue",
//                                         style: TextStyle(
//                                           color: scaffoldBackgroundColor,
//                                           fontSize: heightValue18,
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             );
//                           },
//                         ),
//                         SizedBox(
//                           height: heightValue10,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
