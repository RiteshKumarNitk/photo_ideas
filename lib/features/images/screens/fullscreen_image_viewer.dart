import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:share_plus/share_plus.dart';
import '../../../utils/image_downloader.dart';
import '../../../core/services/supabase_service.dart';

class FullscreenImageViewer extends StatefulWidget {
  final String imageUrl;

  const FullscreenImageViewer({super.key, required this.imageUrl});

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
    final isLiked = await SupabaseService.isImageLiked(widget.imageUrl);
    final count = await SupabaseService.getLikeCount(widget.imageUrl);
    if (mounted) {
      setState(() {
        _isLiked = isLiked;
        _likeCount = count;
      });
    }
  }

  Future<void> _toggleLike() async {
    try {
      final newStatus = await SupabaseService.toggleLike(widget.imageUrl);
      final newCount = await SupabaseService.getLikeCount(widget.imageUrl);
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
              Share.share('Check out this photo idea: ${widget.imageUrl}');
            },
          ),
          IconButton(
            icon: const Icon(Icons.download, color: Colors.white),
            onPressed: () async {
              final success = await ImageDownloader.downloadImage(widget.imageUrl);
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
      body: PhotoView(
        imageProvider: NetworkImage(widget.imageUrl),
        minScale: PhotoViewComputedScale.contained,
        maxScale: PhotoViewComputedScale.covered * 2,
        heroAttributes: PhotoViewHeroAttributes(tag: widget.imageUrl),
      ),
    );
  }
}
