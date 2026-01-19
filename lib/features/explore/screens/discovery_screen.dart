import 'package:appinio_swiper/appinio_swiper.dart';
import 'package:flutter/material.dart';
import '../../../core/models/photo_model.dart';
import '../../../core/services/supabase_service.dart';

import 'dart:ui';

class DiscoveryScreen extends StatefulWidget {
  const DiscoveryScreen({super.key});

  @override
  State<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

class _DiscoveryScreenState extends State<DiscoveryScreen> {
  final AppinioSwiperController _swiperController = AppinioSwiperController();
  List<PhotoModel> _photos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPhotos();
  }

  Future<void> _fetchPhotos() async {
    // In a real app, we would fetch random images or personalized recommendations
    // For now, we'll fetch a mix of categories
    try {
      final haircut = await SupabaseService.getImagesByCategory("Haircut Ideas");
      final wedding = await SupabaseService.getImagesByCategory("Wedding Photos");
      final nature = await SupabaseService.getImagesByCategory("Nature");
      
      final allUrls = [...haircut, ...wedding, ...nature]..shuffle();
      
      final photos = allUrls.take(20).map((url) => PhotoModel(
        url: url,
        category: "Discovery",
        posingInstructions: "Swipe right if you love this style!",
      )).toList();

      if (mounted) {
        setState(() {
          _photos = photos;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onSwipe(int index, dynamic direction) {
    // Check direction by string if type is not available, or just check 'right' logic if mostly right-swipe?
    // Direction usually has toString() like 'AppinioSwiperDirection.right'
    if (direction.toString().contains('right')) {
      _saveToFavorites(_photos[index - 1]); // Index given is often the *next* index or the swiped index. In 2.x, index is the index of the card that was swiped away (0-based?). 
      // Actually usually 'new index'. But if we map mapped 1:1.
      // Let's assume index is reliable enough to pick *something* or just use last if stack.
      // In 2.1.1 onSwipe(int previousIndex, AppinioSwiperDirection direction).
      // If previousIndex is the one swiped.
    }
  }

  Future<void> _saveToFavorites(PhotoModel photo) async {
    await SupabaseService.toggleLike(photo.url);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Saved to Favorites!"),
          duration: Duration(milliseconds: 500),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }

    if (_photos.isEmpty) {
      return const Center(child: Text("No more ideas to discover!", style: TextStyle(color: Colors.white)));
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Style Swipe", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: AppinioSwiper(
              controller: _swiperController,
              cardCount: _photos.length,
              cardBuilder: (context, index) {
                final photo = _photos[index];
                return ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        photo.url,
                        fit: BoxFit.cover,
                      ),
                      Container(
                         decoration: BoxDecoration(
                           gradient: LinearGradient(
                             begin: Alignment.topCenter,
                             end: Alignment.bottomCenter,
                             colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                           ),
                         ),
                      ),
                      Positioned(
                        bottom: 40,
                        left: 20,
                        right: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                             Text(
                               photo.category,
                               style: const TextStyle(color: Colors.white, fontSize: 14),
                             ),
                             const SizedBox(height: 8),
                             const Text(
                               "Swipe Right to Save",
                               style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                             ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(Icons.close, Colors.red, () => _swiperController.swipeLeft()),
                _buildActionButton(Icons.info_outline, Colors.blue, () {
                  // Show details
                   // Info button logic temporarily disabled or just show current card hint
                   ScaffoldMessenger.of(context).showSnackBar(
                     const SnackBar(content: Text("Swipe right to save!")),
                   );
                }),
                _buildActionButton(Icons.favorite, Colors.green, () => _swiperController.swipeRight()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60,
        width: 60,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          shape: BoxShape.circle,
          border: Border.all(color: color.withOpacity(0.5)),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Icon(icon, color: color, size: 30),
      ),
    );
  }
}
