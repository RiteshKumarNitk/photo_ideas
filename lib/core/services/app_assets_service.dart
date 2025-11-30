import 'package:supabase_flutter/supabase_flutter.dart';

class AppAssetsService {
  static const String _category = 'System';
  
  // Default Assets
  static const Map<String, String> defaults = {
    'splash_background': 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?auto=format&fit=crop&w=1000&q=80',
    'admin_background': 'https://images.unsplash.com/photo-1451187580459-43490279c0fa?auto=format&fit=crop&w=1000&q=80',
  };

  static Future<String> getAssetUrl(String key) async {
    try {
      final response = await Supabase.instance.client
          .from('images')
          .select('url')
          .eq('category', _category)
          .eq('title', key)
          .maybeSingle();

      if (response != null && response['url'] != null) {
        return response['url'] as String;
      }
    } catch (e) {
      // Fallback to default on error
    }
    return defaults[key] ?? '';
  }

  static Future<void> updateAsset(String key, String url) async {
    final client = Supabase.instance.client;
    
    // Check if exists
    final existing = await client
        .from('images')
        .select('id')
        .eq('category', _category)
        .eq('title', key)
        .maybeSingle();

    if (existing != null) {
      await client.from('images').update({
        'url': url,
      }).eq('id', existing['id']);
    } else {
      await client.from('images').insert({
        'category': _category,
        'title': key,
        'url': url,
        'created_at': DateTime.now().toIso8601String(),
      });
    }
  }
}
