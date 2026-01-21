import 'package:flutter/material.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Terms of Service")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Terms of Service",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            const Text(
              "Last updated: November 29, 2025",
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 16),
            const Text(
              "1. Acceptance of Terms\n"
              "By accessing and using SnapIdeas, you accept and agree to be bound by the terms and provisions of this agreement.\n\n"
              "2. User Conduct\n"
              "You agree to use the app only for lawful purposes. You must not use the app to harass, abuse, or harm others, or to upload offensive or illegal content.\n\n"
              "3. User-Generated Content\n"
              "You retain ownership of the content you upload. However, by uploading content, you grant SnapIdeas a non-exclusive, royalty-free license to display and process that content within the application.\n\n"
              "4. Intellectual Property\n"
              "The app's design, features, and curated content are protected by copyright and other intellectual property laws. You may not reproduce or distribute any part of the app without permission.\n\n"
              "5. Disclaimer of Warranties\n"
              "SnapIdeas is provided 'as is' without any warranties, express or implied. We do not guarantee that the app will be error-free or uninterrupted.\n\n"
              "6. Limitation of Liability\n"
              "In no event shall SnapIdeas be liable for any damages arising out of the use or inability to use the application.\n\n"
              "7. Changes to Terms\n"
              "We reserve the right to modify these terms at any time. Your continued use of the app signifies your acceptance of any changes.\n\n"
              "8. Contact\n"
              "For any queries regarding these terms, contact us at riteshkumar.nitk21@gmail.com",
            ),
          ],
        ),
      ),
    );
  }
}
