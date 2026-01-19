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
  List<PhotoModel> _displayedImages = [];
  bool _isGridMode = true;
  String _selectedFilter = 'All';

  final List<String> _filters = [
    'All', 'Wedding', 'Nature', 'Travel', 'Baby', 'Architecture', 'Haircut', 'Portrait'
  ];

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  Future<void> _loadImages() async {
    // Try to fetch from Supabase
    List<String> imageUrls = await SupabaseService.getAllImages();
    List<PhotoModel> images = [];

    if (imageUrls.isNotEmpty) {
       images = imageUrls.map((url) => PhotoModel(
        url: url,
        category: 'Explore', // We might want to fetch real categories later
        posingInstructions: 'Explore different angles and lighting.',
      )).toList();
    } else {
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
        _applyFilters();
      });
    }
  }

  void _applyFilters() {
    String query = _searchController.text.toLowerCase();
    
    setState(() {
      _displayedImages = _allImages.where((image) {
        // Filter by Search Query
        bool matchesQuery = query.isEmpty || image.category.toLowerCase().contains(query) || 
                            image.posingInstructions.toLowerCase().contains(query);
        
        // Filter by Category Chip (Approximate match since we just have urls mostly from simple fetch)
        // If the 'category' field in PhotoModel is accurate, use it. 
        // Note: In _loadImages, network images get 'Explore' as category.
        // For local images, they have correct categories. 
        // Ideally, we'd fetch category with image from Supabase.
        
        bool matchesFilter = _selectedFilter == 'All';
        if (!matchesFilter) {
           // For now, this might only work well with local data or if we update the fetch logic
           // But let's check the category field.
           matchesFilter = image.category.toLowerCase().contains(_selectedFilter.toLowerCase());
        }

        return matchesQuery && matchesFilter;
      }).toList();
    });
  }

  void _onFilterSelected(String filter) {
    setState(() {
      _selectedFilter = filter;
      _applyFilters();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Note: No Scaffold here because it's used inside HomeScreen's body Stack
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 60, 16, 16), // Top padding for transparent AppBar
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
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
                    fillColor: Colors.white.withOpacity(0.1),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: MasonryGridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                itemCount: _filteredImages.length,
                itemBuilder: (context, index) {
                  final photo = _filteredImages[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FullscreenImageViewer(photo: photo),
                        ),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
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
                        errorWidget: (context, url, error) => const Icon(Icons.error),
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
