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
              "Welcome to SnapIdeas. We respect your privacy and are committed to protecting your personal data. This Privacy Policy outlines how we collect, use, and safeguard your information when you use our mobile application.\n\n"
              "2. Data We Collect\n"
              "We may collect personal information such as your name, email address, and profile picture when you create an account. Additionally, we may collect metadata from images you upload to provide features like pose detection.\n\n"
              "3. How We Use Your Data\n"
              "We use your data to:\n"
              "• Provide and maintain our service\n"
              "• Personalize your experience\n"
              "• Provide AI-powered pose feedback\n"
              "• Manage your account\n"
              "• Communicate with you regarding updates\n\n"
              "4. Data Security\n"
              "We implement industry-standard security measures to protect your personal data. Your uploaded images are processed securely and are not shared with third parties without your consent.\n\n"
              "5. Third-Party Services\n"
              "We use Supabase for authentication and database services, and Google ML Kit for on-device pose detection. Please refer to their respective privacy policies for more information.\n\n"
              "6. Contact Us\n"
              "If you have any questions about this Privacy Policy, please contact us at:\n"
              "riteshkumar.nitk21@gmail.com",
            ),
          ],
        ),
      ),
    );
  }
}
