import 'package:flutter/material.dart';
import 'admin_images_tab.dart';
import 'admin_quotes_tab.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Dashboard'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Images', icon: Icon(Icons.image)),
              Tab(text: 'Quotes', icon: Icon(Icons.format_quote)),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            AdminImagesTab(),
            AdminQuotesTab(),
          ],
        ),
      ),
    );
  }
}
