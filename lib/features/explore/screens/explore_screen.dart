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
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 80, left: 20, right: 20, bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Explore",
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (value) => _applyFilters(),
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: "Search ideas...",
                            hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                            prefixIcon: const Icon(Icons.search, color: Colors.white70),
                            filled: true,
                            fillColor: Colors.transparent, // Color provided by Container
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverMasonryGrid.count(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childCount: _displayedImages.length,
              itemBuilder: (context, index) {
                final photo = _displayedImages[index];
                return ScaleButton(
                   onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FullscreenImageViewer(photo: photo),
                        ),
                      );
                   },
                   child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
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
                        color: Colors.white10,
                        child: const Icon(Icons.error, color: Colors.white54),
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}
