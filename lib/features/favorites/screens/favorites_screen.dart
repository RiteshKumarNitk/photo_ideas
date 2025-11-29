import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/services/supabase_service.dart';
import '../../images/screens/fullscreen_image_viewer.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<String> _likedImages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() => _isLoading = true);
    final images = await SupabaseService.getLikedImages();
    if (mounted) {
      setState(() {
        _likedImages = images;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Favorites")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _likedImages.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.favorite_border, size: 64, color: Colors.grey[600]),
                      const SizedBox(height: 16),
                      Text(
                        "No favorites yet",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: MasonryGridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    itemCount: _likedImages.length,
                    itemBuilder: (context, index) {
                      final imageUrl = _likedImages[index];
                      return GestureDetector(
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FullscreenImageViewer(imageUrl: imageUrl),
                            ),
                          );
                          // Refresh list when coming back, in case user unliked
                          _loadFavorites();
                        },
                        child: Hero(
                          tag: imageUrl + "fav",
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
    );
  }
}
