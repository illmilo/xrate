import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  static const route = '/privacy-policy';
  const PrivacyPolicyScreen({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy',
          style: TextStyle(
              fontWeight: FontWeight.bold
          ),
        ),
      ),
      body: const Center(
        child: Text('This is the Privacy Policy page.'
        ),
      ),
    );
  }
}
