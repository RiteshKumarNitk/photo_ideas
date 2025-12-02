import 'package:shared_preferences/shared_preferences.dart';

class AppAssetsService {
  static const Map<String, String> defaults = {
    'admin_background': 'https://images.unsplash.com/photo-1451187580459-43490279c0fa?q=80&w=2072&auto=format&fit=crop',
    'login_background': 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?q=80&w=1000&auto=format&fit=crop',
    'signup_background': 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?q=80&w=1000&auto=format&fit=crop',
  };

  /// Returns the URL for a given asset name.
  /// Checks SharedPreferences first, then falls back to defaults.
  static Future<String> getAssetUrl(String assetName) async {
    final prefs = await SharedPreferences.getInstance();
    final customUrl = prefs.getString('asset_$assetName');
    
    if (customUrl != null && customUrl.isNotEmpty) {
      return customUrl;
    }

    return defaults[assetName] ?? 'https://images.unsplash.com/photo-1557683316-973673baf926';
  }

  /// Updates the URL for a given asset name.
  static Future<void> updateAsset(String assetName, String newUrl) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('asset_$assetName', newUrl);
  }
}
