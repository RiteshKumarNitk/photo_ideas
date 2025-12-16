import 'package:flutter/material.dart';
import '../../../core/services/supabase_service.dart';

class AdminCategoryScreen extends StatefulWidget {
  const AdminCategoryScreen({super.key});

  @override
  State<AdminCategoryScreen> createState() => _AdminCategoryScreenState();
}

class _AdminCategoryScreenState extends State<AdminCategoryScreen> {
  List<Map<String, dynamic>> _categories = [];
  bool _isLoading = true;
  final TextEditingController _categoryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoading = true);
    final categories = await SupabaseService.getCategories();
    setState(() {
      _categories = categories;
      _isLoading = false;
    });
  }

  Future<void> _addCategory() async {
    if (_categoryController.text.trim().isEmpty) return;
    try {
      await SupabaseService.addCategory(_categoryController.text.trim());
      _categoryController.clear();
      _loadCategories();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Category added successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding category: $e')),
        );
      }
    }
  }

  Future<void> _deleteCategory(int id) async {
     try {
      await SupabaseService.deleteCategory(id);
      _loadCategories();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Error deleting category: $e')),
        );
      }
    }
  }

  void _showAddCategoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Category'),
        content: TextField(
          controller: _categoryController,
          decoration: const InputDecoration(hintText: 'Category Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _addCategory();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Categories'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCategoryDialog,
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                return CategoryTile(
                  category: category,
                  onDelete: () => _deleteCategory(category['id']),
                );
              },
            ),
    );
  }
}

class CategoryTile extends StatefulWidget {
  final Map<String, dynamic> category;
  final VoidCallback onDelete;

  const CategoryTile({
    super.key,
    required this.category,
    required this.onDelete,
  });

  @override
  State<CategoryTile> createState() => _CategoryTileState();
}

class _CategoryTileState extends State<CategoryTile> {
  List<Map<String, dynamic>> _subCategories = [];
  bool _isLoadingSub = false;
  bool _isExpanded = false;
  final TextEditingController _subCategoryController = TextEditingController();

  Future<void> _loadSubCategories() async {
    setState(() => _isLoadingSub = true);
    final subCategories = await SupabaseService.getSubCategories(widget.category['id']);
    if (mounted) {
      setState(() {
        _subCategories = subCategories;
        _isLoadingSub = false;
      });
    }
  }

  Future<void> _addSubCategory() async {
    if (_subCategoryController.text.trim().isEmpty) return;
    try {
      await SupabaseService.addSubCategory(widget.category['id'], _subCategoryController.text.trim());
      _subCategoryController.clear();
      _loadSubCategories();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding subcategory: $e')),
        );
      }
    }
  }

  Future<void> _deleteSubCategory(int id) async {
    try {
      await SupabaseService.deleteSubCategory(id);
      _loadSubCategories();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting subcategory: $e')),
        );
      }
    }
  }

  void _showAddSubCategoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Subcategory to ${widget.category['name']}'),
        content: TextField(
          controller: _subCategoryController,
          decoration: const InputDecoration(hintText: 'Subcategory Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _addSubCategory();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _subCategoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(widget.category['name']),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.add, size: 20),
            onPressed: _showAddSubCategoryDialog,
            tooltip: 'Add Subcategory',
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: widget.onDelete,
          ),
        ],
      ),
      onExpansionChanged: (expanded) {
        setState(() => _isExpanded = expanded);
        if (expanded && _subCategories.isEmpty) {
          _loadSubCategories();
        }
      },
      children: [
        if (_isLoadingSub)
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_subCategories.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('No subcategories yet.'),
          )
        else
          ..._subCategories.map((sub) => ListTile(
                title: Text(sub['name']),
                contentPadding: const EdgeInsets.only(left: 32, right: 16),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, size: 20, color: Colors.redAccent),
                  onPressed: () => _deleteSubCategory(sub['id']),
                ),
              )),
      ],
    );
  }
}
