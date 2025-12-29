import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../../utils/data_source.dart';
import '../../images/screens/fullscreen_image_viewer.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/models/photo_model.dart';

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
    return SafeArea(
      child: Column(
        children: [
          // Search Bar & View Toggle
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 60, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) => _applyFilters(),
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
                const SizedBox(width: 12),
                // Grid/List Toggle
                GestureDetector(
                  onTap: () => setState(() => _isGridMode = !_isGridMode),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        color: Colors.white.withOpacity(0.1),
                        child: Icon(
                          _isGridMode ? Icons.view_agenda_outlined : Icons.grid_view,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Filters
          Container(
            height: 50,
            margin: const EdgeInsets.only(bottom: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filters.length,
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) _onFilterSelected(filter);
                    },
                    backgroundColor: Colors.white.withOpacity(0.1),
                    selectedColor: Colors.white,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.black : Colors.white,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: Colors.white.withOpacity(0.2)),
                    ),
                  ),
                );
              },
            ),
          ),

          // Grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: MasonryGridView.count(
                crossAxisCount: _isGridMode ? 2 : 1,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                itemCount: _displayedImages.length,
                itemBuilder: (context, index) {
                  final photo = _displayedImages[index];
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
                            height: (index % 2 == 0 && _isGridMode) ? 200 : 300,
                            width: double.infinity,
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
