import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Privacy Policy")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Privacy Policy",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            const Text(
              "Last updated: November 29, 2025",
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 16),
            const Text(
              "1. Introduction\n"
              "Welcome to Photo Ideas App. We respect your privacy and are committed to protecting your personal data.\n\n"
              "2. Data We Collect\n"
              "We may collect personal information such as your name, email address, and profile picture when you create an account.\n\n"
              "3. How We Use Your Data\n"
              "We use your data to provide and improve our services, manage your account, and communicate with you.\n\n"
              "4. Data Security\n"
              "We implement appropriate security measures to protect your personal data.\n\n"
              "5. Contact Us\n"
              "If you have any questions about this Privacy Policy, please contact us.",
            ),
          ],
        ),
      ),
    );
  }
}
