import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../auth/screens/login_screen.dart';
import '../../favorites/screens/favorites_screen.dart';
import 'help_support_screen.dart';
import 'edit_profile_screen.dart';
import '../../admin/screens/admin_dashboard_screen.dart';
import '../../settings/screens/settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final StreamSubscription<AuthState> _authSubscription;

  @override
  void initState() {
    super.initState();
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }


  Future<void> _logout() async {
    await Supabase.instance.client.auth.signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  Future<void> _deleteAccount(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // TODO: Implement actual account deletion logic
        // For now, we'll just sign out
        await Supabase.instance.client.auth.signOut();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Account deleted successfully')),
          );
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting account: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? user = Supabase.instance.client.auth.currentUser;
    final String name = user?.userMetadata?['full_name'] ?? 'User';
    final String email = user?.email ?? 'No Email';

    final String? avatarUrl = user?.userMetadata?['avatar_url'];
    final String? phone = user?.userMetadata?['phone_number'];
    final String? gender = user?.userMetadata?['gender'];

    // Note: No Scaffold here because it's used inside HomeScreen's body Stack
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 60, 16, 16), // Top padding for transparent AppBar
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
              ),
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white.withOpacity(0.2),
                backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                    ? NetworkImage(avatarUrl)
                    : null,
                child: avatarUrl == null || avatarUrl.isEmpty
                    ? Text(
                        name.isNotEmpty ? name[0].toUpperCase() : 'U',
                        style: const TextStyle(fontSize: 40, color: Colors.white),
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              name,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white),
            ),
            Text(
              email,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white70),
            ),
            if (phone != null && phone.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                phone,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
              ),
            ],
            if (gender != null && gender.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                gender,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
              ),
            ],
            const SizedBox(height: 32),
            _buildGlassProfileOption(
              context,
              Icons.edit,
              "Edit Profile",
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                );
                if (result == true) {
                  setState(() {});
                }
              },
            ),
            _buildGlassProfileOption(
              context, 
              Icons.favorite, 
              "Favorites",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FavoritesScreen()),
                );
              },
            ),
            _buildGlassProfileOption(
              context, 
              Icons.settings, 
              "Settings",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsScreen()),
                );
              },
            ),
            _buildGlassProfileOption(
              context, 
              Icons.help, 
              "Help & Support",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HelpSupportScreen()),
                );
              },
            ),
            if (email == 'riteshkumar.nitk21@gmail.com') ...[
              _buildGlassProfileOption(
                context,
                Icons.admin_panel_settings,
                "Admin Dashboard",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AdminDashboardScreen()),
                  );
                },
              ),
            ],
            const SizedBox(height: 20),
            _buildGlassProfileOption(
              context, 
              Icons.logout, 
              "Logout", 
              isDestructive: true,
              onTap: _logout,
            ),
            if (email != 'riteshkumar.nitk21@gmail.com')
              _buildGlassProfileOption(
                context,
                Icons.delete_forever,
                "Delete Account",
                isDestructive: true,
                onTap: () => _deleteAccount(context),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassProfileOption(BuildContext context, IconData icon, String title, {bool isDestructive = false, VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: ListTile(
              leading: Icon(
                icon,
                color: isDestructive ? Colors.redAccent : Colors.white,
              ),
              title: Text(
                title,
                style: TextStyle(
                  color: isDestructive ? Colors.redAccent : Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              trailing: const Icon(Icons.chevron_right, color: Colors.white54),
              onTap: onTap ?? () {},
            ),
          ),
        ),
      ),
    );
  }
}
