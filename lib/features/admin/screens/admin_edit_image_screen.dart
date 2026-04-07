import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';

class AdminEditImageScreen extends StatefulWidget {
  final Map<String, dynamic> imageData;

  const AdminEditImageScreen({super.key, required this.imageData});

  @override
  State<AdminEditImageScreen> createState() => _AdminEditImageScreenState();
}

class _AdminEditImageScreenState extends State<AdminEditImageScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _subtitleController;
  late TextEditingController _posingInstructionsController;
  String? _selectedCategory;
  String? _selectedSubCategory;
  bool _isLoading = false;

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

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.imageData['title']?.toString() ?? '',
    );
    _subtitleController = TextEditingController(
      text: widget.imageData['subtitle']?.toString() ?? '',
    );
    _posingInstructionsController = TextEditingController(
      text: widget.imageData['posing_instructions']?.toString() ?? '',
    );
    _selectedCategory = widget.imageData['category']?.toString();
    _selectedSubCategory = widget.imageData['sub_category']?.toString();

    if (_selectedCategory != null && !_categories.contains(_selectedCategory)) {
      _categories.add(_selectedCategory!);
    }
  }

  Future<void> _updateImage() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final id = widget.imageData['id'];
      if (id == null) {
        throw Exception('Image ID not found');
      }

      final success = await ApiService.updatePhoto(
        id: id.toString(),
        title: _titleController.text.trim(),
        description: _subtitleController.text.trim(),
        posingInstructions: _posingInstructionsController.text.trim(),
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Image updated successfully!')),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to update image')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error updating image: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Image Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  widget.imageData['url']?.toString() ?? '',
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: const Center(child: Icon(Icons.error)),
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
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                items: _categories
                    .map(
                      (category) => DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                    _selectedSubCategory = null;
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
              if (_selectedCategory != null &&
                  _subCategories.containsKey(_selectedCategory))
                DropdownButtonFormField<String>(
                  value: _selectedSubCategory,
                  decoration: const InputDecoration(
                    labelText: 'Sub-Category',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.subdirectory_arrow_right),
                  ),
                  items: _subCategories[_selectedCategory]!
                      .map(
                        (sub) => DropdownMenuItem(value: sub, child: Text(sub)),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedSubCategory = value;
                    });
                  },
                ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updateImage,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save Changes'),
                ),
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
