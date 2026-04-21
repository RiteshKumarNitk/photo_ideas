import 'package:appinio_swiper/appinio_swiper.dart';
import 'package:flutter/material.dart';
import '../../../core/models/photo_model.dart';
import '../../../core/services/api_service.dart';

import '../../auth/screens/login_screen.dart';
import 'dart:ui';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

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
    try {
      final haircut = await ApiService.getImagesByCategory("Haircut Ideas");
      final wedding = await ApiService.getImagesByCategory("Wedding Photos");
      final nature = await ApiService.getImagesByCategory("Nature");

      final allImages = [...haircut, ...wedding, ...nature]..shuffle();

      final photos = allImages
          .take(20)
          .map((item) => PhotoModel.fromJson(item))
          .toList();

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

  void _onSwipe(int previousIndex, int targetIndex, SwiperActivity activity) {
    if (activity is Swipe && activity.direction == AxisDirection.right) {
      if (previousIndex >= 0 && previousIndex < _photos.length) {
        _saveToFavorites(_photos[previousIndex]);
      }
    }
  }

  Future<void> _saveToFavorites(PhotoModel photo) async {
    if (!ApiService.isAuthenticated) return;

    await ApiService.toggleLike(photo.url);
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

  void _handleLikeAction() {
    if (!ApiService.isAuthenticated) {
      _showLoginPrompt();
    } else {
      _swiperController.swipeRight();
    }
  }

  void _showLoginPrompt() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Sign In Required',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'You need to sign in to save your likes.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
            child: const Text('Sign In', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (_photos.isEmpty) {
      return const Center(
        child: Text(
          "No more ideas to discover!",
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        title: Text(
          "Style Swipe",
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      extendBodyBehindAppBar: true,
      body: Column(
        children: [
          Expanded(
            child: AppinioSwiper(
              controller: _swiperController,
              cardCount: _photos.length,
              onSwipeEnd: _onSwipe,
              cardBuilder: (context, index) {
                final photo = _photos[index];
                return ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(photo.url, fit: BoxFit.cover),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.8),
                            ],
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
                              style: GoogleFonts.outfit(
                                color: Colors.white70,
                                fontSize: 14,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Swipe Right to Like",
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ).animate().scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1), duration: 400.ms, curve: Curves.easeOutBack);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(
                  Icons.close_rounded,
                  AppTheme.accentColor,
                  () => _swiperController.swipeLeft(),
                ),
                _buildActionButton(Icons.info_outline, Colors.blue, () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Swipe right to save!")),
                  );
                }),
                _buildActionButton(
                  Icons.favorite_rounded,
                  AppTheme.secondaryColor,
                  _handleLikeAction,
                ),
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
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
          border: Border.all(color: color.withOpacity(0.3), width: 2),
        ),
        child: Icon(icon, color: color, size: 32),
      ),
    ).animate(onPlay: (controller) => controller.repeat(reverse: true))
     .scale(begin: const Offset(1, 1), end: const Offset(1.05, 1.05), duration: 2.seconds, curve: Curves.easeInOut);
  }
}
