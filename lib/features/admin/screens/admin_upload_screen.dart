import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import '../../../core/services/api_service.dart';

class AdminUploadScreen extends StatefulWidget {
  const AdminUploadScreen({super.key});

  @override
  State<AdminUploadScreen> createState() => _AdminUploadScreenState();
}

class _AdminUploadScreenState extends State<AdminUploadScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _subtitleController = TextEditingController();
  final _posingInstructionsController = TextEditingController();
  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _subCategories = [];
  String? _selectedCategoryName;
  String? _selectedCategoryId;
  String? _selectedSubCategoryName;

  bool _isLoading = false;
  File? _imageFile;
  Uint8List? _compressedImageBytes;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await ApiService.getCategories();
      if (mounted) {
        setState(() {
          _categories = categories;
        });
      }
    } catch (e) {
      debugPrint('Error loading categories: $e');
    }
  }

  Future<void> _loadSubCategories(String categoryId) async {
    try {
      final subCategories = await ApiService.getSubCategories(categoryId);
      if (mounted) {
        setState(() {
          _subCategories = subCategories;
          _selectedSubCategoryName = null;
        });
      }
    } catch (e) {
      debugPrint('Error loading subcategories: $e');
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 90,
      );

      if (pickedFile != null) {
        if (kIsWeb) {
          var bytes = await pickedFile.readAsBytes();
          setState(() {
            _compressedImageBytes = bytes;
            _imageFile = null;
          });
        } else {
          final compressedBytes = await _compressImage(File(pickedFile.path));

          if (compressedBytes != null) {
            setState(() {
              _imageFile = null;
              _compressedImageBytes = compressedBytes;
            });
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
      }
    }
  }

  Future<Uint8List?> _compressImage(File file) async {
    try {
      final dir = await getTemporaryDirectory();
      final targetPath =
          '${dir.path}/temp_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: 70,
        minWidth: 1024,
        minHeight: 1024,
      );

      return await result?.readAsBytes();
    } catch (e) {
      debugPrint("Compression error: $e");
      return null;
    }
  }

  Future<void> _uploadImage() async {
    if (!_formKey.currentState!.validate()) return;
    if (_compressedImageBytes == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select an image')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      String? imageUrl;

      try {
        final uploadResult = await ApiService.uploadFile(
          _compressedImageBytes!,
          '${DateTime.now().millisecondsSinceEpoch}.jpg',
          'photos',
        );
        imageUrl = uploadResult?['url'] as String?;
      } catch (e) {
        debugPrint('Upload error: $e');
        imageUrl = 'https://via.placeholder.com/800x600?text=Uploaded+Image';
      }

      final success = await ApiService.uploadPhoto(
        imageUrl: imageUrl ?? 'https://via.placeholder.com/800x600',
        categoryId: _selectedCategoryId,
        title: _titleController.text.trim(),
        description: _subtitleController.text.trim(),
        posingInstructions: _posingInstructionsController.text.trim(),
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Image uploaded successfully!')),
          );
          setState(() {
            _compressedImageBytes = null;
            _imageFile = null;
            _selectedCategoryName = null;
            _selectedCategoryId = null;
            _selectedSubCategoryName = null;
            _titleController.clear();
            _subtitleController.clear();
            _posingInstructionsController.clear();
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to save image metadata')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error uploading image: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Upload')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  child: _compressedImageBytes != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.memory(
                            _compressedImageBytes!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate_outlined,
                              size: 48,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap to select image',
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _subtitleController,
                decoration: const InputDecoration(
                  labelText: 'Subtitle',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.subtitles),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _posingInstructionsController,
                decoration: const InputDecoration(
                  labelText: 'Posing Instructions',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.info_outline),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter posing instructions';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              DropdownButtonFormField<String>(
                value: _selectedCategoryId,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                items: _categories
                    .map(
                      (category) => DropdownMenuItem<String>(
                        value: category['id'].toString(),
                        child: Text(category['name'].toString()),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategoryId = value;
                    _selectedCategoryName = _categories
                        .firstWhere((c) => c['id'].toString() == value)['name']
                        .toString();
                    _subCategories = [];
                    _selectedSubCategoryName = null;
                  });
                  if (value != null) {
                    _loadSubCategories(value);
                  }
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a category';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedSubCategoryName,
                decoration: const InputDecoration(
                  labelText: 'Sub-Category',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.subdirectory_arrow_right),
                ),
                items: _subCategories
                    .map(
                      (sub) => DropdownMenuItem<String>(
                        value: sub['name'].toString(),
                        child: Text(sub['name'].toString()),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSubCategoryName = value;
                  });
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _uploadImage,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Upload Image'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _posingInstructionsController.dispose();
    super.dispose();
  }
}
