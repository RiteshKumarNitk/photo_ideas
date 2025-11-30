import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/app_assets_service.dart';
import 'admin_upload_screen.dart';
import 'admin_edit_image_screen.dart';

class AdminImagesScreen extends StatefulWidget {
  const AdminImagesScreen({super.key});

  @override
  State<AdminImagesScreen> createState() => _AdminImagesScreenState();
}

class _AdminImagesScreenState extends State<AdminImagesScreen> {
  List<Map<String, dynamic>> _allImages = [];
  List<Map<String, dynamic>> _filteredImages = [];
  bool _isLoading = true;
  String _selectedCategory = 'All';
  List<String> _categories = ['All'];

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  Future<void> _loadImages() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final response = await Supabase.instance.client
          .from('images')
          .select()
          .order('created_at', ascending: false);
      
      if (mounted) {
        final images = List<Map<String, dynamic>>.from(response);
        final categories = <String>{'All'};
        for (var img in images) {
          if (img['category'] != null) {
            categories.add(img['category']);
          }
        }

        setState(() {
          _allImages = images;
          _categories = categories.toList()..sort();
          _filterImages();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading images: $e')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  void _filterImages() {
    if (_selectedCategory == 'All') {
      _filteredImages = List.from(_allImages);
    } else {
      _filteredImages = _allImages.where((img) => img['category'] == _selectedCategory).toList();
    }
  }

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
      _filterImages();
    });
  }

  Future<void> _deleteImage(String id, String url) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Image'),
        content: const Text('Are you sure you want to delete this image?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;
      final bucketIndex = pathSegments.indexOf('images');
      if (bucketIndex != -1 && bucketIndex + 1 < pathSegments.length) {
        final filePath = pathSegments.sublist(bucketIndex + 1).join('/');
        await Supabase.instance.client.storage.from('images').remove([filePath]);
      }

      await Supabase.instance.client.from('images').delete().eq('id', id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image deleted successfully')),
        );
        _loadImages();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting image: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Manage Images', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white.withOpacity(0.2),
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withOpacity(0.2)),
        ),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AdminUploadScreen()),
          );
          _loadImages();
        },
        child: const Icon(Icons.add),
      ),
      body: Stack(
        children: [
          // Background Image
          FutureBuilder<String>(
            future: AppAssetsService.getAssetUrl('admin_background'),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return Container(color: Colors.black);
              return Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(snapshot.data!),
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
          // Dark Gradient Overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.8),
                  Colors.black.withOpacity(0.6),
                ],
              ),
            ),
          ),
          // Content
          Column(
            children: [
              const SizedBox(height: 100), // Spacer for AppBar
              
              // Category Filter
              if (!_isLoading && _categories.length > 1)
                Container(
                  height: 50,
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      final isSelected = _selectedCategory == category;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(category),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) _onCategorySelected(category);
                          },
                          selectedColor: Colors.blueAccent.withOpacity(0.5),
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
                    : _filteredImages.isEmpty
                        ? const Center(child: Text('No images found', style: TextStyle(color: Colors.white)))
                        : MasonryGridView.count(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                            crossAxisCount: 2,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            itemCount: _filteredImages.length,
                            itemBuilder: (context, index) {
                              final image = _filteredImages[index];
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Stack(
                                          children: [
                                            Image.network(
                                              image['url'],
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) => 
                                                Container(
                                                  height: 150, 
                                                  color: Colors.white.withOpacity(0.1),
                                                  child: const Center(child: Icon(Icons.error, color: Colors.white)),
                                                ),
                                            ),
                                            Positioned(
                                              top: 8,
                                              right: 8,
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: Colors.black54,
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  image['category'] ?? 'All',
                                                  style: const TextStyle(color: Colors.white, fontSize: 10),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(12.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                image['title'] ?? 'No Title',
                                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 4),
                                              if (image['sub_category'] != null)
                                                Text(
                                                  image['sub_category'],
                                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                    color: Colors.white70,
                                                    fontSize: 10,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              const SizedBox(height: 8),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                children: [
                                                  InkWell(
                                                    onTap: () async {
                                                      final result = await Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) => AdminEditImageScreen(imageData: image),
                                                        ),
                                                      );
                                                      if (result == true) {
                                                        _loadImages();
                                                      }
                                                    },
                                                    child: const Padding(
                                                      padding: EdgeInsets.all(4.0),
                                                      child: Icon(Icons.edit, color: Colors.blueAccent, size: 20),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  InkWell(
                                                    onTap: () => _deleteImage(image['id'], image['url']),
                                                    child: const Padding(
                                                      padding: EdgeInsets.all(4.0),
                                                      child: Icon(Icons.delete, color: Colors.redAccent, size: 20),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
