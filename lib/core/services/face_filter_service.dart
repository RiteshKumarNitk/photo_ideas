
import 'package:flutter/foundation.dart';
import '../../features/images/models/face_filter_model.dart';
import 'supabase_service.dart';

class FaceFilterService {
  static List<FaceFilter>? _cachedFilters;

  // Fetch filters from Supabase, fallback to local repository if empty or error
  static Future<List<FaceFilter>> getFilters() async {
    if (_cachedFilters != null) return _cachedFilters!;

    try {
      final data = await SupabaseService.getFaceFilters();
      
      if (data.isNotEmpty) {
        final dynamicFilters = data.map((json) => FaceFilter.fromJson(json)).toList();
        // Ensure "None" is first
        _cachedFilters = [
          FilterRepository.filters.firstWhere((f) => f.type == FaceFilterCapability.none),
          ...dynamicFilters
        ];
      } else {
        // Fallback to hardcoded if DB is empty (for transition)
        _cachedFilters = FilterRepository.filters;
      }
    } catch (e) {
      debugPrint("Error loading filters from DB: $e");
      // Fallback on error
      _cachedFilters = FilterRepository.filters;
    }

    return _cachedFilters!;
  }

  // Force refresh
  static Future<void> refreshFilters() async {
    _cachedFilters = null;
    await getFilters();
  }
}
