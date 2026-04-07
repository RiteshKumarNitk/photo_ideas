import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/services/api_service.dart';
import '../../images/models/face_filter_model.dart';

class AdminFilterUploadScreen extends StatefulWidget {
  const AdminFilterUploadScreen({super.key});

  @override
  State<AdminFilterUploadScreen> createState() =>
      _AdminFilterUploadScreenState();
}

class _AdminFilterUploadScreenState extends State<AdminFilterUploadScreen> {
  final _formKey = GlobalKey<FormState>();
  File? _imageFile;
  bool _isUploading = false;

  final _nameController = TextEditingController();
  final _scaleController = TextEditingController(text: "1.0");
  final _offsetXController = TextEditingController(text: "0.0");
  final _offsetYController = TextEditingController(text: "0.0");

  FaceLandmarkAnchor _selectedAnchor = FaceLandmarkAnchor.forehead;
  String _selectedType = 'asset';

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadFilter() async {
    if (!_formKey.currentState!.validate() || _imageFile == null) {
      if (_imageFile == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Please select an image')));
      }
      return;
    }

    setState(() => _isUploading = true);

    try {
      String? imageUrl;
      try {
        final bytes = await _imageFile!.readAsBytes();
        final result = await ApiService.uploadFile(
          bytes,
          '${DateTime.now().millisecondsSinceEpoch}.png',
          'filters',
        );
        imageUrl = result?['url'] as String?;
      } catch (e) {
        debugPrint('Upload error: $e');
        imageUrl = 'https://via.placeholder.com/200x200?text=Filter';
      }

      await ApiService.addFaceFilter(
        name: _nameController.text,
        imageUrl: imageUrl,
        thumbnailUrl: imageUrl,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Filter uploaded successfully!')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Upload Face Filter',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey),
                    image: _imageFile != null
                        ? DecorationImage(
                            image: FileImage(_imageFile!),
                            fit: BoxFit.contain,
                          )
                        : null,
                  ),
                  child: _imageFile == null
                      ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_a_photo,
                              size: 50,
                              color: Colors.white,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Tap to select PNG image',
                              style: TextStyle(color: Colors.white),
                            ),
                            Text(
                              '(Transparent background recommended)',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('Filter Name'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<FaceLandmarkAnchor>(
                value: _selectedAnchor,
                dropdownColor: Colors.grey[900],
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('Anchor Point'),
                items: FaceLandmarkAnchor.values.map((anchor) {
                  return DropdownMenuItem(
                    value: anchor,
                    child: Text(
                      anchor.toString().split('.').last.toUpperCase(),
                    ),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedAnchor = val!),
              ),
              const SizedBox(height: 8),
              Text(
                _getAnchorDescription(_selectedAnchor),
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _scaleController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('Scale (e.g. 1.0, 2.5)'),
                validator: (value) =>
                    double.tryParse(value!) == null ? 'Invalid number' : null,
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _offsetXController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration('Offset X'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _offsetYController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration('Offset Y'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isUploading ? null : _uploadFilter,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isUploading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Upload Filter',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.white24),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.blueAccent),
        borderRadius: BorderRadius.circular(12),
      ),
      filled: true,
      fillColor: Colors.white.withOpacity(0.05),
    );
  }

  String _getAnchorDescription(FaceLandmarkAnchor anchor) {
    switch (anchor) {
      case FaceLandmarkAnchor.forehead:
        return 'Best for: Hats, Crowns, Animal Ears. Positioned above eyes.';
      case FaceLandmarkAnchor.eyes:
        return 'Best for: Glasses, Eye Masks. Positioned between eyes.';
      case FaceLandmarkAnchor.nose:
        return 'Best for: Mustaches, Animal Noses, Clowns. Positioned on nose base.';
      case FaceLandmarkAnchor.face:
        return 'Best for: Full Face Masks. Centered on the face bounding box.';
    }
  }
}
