import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  String? _selectedCategory;
  String? _selectedSubCategory;
  bool _isLoading = false;
  File? _imageFile;
  Uint8List? _webImage;
  final ImagePicker _picker = ImagePicker();

  final List<String> _categories = [
    'Haircut Ideas',
    'Wedding Photos',
    'Baby Photos',
    'Nature',
    'Travel',
    'Architecture',
  ];

  final Map<String, List<String>> _subCategories = {
    'Haircut Ideas': ['Men', 'Women', 'Short', 'Long'],
    'Wedding Photos': ['Couple', 'Bride', 'Groom', 'Decor'],
    'Baby Photos': ['Newborn', 'Family', 'Outdoor'],
    'Nature': ['Landscape', 'Forest', 'Beach'],
    'Travel': ['City', 'Adventure', 'Beach'],
    'Architecture': ['Modern', 'Historic'],
  };

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        if (kIsWeb) {
          final bytes = await pickedFile.readAsBytes();
          setState(() {
            _webImage = bytes;
            _imageFile = null;
          });
        } else {
          setState(() {
            _imageFile = File(pickedFile.path);
            _webImage = null;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  Future<void> _uploadImage() async {
    if (!_formKey.currentState!.validate()) return;
    if (_imageFile == null && _webImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final path = 'uploads/$fileName';

      // 1. Upload to Storage
      if (kIsWeb) {
        await Supabase.instance.client.storage.from('images').uploadBinary(
              path,
              _webImage!,
              fileOptions: const FileOptions(upsert: true),
            );
      } else {
        await Supabase.instance.client.storage.from('images').upload(
              path,
              _imageFile!,
              fileOptions: const FileOptions(upsert: true),
            );
      }

      final imageUrl = Supabase.instance.client.storage
          .from('images')
          .getPublicUrl(path);

      // 2. Insert into Database
      await Supabase.instance.client.from('images').insert({
        'url': imageUrl,
        'category': _selectedCategory,
        'sub_category': _selectedSubCategory,
        'title': _titleController.text.trim(),
        'subtitle': _subtitleController.text.trim(),
        'posing_instructions': _posingInstructionsController.text.trim(),
        'created_at': DateTime.now().toIso8601String(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image uploaded successfully!')),
        );
        setState(() {
          _imageFile = null;
          _webImage = null;
          _imageFile = null;
          _webImage = null;
          _selectedCategory = null;
          _selectedSubCategory = null;
          _titleController.clear();
          _subtitleController.clear();
          _posingInstructionsController.clear();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading image: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Upload'),
      ),
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
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  child: _webImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.memory(_webImage!, fit: BoxFit.cover),
                        )
                      : _imageFile != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(_imageFile!, fit: BoxFit.cover),
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
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                items: _categories
                    .map((category) => DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                    _selectedSubCategory = null; // Reset sub-category
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a category';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              if (_selectedCategory != null && _subCategories.containsKey(_selectedCategory))
                DropdownButtonFormField<String>(
                  value: _selectedSubCategory,
                  decoration: const InputDecoration(
                    labelText: 'Sub-Category',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.subdirectory_arrow_right),
                  ),
                  items: _subCategories[_selectedCategory]!
                      .map((sub) => DropdownMenuItem(
                            value: sub,
                            child: Text(sub),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedSubCategory = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a sub-category';
                    }
                    return null;
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
