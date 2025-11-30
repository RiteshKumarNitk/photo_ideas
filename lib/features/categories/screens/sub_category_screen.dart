import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../../core/models/photo_model.dart';
import 'category_grid_screen.dart';

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/models/photo_model.dart';
import 'category_grid_screen.dart';

class SubCategoryScreen extends StatefulWidget {
  final String title;
  final List<PhotoModel> allImages;
  final Map<String, List<PhotoModel>> subCategories;

  const SubCategoryScreen({
    super.key,
    required this.title,
    required this.allImages,
    required this.subCategories,
  });

  @override
  State<SubCategoryScreen> createState() => _SubCategoryScreenState();
}

class _SubCategoryScreenState extends State<SubCategoryScreen> {
  late Map<String, List<PhotoModel>> _subCategories;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _subCategories = widget.subCategories;
    if (_subCategories.isEmpty) {
      _fetchSubCategories();
    }
  }

  Future<void> _fetchSubCategories() async {
    setState(() => _isLoading = true);
    try {
      final response = await Supabase.instance.client
          .from('images')
          .select()
          .eq('category', widget.title);

      final List<PhotoModel> images = (response as List)
          .map((item) => PhotoModel.fromJson(item))
          .toList();

      // Group by sub_category
      final Map<String, List<PhotoModel>> grouped = {};
      
      // Add 'All' category implicitly if needed, or just rely on sub_categories
      // The Sync logic added 'sub_category' field.
      
      for (var img in images) {
        // We need to access the raw JSON to get sub_category as it might not be in PhotoModel yet
        // Wait, PhotoModel doesn't have sub_category field in the version I saw earlier.
        // I need to check PhotoModel or use the raw response for grouping.
        // Let's check the raw response item for 'sub_category'.
        final rawItem = response.firstWhere((element) => element['url'] == img.url, orElse: () => {});
        final subCat = rawItem['sub_category'] as String? ?? 'General';
        
        if (!grouped.containsKey(subCat)) {
          grouped[subCat] = [];
        }
        grouped[subCat]!.add(img);
      }

      if (mounted) {
        setState(() {
          _subCategories = grouped;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching subcategories: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Extract sub-category names
    final keys = _subCategories.keys.toList()..sort();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(
                  'https://images.unsplash.com/photo-1492691527719-9d1e07e534b4?auto=format&fit=crop&w=1000&q=80',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Blur Effect
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              color: Colors.black.withOpacity(0.4),
            ),
          ),
          // Content
          _isLoading 
              ? const Center(child: CircularProgressIndicator(color: Colors.white))
              : keys.isEmpty
                  ? const Center(child: Text("No ideas found", style: TextStyle(color: Colors.white)))
                  : Padding(
                      padding: const EdgeInsets.fromLTRB(16, 100, 16, 16),
                      child: MasonryGridView.count(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        itemCount: keys.length,
                        itemBuilder: (context, index) {
                          final key = keys[index];
                          final count = _subCategories[key]?.length ?? 0;
                          
                          return _buildGlassSubCategoryGridItem(
                            context, 
                            title: key, 
                            count: count,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CategoryGridScreen(
                                    title: "${widget.title} - $key",
                                    fallbackImages: _subCategories[key] ?? [],
                                    // We don't pass filters here because we are already drilled down
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
        ],
      ),
    );
  }

  Widget _buildGlassSubCategoryGridItem(
    BuildContext context, {
    required String title,
    required int count,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _getSubCategoryIcon(title),
                  color: Colors.white,
                  size: 32,
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  "$count ideas",
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getSubCategoryIcon(String title) {
    final lowerTitle = title.toLowerCase();
    if (lowerTitle.contains('men') && !lowerTitle.contains('women')) return Icons.man;
    if (lowerTitle.contains('women')) return Icons.woman;
    if (lowerTitle.contains('short')) return Icons.content_cut;
    if (lowerTitle.contains('long')) return Icons.waves;
    if (lowerTitle.contains('couple')) return Icons.favorite;
    if (lowerTitle.contains('bride')) return Icons.person_3;
    if (lowerTitle.contains('groom')) return Icons.person;
    if (lowerTitle.contains('decor')) return Icons.local_florist;
    if (lowerTitle.contains('newborn')) return Icons.child_friendly;
    if (lowerTitle.contains('family')) return Icons.family_restroom;
    if (lowerTitle.contains('outdoor')) return Icons.forest;
    if (lowerTitle.contains('landscape')) return Icons.landscape;
    if (lowerTitle.contains('beach')) return Icons.beach_access;
    if (lowerTitle.contains('city')) return Icons.location_city;
    if (lowerTitle.contains('adventure')) return Icons.hiking;
    if (lowerTitle.contains('modern')) return Icons.apartment;
    if (lowerTitle.contains('historic')) return Icons.castle;
    return Icons.category;
  }
}
