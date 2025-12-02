import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _selectedGender;
  bool _isLoading = false;
  
  File? _imageFile;
  Uint8List? _webImage;
  String? _currentAvatarUrl;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      _nameController.text = user.userMetadata?['full_name'] ?? '';
      _phoneController.text = user.userMetadata?['phone_number'] ?? '';
      _selectedGender = user.userMetadata?['gender'];
      _currentAvatarUrl = user.userMetadata?['avatar_url'];
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 600,
        maxHeight: 600,
        imageQuality: 80,
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

  Future<String?> _uploadImage(String userId) async {
    if (_imageFile == null && _webImage == null) return null;

    final fileName = '$userId/${DateTime.now().millisecondsSinceEpoch}.jpg';
    try {
      if (kIsWeb) {
        await Supabase.instance.client.storage.from('profiles').uploadBinary(
              fileName,
              _webImage!,
              fileOptions: const FileOptions(upsert: true),
            );
      } else {
        await Supabase.instance.client.storage.from('profiles').upload(
              fileName,
              _imageFile!,
              fileOptions: const FileOptions(upsert: true),
            );
      }
      
      final imageUrl = Supabase.instance.client.storage
          .from('profiles')
          .getPublicUrl(fileName);
      
      return imageUrl;
    } catch (e) {
      debugPrint('Error uploading image: $e');
      return null;
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception('No user logged in');

      String? avatarUrl = _currentAvatarUrl;
      if (_imageFile != null || _webImage != null) {
        final uploadedUrl = await _uploadImage(user.id);
        if (uploadedUrl != null) {
          avatarUrl = uploadedUrl;
        } else {
          throw Exception('Failed to upload image. Please try again.');
        }
      }

      await Supabase.instance.client.auth.updateUser(
        UserAttributes(
          data: {
            'full_name': _nameController.text.trim(),
            'phone_number': _phoneController.text.trim(),
            'gender': _selectedGender,
            'avatar_url': avatarUrl,
          },
        ),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Edit Profile', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(
                  'https://images.unsplash.com/photo-1492691527719-9d1e07e534b4?auto=format&fit=crop&w=1000&q=80',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Blur Effect
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              color: Colors.black.withOpacity(0.4),
            ),
          ),
          // Content
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 100, 16, 16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
                          ),
                          child: CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.white.withOpacity(0.2),
                            backgroundImage: _webImage != null
                                ? MemoryImage(_webImage!)
                                : _imageFile != null
                                    ? FileImage(_imageFile!) as ImageProvider
                                    : (_currentAvatarUrl != null && _currentAvatarUrl!.isNotEmpty)
                                        ? NetworkImage(_currentAvatarUrl!)
                                        : null,
                            child: (_webImage == null && _imageFile == null && (_currentAvatarUrl == null || _currentAvatarUrl!.isEmpty))
                                ? const Icon(
                                    Icons.person,
                                    size: 60,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Colors.blueAccent,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildGlassTextField(
                    controller: _nameController,
                    label: 'Full Name',
                    icon: Icons.person,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildGlassTextField(
                    controller: _phoneController,
                    label: 'Phone Number',
                    icon: Icons.phone,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  _buildGlassDropdown(),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _updateProfile,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.white.withOpacity(0.2),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.white.withOpacity(0.3)),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Save Changes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
            prefixIcon: Icon(icon, color: Colors.white70),
            filled: true,
            fillColor: Colors.white.withOpacity(0.1),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          validator: validator,
        ),
      ),
    );
  }

  Widget _buildGlassDropdown() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: DropdownButtonFormField<String>(
          value: _selectedGender,
          dropdownColor: Colors.grey[900], // Solid color for dropdown menu to be readable
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Gender',
            labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
            prefixIcon: const Icon(Icons.people, color: Colors.white70),
            filled: true,
            fillColor: Colors.white.withOpacity(0.1),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          items: ['Male', 'Female', 'Other']
              .map((label) => DropdownMenuItem(
                    value: label,
                    child: Text(label),
                  ))
              .toList(),
          onChanged: (value) {
            setState(() {
              _selectedGender = value;
            });
          },
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}
