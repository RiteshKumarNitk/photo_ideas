import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/models/photo_model.dart';
import '../../../core/services/supabase_service.dart';
import '../../../utils/image_downloader.dart';
import 'fullscreen_image_viewer.dart';
import 'magic_camera_screen.dart';

class ImageDetailScreen extends StatefulWidget {
  final PhotoModel photo;
  final String? heroTag;

  const ImageDetailScreen({super.key, required this.photo, this.heroTag});

  @override
  State<ImageDetailScreen> createState() => _ImageDetailScreenState();
}

class _ImageDetailScreenState extends State<ImageDetailScreen> {
  bool _isLiked = false;
  int _likeCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchLikeStatus();
  }

  Future<void> _fetchLikeStatus() async {
    final isLiked = await SupabaseService.isImageLiked(widget.photo.url);
    final count = await SupabaseService.getLikeCount(widget.photo.url);
    if (mounted) {
      setState(() {
        _isLiked = isLiked;
        _likeCount = count;
      });
    }
  }

  Future<void> _toggleLike() async {
    try {
      final newStatus = await SupabaseService.toggleLike(widget.photo.url);
      final newCount = await SupabaseService.getLikeCount(widget.photo.url);
      if (mounted) {
        setState(() {
          _isLiked = newStatus;
          _likeCount = newCount;
        });
      }
    } catch (e) {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 400.0,
            floating: false,
            pinned: true,
            backgroundColor: Colors.black,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  GestureDetector(
                    onTap: () {
                       // Navigate to Fullscreen Zoom
                       Navigator.push(
                         context,
                         MaterialPageRoute(
                           builder: (context) => FullscreenImageViewer(
                             photo: widget.photo,
                             heroTag: widget.heroTag,
                           ),
                         ),
                       );
                    },
                    child: Hero(
                      tag: widget.heroTag ?? widget.photo.url,
                      child: Image.network(
                        widget.photo.url,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // Gradient Overlay for Text Visibility
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.3),
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                   Positioned(
                    bottom: 20,
                    right: 20,
                    child: FloatingActionButton(
                      heroTag: 'zoom_btn',
                      mini: true,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      onPressed: () {
                         Navigator.push(
                         context,
                         MaterialPageRoute(
                           builder: (context) => FullscreenImageViewer(
                             photo: widget.photo,
                             heroTag: widget.heroTag,
                           ),
                         ),
                       );
                      },
                      child: const Icon(Icons.zoom_out_map, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  _isLiked ? Icons.favorite : Icons.favorite_border,
                  color: _isLiked ? Colors.red : Colors.white,
                ),
                onPressed: _toggleLike,
              ),
              IconButton(
                icon: const Icon(Icons.download_rounded, color: Colors.white),
                onPressed: () async {
                   final success = await ImageDownloader.downloadImage(widget.photo.url);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(success ? "Downloaded" : "Failed")));
                    }
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title & Metadata
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.photo.category,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.favorite, color: Colors.redAccent, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  "$_likeCount Likes",
                                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                                ),
                                const SizedBox(width: 16),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text("PRO TIP", style: TextStyle(color: Colors.amber, fontSize: 10, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  
                  // Content Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.lightbulb_outline, color: Colors.yellowAccent.withOpacity(0.8)),
                            const SizedBox(width: 12),
                            const Text(
                              "Posing & Lighting",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          widget.photo.posingInstructions,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 100), // Space for FAB
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SizedBox(
          width: double.infinity,
          height: 60,
          child: FloatingActionButton.extended(
            onPressed: () {
               Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MagicCameraScreen(photo: widget.photo)),
              );
            },
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            icon: const Icon(Icons.camera_alt),
            label: const Text(
              "Try Magic Camera",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}
