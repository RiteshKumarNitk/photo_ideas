import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../images/screens/fullscreen_image_viewer.dart';
import '../../../core/services/supabase_service.dart';

class CategoryGridScreen extends StatefulWidget {
  final String title;
  final List<String> fallbackImages; // Used if Supabase fails or is empty
  final Map<String, List<String>>? filters;

  const CategoryGridScreen({
    super.key,
    required this.title,
    required this.fallbackImages,
    this.filters,
  });

  @override
  State<CategoryGridScreen> createState() => _CategoryGridScreenState();
}

class _CategoryGridScreenState extends State<CategoryGridScreen> {
  List<String> _displayedImages = [];
  bool _isLoading = true;
  late ScrollController _scrollController;
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _loadImages();
  }

  Future<void> _loadImages() async {
    setState(() => _isLoading = true);
    
    // Try to fetch from Supabase
    // Map title to category key if needed, or use title directly
    // Assuming title matches category in DB for simplicity
    List<String> images = await SupabaseService.getImagesByCategory(widget.title);

    if (images.isEmpty) {
      images = widget.fallbackImages;
    }

    if (mounted) {
      setState(() {
        _displayedImages = images;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onFilterSelected(String filter) {
    // For now, filters are only implemented for local fallback data in this demo
    // To implement real filtering with Supabase, we'd need to query with filter params
    setState(() {
      _selectedFilter = filter;
      if (widget.filters != null && widget.filters!.containsKey(filter)) {
        _displayedImages = List.from(widget.filters![filter]!);
      } else {
        // Reset to initial loaded images (which might be from Supabase or fallback)
        // Ideally we should re-fetch with filter from Supabase
        _loadImages(); 
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Column(
        children: [
          if (widget.filters != null)
            Container(
              height: 60,
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: widget.filters!.keys.length,
                itemBuilder: (context, index) {
                  final filter = widget.filters!.keys.elementAt(index);
                  final isSelected = _selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(filter),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          _onFilterSelected(filter);
                        }
                      },
                      selectedColor: Theme.of(context).primaryColor,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.white70,
                      ),
                      backgroundColor: Colors.grey[800],
                    ),
                  );
                },
              ),
            ),
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: MasonryGridView.count(
                    controller: _scrollController,
                    crossAxisCount: 2,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    itemCount: _displayedImages.length,
                    itemBuilder: (context, index) {
                      final imageUrl = _displayedImages[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FullscreenImageViewer(imageUrl: imageUrl),
                            ),
                          );
                        },
                        child: Hero(
                          tag: imageUrl + index.toString(),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CachedNetworkImage(
                              imageUrl: imageUrl,
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
