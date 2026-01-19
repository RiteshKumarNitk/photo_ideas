import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../../utils/data_source.dart';
import '../../images/screens/fullscreen_image_viewer.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/models/photo_model.dart';
import '../../../core/widgets/scale_button.dart';
import 'discovery_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<PhotoModel> _allImages = [];
  List<PhotoModel> _filteredImages = [];

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  Future<void> _loadImages() async {
    // Try to fetch from Supabase
    List<String> imageUrls = await SupabaseService.getAllImages();
    List<PhotoModel> images = imageUrls.map((url) => PhotoModel(
      url: url,
      category: 'Explore',
      posingInstructions: 'Explore different angles and lighting.',
    )).toList();

    if (images.isEmpty) {
      // Fallback to local data
      images = [
        ...DataSource.haircutImages,
        ...DataSource.weddingImages,
        ...DataSource.babyImages,
        ...DataSource.natureImages,
        ...DataSource.travelImages,
        ...DataSource.architectureImages,
      ];
    }

    if (mounted) {
      setState(() {
        _allImages = images;
        _allImages.shuffle();
        _filteredImages = _allImages;
      });
    }
  }

  void _filterImages(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredImages = _allImages;
      });
    } else {
      // Mock search: just show a subset
      setState(() {
        _filteredImages = _allImages.take(10).toList(); 
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 110, 16, 16), // Top padding for visual balance with Home Header
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: TextField(
                  controller: _searchController,
                  onChanged: _filterImages,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Search ideas...",
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                    prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.6)),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.15),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                ),
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          sliver: SliverMasonryGrid.count(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childCount: _filteredImages.length,
            itemBuilder: (context, index) {
              final photo = _filteredImages[index];
              return ScaleButton(
                 onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FullscreenImageViewer(photo: photo), // Or ImageDetailScreen if you prefer
                      ),
                    );
                 },
                 child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: CachedNetworkImage(
                    imageUrl: photo.url,
                    placeholder: (context, url) => Shimmer.fromColors(
                      baseColor: Colors.grey[800]!,
                      highlightColor: Colors.grey[700]!,
                      child: Container(
                        color: Colors.grey[800],
                        height: (index % 2 == 0) ? 200 : 300,
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                        height: 200, 
                        color: Colors.grey[900], 
                        child: const Icon(Icons.broken_image, color: Colors.white54)
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)), // Bottom padding
      ],
    );
  }
}
