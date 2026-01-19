import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../images/screens/fullscreen_image_viewer.dart';
import '../../images/screens/image_detail_screen.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/models/photo_model.dart';
import '../../../core/widgets/scale_button.dart';
import '../../../core/utils/page_transitions.dart';

class CategoryGridScreen extends StatefulWidget {
  final String title;
  final List<PhotoModel> fallbackImages; // Used if Supabase fails or is empty
  final Map<String, List<PhotoModel>>? filters;

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
  List<PhotoModel> _displayedImages = [];
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
    
    // If we have fallback images passed (which might be filtered already), use them first
    // In the new flow, we pass specific lists, so we might not need to fetch again if the list is populated.
    // However, to keep it robust:
    
    List<PhotoModel> images = [];
    if (widget.fallbackImages.isNotEmpty) {
      images = widget.fallbackImages;
    } else {
       // Try to fetch from Supabase if fallback is empty
       // This logic might need adjustment based on how we want to mix local/remote data
       try {
         List<String> imageUrls = await SupabaseService.getImagesByCategory(widget.title);
         images = imageUrls.map((url) => PhotoModel(
            url: url, 
            category: widget.title,
            posingInstructions: "Stand naturally and smile! Ensure good lighting falls on your face."
          )).toList();
       } catch (e) {
         debugPrint("Error loading images: $e");
       }
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
    setState(() {
      _selectedFilter = filter;
      if (widget.filters != null && widget.filters!.containsKey(filter)) {
        _displayedImages = List.from(widget.filters![filter]!);
      } else {
        _loadImages(); 
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
          Column(
            children: [
              // Spacer for AppBar
              const SizedBox(height: 100),
              
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
                          selectedColor: Colors.white.withOpacity(0.3),
                          backgroundColor: Colors.white.withOpacity(0.1),
                          labelStyle: TextStyle(
                            color: Colors.white,
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
              Expanded(
                child: _isLoading 
                  ? const Center(child: CircularProgressIndicator(color: Colors.white))
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: MasonryGridView.count(
                        controller: _scrollController,
                        crossAxisCount: 2,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        itemCount: _displayedImages.length,
                        itemBuilder: (context, index) {
                          final photo = _displayedImages[index];
                          final heroTag = photo.url + index.toString();
                          return ScaleButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                FadeRoute(
                                  page: ImageDetailScreen(
                                    photo: photo,
                                    heroTag: heroTag,
                                  ),
                                ),
                              );
                            },
                            child: Hero(
                              tag: heroTag,
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
                            ),
                          );
                        },
                      ),
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
