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
              "By accessing and using this application, you accept and agree to be bound by the terms and provision of this agreement.\n\n"
              "2. Use License\n"
              "Permission is granted to temporarily download one copy of the materials (information or software) on Photo Ideas App for personal, non-commercial transitory viewing only.\n\n"
              "3. Disclaimer\n"
              "The materials on Photo Ideas App are provided 'as is'. We make no warranties, expressed or implied, and hereby disclaim and negate all other warranties.\n\n"
              "4. Limitations\n"
              "In no event shall Photo Ideas App or its suppliers be liable for any damages (including, without limitation, damages for loss of data or profit, or due to business interruption) arising out of the use or inability to use the materials on Photo Ideas App.\n\n"
              "5. Governing Law\n"
              "Any claim relating to Photo Ideas App shall be governed by the laws of the local jurisdiction without regard to its conflict of law provisions.",
            ),
          ],
        ),
      ),
    );
  }
}
