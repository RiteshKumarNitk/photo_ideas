import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/app_assets_service.dart';

class AdminQuotesScreen extends StatefulWidget {
  const AdminQuotesScreen({super.key});

  @override
  State<AdminQuotesScreen> createState() => _AdminQuotesScreenState();
}

class _AdminQuotesScreenState extends State<AdminQuotesScreen> {
  List<Map<String, dynamic>> _quotes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQuotes();
  }

  Future<void> _loadQuotes() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final response = await Supabase.instance.client
          .from('quotes')
          .select()
          .order('created_at', ascending: false);
      
      if (mounted) {
        setState(() {
          _quotes = List<Map<String, dynamic>>.from(response);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading quotes: $e')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _addOrEditQuote({Map<String, dynamic>? quote}) async {
    final textController = TextEditingController(text: quote?['text'] ?? '');
    final authorController = TextEditingController(text: quote?['author'] ?? '');
    String selectedCategory = quote?['category'] ?? 'Love';
    final isEditing = quote != null;
    
    final categories = ['Love', 'Wedding', 'Sad', 'Motivational', 'Funny', 'Other'];

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(isEditing ? 'Edit Quote' : 'Add Quote'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: textController,
                decoration: const InputDecoration(labelText: 'Quote Text'),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: authorController,
                decoration: const InputDecoration(labelText: 'Author (Optional)'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: const InputDecoration(labelText: 'Category'),
                items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (value) {
                  if (value != null) setState(() => selectedCategory = value);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (textController.text.trim().isEmpty) return;
                
                try {
                  if (isEditing) {
                    await Supabase.instance.client.from('quotes').update({
                      'text': textController.text.trim(),
                      'author': authorController.text.trim(),
                      'category': selectedCategory,
                    }).eq('id', quote['id']);
                  } else {
                    await Supabase.instance.client.from('quotes').insert({
                      'text': textController.text.trim(),
                      'author': authorController.text.trim(),
                      'category': selectedCategory,
                      'created_at': DateTime.now().toIso8601String(),
                    });
                  }
                  if (context.mounted) Navigator.pop(context, true);
                } catch (e) {
                  // Error handling
                  debugPrint('Error saving quote: $e');
                }
              },
              child: Text(isEditing ? 'Save' : 'Add'),
            ),
          ],
        ),
      ),
    );

    if (result == true) {
      _loadQuotes();
    }
  }

  Future<void> _deleteQuote(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Quote'),
        content: const Text('Are you sure you want to delete this quote?'),
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
      await Supabase.instance.client.from('quotes').delete().eq('id', id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Quote deleted successfully')),
        );
        _loadQuotes();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting quote: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Manage Quotes', style: TextStyle(color: Colors.white)),
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
        onPressed: () => _addOrEditQuote(),
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
          _isLoading
              ? const Center(child: CircularProgressIndicator(color: Colors.white))
              : _quotes.isEmpty
                  ? const Center(child: Text('No quotes added yet', style: TextStyle(color: Colors.white)))
                  : MasonryGridView.count(
                      padding: const EdgeInsets.fromLTRB(16, 100, 16, 80), // Top padding for AppBar
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      itemCount: _quotes.length,
                      itemBuilder: (context, index) {
                        final quote = _quotes[index];
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
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '"${quote['text']}"',
                                      style: const TextStyle(
                                        fontStyle: FontStyle.italic,
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                      maxLines: 4,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      '- ${quote['author'] ?? 'Unknown'}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        '${quote['category'] ?? 'Uncategorized'}',
                                        style: const TextStyle(fontSize: 10, color: Colors.white70),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        InkWell(
                                          onTap: () => _addOrEditQuote(quote: quote),
                                          child: const Padding(
                                            padding: EdgeInsets.all(4.0),
                                            child: Icon(Icons.edit, color: Colors.blueAccent, size: 20),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        InkWell(
                                          onTap: () => _deleteQuote(quote['id']),
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
                            ),
                          ),
                        );
                      },
                    ),
        ],
      ),
    );
  }
}
