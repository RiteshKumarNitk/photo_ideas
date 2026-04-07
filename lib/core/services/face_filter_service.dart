import 'package:flutter/foundation.dart';
import '../../features/images/models/face_filter_model.dart';
import 'api_service.dart';

class FaceFilterService {
  static List<FaceFilter>? _cachedFilters;

  static Future<List<FaceFilter>> getFilters() async {
    if (_cachedFilters != null) return _cachedFilters!;

    try {
      final data = await ApiService.getFaceFilters();

      if (data.isNotEmpty) {
        final dynamicFilters = data
            .map((json) => FaceFilter.fromJson(json))
            .toList();
        _cachedFilters = [
          FilterRepository.filters.firstWhere(
            (f) => f.type == FaceFilterCapability.none,
          ),
          ...dynamicFilters,
        ];
      } else {
        _cachedFilters = FilterRepository.filters;
      }
    } catch (e) {
      debugPrint("Error loading filters from API: $e");
      _cachedFilters = FilterRepository.filters;
    }

    return _cachedFilters!;
  }

  static Future<void> refreshFilters() async {
    _cachedFilters = null;
    await getFilters();
  }
}
