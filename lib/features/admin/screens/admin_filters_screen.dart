
import 'package:flutter/material.dart';
import '../../../core/services/supabase_service.dart';
import '../../images/models/face_filter_model.dart';
import 'admin_filter_upload_screen.dart';

class AdminFiltersScreen extends StatefulWidget {
  const AdminFiltersScreen({super.key});

  @override
  State<AdminFiltersScreen> createState() => _AdminFiltersScreenState();
}

class _AdminFiltersScreenState extends State<AdminFiltersScreen> {
  List<FaceFilter> _filters = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFilters();
  }

  Future<void> _loadFilters() async {
    setState(() => _isLoading = true);
    try {
      final data = await SupabaseService.getFaceFilters();
      if (mounted) {
        setState(() {
          _filters = data.map((json) => FaceFilter.fromJson(json)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading filters: $e')),
        );
      }
    }
  }

  Future<void> _deleteFilter(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Filter'),
        content: const Text('Are you sure? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
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
      await SupabaseService.deleteFaceFilter(id);
      _loadFilters(); // Refresh
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Filter deleted')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Dark theme
      appBar: AppBar(
        title: const Text('Manage Face Filters', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AdminFilterUploadScreen()),
          );
          if (result == true) {
            _loadFilters();
          }
        },
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _filters.isEmpty
              ? const Center(child: Text('No filters found. Add one!', style: TextStyle(color: Colors.white)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _filters.length,
                  itemBuilder: (context, index) {
                    final filter = _filters[index];
                    return Card(
                      color: Colors.grey[900],
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: Container(
                          width: 50, height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white10,
                            borderRadius: BorderRadius.circular(8),
                            image: filter.iconUrl.isNotEmpty
                                ? DecorationImage(image: NetworkImage(filter.iconUrl), fit: BoxFit.cover)
                                : null,
                          ),
                          child: filter.iconUrl.isEmpty ? const Icon(Icons.face, color: Colors.white) : null,
                        ),
                        title: Text(filter.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        subtitle: Text(
                          '${filter.anchor.toString().split('.').last} • Scale: ${filter.scale}', 
                          style: const TextStyle(color: Colors.grey),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () => _deleteFilter(filter.id),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
