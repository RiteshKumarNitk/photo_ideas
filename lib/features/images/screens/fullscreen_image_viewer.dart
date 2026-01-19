import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:share_plus/share_plus.dart';
import '../../../utils/image_downloader.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/models/photo_model.dart';
import 'magic_camera_screen.dart';

class FullscreenImageViewer extends StatefulWidget {
  final PhotoModel photo;
  final String? heroTag;

  const FullscreenImageViewer({super.key, required this.photo, this.heroTag});

  @override
  State<FullscreenImageViewer> createState() => _FullscreenImageViewerState();
}

class _FullscreenImageViewerState extends State<FullscreenImageViewer> {
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update like')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
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
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text(
                '$_likeCount',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () {
              Share.share('Check out this photo idea: ${widget.photo.url}\n\nTip: ${widget.photo.posingInstructions}');
            },
          ),
          IconButton(
            icon: const Icon(Icons.download, color: Colors.white),
            onPressed: () async {
              final success = await ImageDownloader.downloadImage(widget.photo.url);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Image saved to gallery' : 'Failed to save image'),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          PhotoView(
            imageProvider: NetworkImage(widget.photo.url),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 2,
            heroAttributes: PhotoViewHeroAttributes(tag: widget.heroTag ?? widget.photo.url),
          ),
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Posing Tips",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                             decoration: BoxDecoration(
                               color: Colors.white.withOpacity(0.2),
                               borderRadius: BorderRadius.circular(20),
                             ),
                             child: const Text("AI Tip", style: TextStyle(color: Colors.white, fontSize: 12)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.photo.posingInstructions,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 15,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                             Navigator.push(
                               context,
                               MaterialPageRoute(
                                 builder: (context) => MagicCameraScreen(photo: widget.photo),
                               ),
                             );
                          },
                          icon: const Icon(Icons.camera_enhance),
                          label: const Text("Try with Magic Camera"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
