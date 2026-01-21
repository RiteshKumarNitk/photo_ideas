import 'package:flutter/material.dart';
import 'legal_screen.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Help & Support"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Text(
            "Frequently Asked Questions",
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          _buildFaqItem(
            context,
            "How do I save an image?",
            "Tap on any image to view it in full screen, then tap the download icon to save it to your gallery.",
          ),
          _buildFaqItem(
            context,
            "Can I share images?",
            "Yes, you can share images directly from the full-screen viewer using the share button.",
          ),
          _buildFaqItem(
            context,
            "How do I add to favorites?",
            "Tap the heart icon on any image to add it to your favorites collection.",
          ),
          const SizedBox(height: 32),
          Text(
            "About Us",
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          const Text(
            "Photo Ideas is your go-to destination for creative inspiration. Whether you're looking for a new haircut, wedding photography ideas, or just beautiful nature shots, we have it all curated just for you.",
            style: TextStyle(height: 1.5),
          ),
          const SizedBox(height: 32),
          Text(
            "Legal",
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          _buildLegalItem(context, "Privacy Policy", () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const LegalScreen(
                  title: "Privacy Policy",
                  content: """
                    **Privacy Policy**

                    1. **Data Collection**
                    We collect basic user information such as your name, email address, and profile picture to provide a personalized experience in SnapIdeas.

                    2. **Image Sources & Copyright**
                    - **App Content:** Curated images are sourced from Unsplash and used in accordance with the Unsplash License.
                    - **User Uploads:** You retain rights to your uploaded content. You grant us a license to display them within SnapIdeas.

                    3. **Data Usage**
                    We use your data to improve app functionality and provide support. We do not sell your personal data.

                    4. **Security**
                    We implement appropriate security measures to protect your information.
                    """,
                ),
              ),
            );
          }),
          _buildLegalItem(context, "Terms of Service", () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const LegalScreen(
                  title: "Terms of Service",
                  content: """
**Terms of Service**

1. **Acceptance of Terms**
By using the SnapIdeas app, you agree to these Terms of Service. If you do not agree, please do not use the app.

2. **User Conduct**
You agree to use the app only for lawful purposes. You must not use the app to harass, abuse, or harm others.

3. **User-Generated Content**
- **Responsibility:** You are solely responsible for any images or content you upload to the app.
- **Copyright:** You must ensure that you own the copyright or have the necessary rights/licenses for any content you upload. **Do not upload copyrighted material without permission.**
- **Prohibited Content:** You may not upload content that is illegal, offensive, or violates the rights of others. We reserve the right to remove any content that violates these terms.

4. **App Content**
The curated images provided by the app are subject to the Unsplash License (for default content). You may use them for personal inspiration.

5. **Termination**
We reserve the right to terminate or suspend your account if you violate these terms.
""",
                ),
              ),
            );
          }),
          const SizedBox(height: 32),
          Text(
            "Contact Us",
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.email_outlined),
              title: const Text("Email Support"),
              subtitle: const Text("Riteshkumar.nitk21@gmail.com"),
              onTap: () {
                // Implement email launch
              },
            ),
          ),
          const SizedBox(height: 32),
          Center(
            child: Text(
              "Version 1.0.0",
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegalItem(BuildContext context, String title, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Widget _buildFaqItem(BuildContext context, String question, String answer) {
    return ExpansionTile(
      title: Text(
        question,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(
            answer,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}
