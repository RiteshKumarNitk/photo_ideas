// ignore_for_file: avoid_print
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseClient client = Supabase.instance.client;

  // Fetch images by category
  static Future<List<String>> getImagesByCategory(String category) async {
    try {
      final response = await client
          .from('images')
          .select('url')
          .eq('category', category);

      final List<dynamic> data = response as List<dynamic>;
      return data.map((e) => e['url'] as String).toList();
    } catch (e) {
      // Fallback or log error
      debugPrint('Error fetching images for $category: $e');
      return [];
    }
  }

  // Fetch all images (for explore)
  static Future<List<String>> getAllImages() async {
    try {
      final response = await client
          .from('images')
          .select('url');

      final List<dynamic> data = response as List<dynamic>;
      return data.map((e) => e['url'] as String).toList();
    } catch (e) {
      debugPrint('Error fetching all images: $e');
      return [];
    }
  }

  // --- Likes Feature ---

  // Toggle like for an image
  static Future<bool> toggleLike(String imageUrl) async {
    final user = client.auth.currentUser;
    if (user == null) return false;

    try {
      // Check if already liked
      final isLiked = await isImageLiked(imageUrl);

      if (isLiked) {
        // Unlike
        await client
            .from('likes')
            .delete()
            .eq('user_id', user.id)
            .eq('image_url', imageUrl);
        return false; // Not liked anymore
      } else {
        // Like
        await client.from('likes').insert({
          'user_id': user.id,
          'image_url': imageUrl,
        });
        return true; // Liked
      }
    } catch (e) {
      debugPrint('Error toggling like: $e');
      rethrow;
    }
  }

  // Check if image is liked by current user
  static Future<bool> isImageLiked(String imageUrl) async {
    final user = client.auth.currentUser;
    if (user == null) return false;

    try {
      final response = await client
          .from('likes')
          .select()
          .eq('user_id', user.id)
          .eq('image_url', imageUrl)
          .maybeSingle();
      
      return response != null;
    } catch (e) {
      debugPrint('Error checking like status: $e');
      return false;
    }
  }
  static Future<int> getLikeCount(String imageUrl) async {
    try {
      final count = await client
          .from('likes')
          .count(CountOption.exact)
          .eq('image_url', imageUrl);
      
      return count;
    } catch (e) {
      debugPrint('Error getting like count: $e');
      return 0;
    }
  }

  // Get all images liked by current user
  static Future<List<String>> getLikedImages() async {
    final user = client.auth.currentUser;
    if (user == null) return [];

    try {
      final response = await client
          .from('likes')
          .select('image_url')
          .eq('user_id', user.id);

      final List<dynamic> data = response as List<dynamic>;
      return data.map((e) => e['image_url'] as String).toList();
    } catch (e) {
      debugPrint('Error fetching liked images: $e');
      return [];
    }
  }

  // --- Quotes Feature ---

  // --- Quotes Feature ---

  // Fetch quotes
  static Future<List<Map<String, dynamic>>> getQuotes() async {
    try {
      final response = await client
          .from('quotes')
          .select('id, text, author, category');

      final List<dynamic> data = response as List<dynamic>;
      return data.map((e) => {
        'id': e['id'] as int,
        'text': e['text'] as String,
        'author': (e['author'] as String?) ?? 'Unknown',
        'category': (e['category'] as String?) ?? 'Uncategorized',
      }).toList();
    } catch (e) {
      debugPrint('Error fetching quotes: $e');
      return [];
    }
  }

  // Fetch quotes by category
  static Future<List<Map<String, dynamic>>> getQuotesByCategory(String category) async {
    try {
      final response = await client
          .from('quotes')
          .select('id, text, author, category')
          .eq('category', category)
          .order('created_at', ascending: false);

      final List<dynamic> data = response as List<dynamic>;
      return data.map((e) => {
        'id': e['id'] as int,
        'text': e['text'] as String,
        'author': (e['author'] as String?) ?? 'Unknown',
        'category': (e['category'] as String?) ?? 'Uncategorized',
      }).toList();
    } catch (e) {
      debugPrint('Error fetching quotes for $category: $e');
      return [];
    }
  }

  // Toggle like for a quote
  static Future<bool> toggleQuoteLike(int quoteId) async {
    final user = client.auth.currentUser;
    if (user == null) return false;

    try {
      final isLiked = await isQuoteLiked(quoteId);

      if (isLiked) {
        await client
            .from('quote_likes')
            .delete()
            .eq('user_id', user.id)
            .eq('quote_id', quoteId);
        return false;
      } else {
        await client.from('quote_likes').insert({
          'user_id': user.id,
          'quote_id': quoteId,
        });
        return true;
      }
    } catch (e) {
      debugPrint('Error toggling quote like: $e');
      rethrow;
    }
  }

  // Check if quote is liked
  static Future<bool> isQuoteLiked(int quoteId) async {
    final user = client.auth.currentUser;
    if (user == null) return false;

    try {
      final response = await client
          .from('quote_likes')
          .select()
          .eq('user_id', user.id)
          .eq('quote_id', quoteId)
          .maybeSingle();
      
      return response != null;
    } catch (e) {
      debugPrint('Error checking quote like status: $e');
      return false;
    }
  }

  // Get like count for a quote
  static Future<int> getQuoteLikeCount(int quoteId) async {
    try {
      final count = await client
          .from('quote_likes')
          .count(CountOption.exact)
          .eq('quote_id', quoteId);
      
      return count;
    } catch (e) {
      debugPrint('Error getting quote like count: $e');
      return 0;
    }
  }
}
