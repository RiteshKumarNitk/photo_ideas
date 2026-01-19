import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/models/photo_model.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/widgets/scale_button.dart';
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
    // Always fetch dynamic data to merge with local data
    _fetchSubCategories();
  }

  Future<void> _fetchSubCategories() async {
    setState(() => _isLoading = true);
    try {
      // 1. Initialize with existing local subcategories
      final Map<String, List<PhotoModel>> grouped = Map.from(widget.subCategories);

      // 2. Fetch Category ID and Explicit Subcategories using Service
      try {
        final allCategories = await SupabaseService.getCategories();
        
        Map<String, dynamic> category = {};
        for (var cat in allCategories) {
          if (cat['name'].toString().toLowerCase() == widget.title.toLowerCase()) {
            category = cat;
            break;
          }
        }

        if (category.isNotEmpty) {
          final int categoryId = category['id'];
          final subCats = await SupabaseService.getSubCategories(categoryId);
          
          for (var sub in subCats) {
            String subName = sub['name'];
            if (!grouped.containsKey(subName)) {
              grouped[subName] = [];
            }
          }
        } else {
             // Fallback: Try removing " Photos" if present
             if (widget.title.contains(' Photos')) {
                 final simplified = widget.title.replaceAll(' Photos', '').trim();
                 
                 Map<String, dynamic> catSimple = {};
                 for (var cat in allCategories) {
                    if (cat['name'].toString().toLowerCase() == simplified.toLowerCase()) {
                       catSimple = cat;
                       break;
                    }
                 }

                 if (catSimple.isNotEmpty) {
                    final int catId = catSimple['id'];
                    final subCats = await SupabaseService.getSubCategories(catId);
                    for (var sub in subCats) {
                      String subName = sub['name'];
                      if (!grouped.containsKey(subName)) {
                        grouped[subName] = [];
                      }
                    }
                 }
             }
        }
      } catch (e) {
        debugPrint('Error fetching explicit subcategories via service: $e');
      }

      // 3. Fetch images from 'images' table
      // We still need the images to populate the folders
      String simplifiedTitle = widget.title;
      bool hasSimplified = false;
      if (widget.title.contains(' Photos')) {
        simplifiedTitle = widget.title.replaceAll(' Photos', '').trim();
        hasSimplified = true;
      }

      dynamic imageResponse;
      if (hasSimplified) {
        imageResponse = await Supabase.instance.client
            .from('images')
            .select()
            .or('category.eq.${widget.title},category.eq.$simplifiedTitle');
      } else {
        imageResponse = await Supabase.instance.client
            .from('images')
            .select()
            .eq('category', widget.title);
      }

      final List<PhotoModel> images = (imageResponse as List)
          .map((item) => PhotoModel.fromJson(item))
          .toList();

      // 4. Distribute images into groups
      for (var img in images) {
        // Find raw item to get sub_category
        Map<String, dynamic> rawItem = {};
        for (var item in (imageResponse as List)) {
           if (item['url'] == img.url) {
             rawItem = item;
             break;
           }
        }
        
        // Fallback logic for sub_category
        final subCat = rawItem['sub_category'] != null ? rawItem['sub_category'] as String : 'General';
        
        if (!grouped.containsKey(subCat)) {
          // Only add 'General' if we have images for it, or if it was explicitly defined (unlikely for General)
          grouped[subCat] = [];
        }
        
        // Check for duplicates before adding
        final exists = grouped[subCat]!.any((element) => element.url == img.url);
        if (!exists) {
          grouped[subCat]!.add(img);
        }
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
    return ScaleButton(
      onPressed: onTap,
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

