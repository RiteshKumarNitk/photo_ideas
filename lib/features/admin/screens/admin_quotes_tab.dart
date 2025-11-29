import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminQuotesTab extends StatefulWidget {
  const AdminQuotesTab({super.key});

  @override
  State<AdminQuotesTab> createState() => _AdminQuotesTabState();
}

class _AdminQuotesTabState extends State<AdminQuotesTab> {
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
    final isEditing = quote != null;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
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
                  }).eq('id', quote['id']);
                } else {
                  await Supabase.instance.client.from('quotes').insert({
                    'text': textController.text.trim(),
                    'author': authorController.text.trim(),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEditQuote(),
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _quotes.isEmpty
              ? const Center(child: Text('No quotes added yet'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _quotes.length,
                  itemBuilder: (context, index) {
                    final quote = _quotes[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ListTile(
                        title: Text(
                          '"${quote['text']}"',
                          style: const TextStyle(fontStyle: FontStyle.italic),
                        ),
                        subtitle: Text(
                          '- ${quote['author'] ?? 'Unknown'}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _addOrEditQuote(quote: quote),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteQuote(quote['id']),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
