import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class ApiService {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://photo-ideas-api.vercel.app/api',
  );

  // For local testing only - use: flutter run --dart-define=API_BASE_URL=http://localhost:3000/api
  // static const String baseUrl = 'http://localhost:3000/api';

  static String? _token;
  static Map<String, dynamic>? _currentUser;

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');

    if (_token != null) {
      if (JwtDecoder.isExpired(_token!)) {
        await logout();
      } else {
        _currentUser = JwtDecoder.decode(_token!);
      }
    }
  }

  static String? get token => _token;
  static Map<String, dynamic>? get currentUser => _currentUser;
  static bool get isAuthenticated =>
      _token != null && !JwtDecoder.isExpired(_token!);

  static Future<Map<String, String>> _getHeaders() async {
    final headers = {'Content-Type': 'application/json'};
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  static Future<void> setToken(String token) async {
    _token = token;
    _currentUser = JwtDecoder.decode(token);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  // --- Auth ---

  static Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await setToken(data['token']);
        _currentUser = data['user'];
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Login error: $e');
      return false;
    }
  }

  static Future<bool> signup(
    String email,
    String password,
    String username,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'username': username,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        await setToken(data['token']);
        _currentUser = data['user'];
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Signup error: $e');
      return false;
    }
  }

  static Future<void> logout() async {
    _token = null;
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // --- User ---

  static Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/me'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching user: $e');
      return null;
    }
  }

  // --- Categories ---

  static Future<List<Map<String, dynamic>>> getCategories() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/categories'));

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching categories: $e');
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getSubCategories(
    String categoryId,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/categories/subcategories?categoryId=$categoryId'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching subcategories: $e');
      return [];
    }
  }

  static Future<bool> addCategory(String name, {String? imageUrl}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/categories'),
        headers: await _getHeaders(),
        body: jsonEncode({'name': name, 'imageUrl': imageUrl}),
      );
      return response.statusCode == 201;
    } catch (e) {
      debugPrint('Error adding category: $e');
      return false;
    }
  }

  static Future<bool> addSubCategory(String categoryId, String name) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/categories/subcategories'),
        headers: await _getHeaders(),
        body: jsonEncode({'categoryId': categoryId, 'name': name}),
      );
      return response.statusCode == 201;
    } catch (e) {
      debugPrint('Error adding subcategory: $e');
      return false;
    }
  }

  static Future<bool> deleteCategory(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/categories/$id'),
        headers: await _getHeaders(),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error deleting category: $e');
      return false;
    }
  }

  static Future<bool> deleteSubCategory(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/categories/subcategories/$id'),
        headers: await _getHeaders(),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error deleting subcategory: $e');
      return false;
    }
  }

  // --- Photos ---

  static Future<List<Map<String, dynamic>>> getPhotos({
    String? categoryId,
    String? subCategoryId,
  }) async {
    try {
      final params = <String, String>{};
      if (categoryId != null) params['categoryId'] = categoryId;
      if (subCategoryId != null) params['subCategoryId'] = subCategoryId;

      final uri = Uri.parse(
        '$baseUrl/photos',
      ).replace(queryParameters: params.isEmpty ? null : params);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching photos: $e');
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getAllImages() async {
    return getPhotos();
  }

  static Future<List<Map<String, dynamic>>> getImagesByCategory(
    String categoryName,
  ) async {
    try {
      final uri = Uri.parse(
        '$baseUrl/photos',
      ).replace(queryParameters: {'categoryName': categoryName});
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching images by category: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>?> getPhotoById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/photos/$id'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching photo: $e');
      return null;
    }
  }

  // --- Likes ---

  static Future<bool> toggleLike(String photoId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/photos/like'),
        headers: await _getHeaders(),
        body: jsonEncode({'photoId': photoId}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body)['liked'] ?? false;
      }
      return false;
    } catch (e) {
      debugPrint('Error toggling like: $e');
      return false;
    }
  }

  static Future<bool> isPhotoLiked(String photoId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/photos/like?photoId=$photoId'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body)['liked'] ?? false;
      }
      return false;
    } catch (e) {
      debugPrint('Error checking like status: $e');
      return false;
    }
  }

  static Future<bool> isImageLiked(String imageUrl) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/photos/like?imageUrl=$imageUrl'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body)['liked'] ?? false;
      }
      return false;
    } catch (e) {
      debugPrint('Error checking like status: $e');
      return false;
    }
  }

  static Future<int> getLikeCount(String imageUrl) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/photos/like?imageUrl=$imageUrl'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body)['count'] ?? 0;
      }
      return 0;
    } catch (e) {
      debugPrint('Error getting like count: $e');
      return 0;
    }
  }

  static Future<List<Map<String, dynamic>>> getLikedPhotos() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/photos/liked'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching liked photos: $e');
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getLikedImages() async {
    return getLikedPhotos();
  }

  // --- Quotes ---

  static Future<List<Map<String, dynamic>>> getQuotesByCategory(
    String category,
  ) async {
    return getQuotes(category: category);
  }

  static Future<List<Map<String, dynamic>>> getQuotes({
    String? category,
  }) async {
    try {
      final uri = category != null
          ? Uri.parse('$baseUrl/quotes?category=$category')
          : Uri.parse('$baseUrl/quotes');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching quotes: $e');
      return [];
    }
  }

  static Future<bool> addQuote({
    required String content,
    String? author,
    String category = 'General',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/quotes'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'content': content,
          'author': author ?? 'Unknown',
          'category': category,
        }),
      );
      return response.statusCode == 201;
    } catch (e) {
      debugPrint('Error adding quote: $e');
      return false;
    }
  }

  static Future<bool> updateQuote({
    required String id,
    required String content,
    String? author,
    String? category,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/quotes/$id'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'content': content,
          if (author != null) 'author': author,
          if (category != null) 'category': category,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error updating quote: $e');
      return false;
    }
  }

  static Future<bool> deleteQuote(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/quotes/$id'),
        headers: await _getHeaders(),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error deleting quote: $e');
      return false;
    }
  }

  static Future<bool> toggleQuoteLike(String quoteId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/quotes/$quoteId/like'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body)['liked'] ?? false;
      }
      return false;
    } catch (e) {
      debugPrint('Error toggling quote like: $e');
      return false;
    }
  }

  static Future<Map<String, dynamic>> getQuoteLikeStatus(String quoteId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/quotes/$quoteId/like'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {'liked': false};
    } catch (e) {
      debugPrint('Error getting quote like status: $e');
      return {'liked': false};
    }
  }

  // --- Face Filters ---

  static Future<List<Map<String, dynamic>>> getFaceFilters() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/filters'));

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching face filters: $e');
      return [];
    }
  }

  static Future<bool> addFaceFilter({
    required String name,
    String? imageUrl,
    String? thumbnailUrl,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/filters'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'name': name,
          'imageUrl': imageUrl,
          'thumbnailUrl': thumbnailUrl,
        }),
      );
      return response.statusCode == 201;
    } catch (e) {
      debugPrint('Error adding face filter: $e');
      return false;
    }
  }

  static Future<bool> deleteFaceFilter(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/filters/$id'),
        headers: await _getHeaders(),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error deleting face filter: $e');
      return false;
    }
  }

  // --- Photo Upload (Admin) ---

  static Future<bool> uploadPhoto({
    required String imageUrl,
    String? title,
    String? description,
    String? categoryId,
    String? subCategoryId,
    String? posingInstructions,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/photos'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'imageUrl': imageUrl,
          if (title != null) 'title': title,
          if (description != null) 'description': description,
          if (categoryId != null) 'categoryId': categoryId,
          if (subCategoryId != null) 'subCategoryId': subCategoryId,
          if (posingInstructions != null)
            'posingInstructions': posingInstructions,
        }),
      );
      return response.statusCode == 201;
    } catch (e) {
      debugPrint('Error uploading photo: $e');
      return false;
    }
  }

  static Future<bool> updatePhoto({
    required String id,
    String? title,
    String? description,
    String? imageUrl,
    String? categoryId,
    String? subCategoryId,
    String? posingInstructions,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/photos/$id'),
        headers: await _getHeaders(),
        body: jsonEncode({
          if (title != null) 'title': title,
          if (description != null) 'description': description,
          if (imageUrl != null) 'imageUrl': imageUrl,
          if (categoryId != null) 'categoryId': categoryId,
          if (subCategoryId != null) 'subCategoryId': subCategoryId,
          if (posingInstructions != null)
            'posingInstructions': posingInstructions,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error updating photo: $e');
      return false;
    }
  }

  static Future<bool> deletePhoto(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/photos/$id'),
        headers: await _getHeaders(),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error deleting photo: $e');
      return false;
    }
  }

  // --- Profile ---

  static Future<bool> updateProfile({
    String? username,
    String? fullName,
    String? avatar,
    String? bio,
    String? phoneNumber,
    String? gender,
    String? avatarUrl,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/auth/profile'),
        headers: await _getHeaders(),
        body: jsonEncode({
          if (username != null) 'username': username,
          if (fullName != null) 'fullName': fullName,
          if (avatar != null) 'avatar': avatar,
          if (avatarUrl != null) 'avatar': avatarUrl,
          if (bio != null) 'bio': bio,
          if (phoneNumber != null) 'phoneNumber': phoneNumber,
          if (gender != null) 'gender': gender,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error updating profile: $e');
      return false;
    }
  }

  // --- Password Reset ---

  static Future<bool> requestPasswordReset(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error requesting password reset: $e');
      return false;
    }
  }

  static Future<bool> resetPassword(String token, String newPassword) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'token': token, 'newPassword': newPassword}),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error resetting password: $e');
      return false;
    }
  }

  // --- File Upload ---

  static Future<Map<String, dynamic>?> uploadFile(
    List<int> bytes,
    String fileName,
    String bucket,
  ) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/upload/$bucket'),
      );
      if (_token != null) {
        request.headers['Authorization'] = 'Bearer $_token';
      }
      request.files.add(
        http.MultipartFile.fromBytes('file', bytes, filename: fileName),
      );
      request.fields['bucket'] = bucket;

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('Error uploading file: $e');
      return null;
    }
  }

  static Future<bool> deleteFile(String publicId, String bucket) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/upload/$bucket?publicId=$publicId'),
        headers: await _getHeaders(),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error deleting file: $e');
      return false;
    }
  }
}
