import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'features/splash/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://gileyahzdpoyjgrztxow.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdpbGV5YWh6ZHBveWpncnp0eG93Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjE2NzE2MTQsImV4cCI6MjA3NzI0NzYxNH0.b9RNGS-r4B91y96nxdUjK_jNtaG_5Dm-KwBSKtlPMYs',
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const SnapIdeasApp(),
    ),
  );
}

class SnapIdeasApp extends StatelessWidget {
  const SnapIdeasApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return MaterialApp(
      title: 'SnapIdeas',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      home: const SplashScreen(),
    );
  }
}
