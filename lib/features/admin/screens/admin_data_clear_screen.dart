import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../utils/data_source.dart';
import '../../../core/models/photo_model.dart';

class AdminDataClearScreen extends StatefulWidget {
  const AdminDataClearScreen({super.key});

  @override
  State<AdminDataClearScreen> createState() => _AdminDataClearScreenState();
}

class _AdminDataClearScreenState extends State<AdminDataClearScreen> {
  bool _isClearing = false;
  List<String> _logs = [];

  void _addLog(String message) {
    setState(() {
      _logs.add(message);
    });
  }

  Future<void> _clearData() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Default Data'),
        content: const Text(
          'This will remove all images from the database that match the hardcoded "Idea" images. '
          'This action cannot be undone (unless you Sync again). Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear Data'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isClearing = true;
      _logs.clear();
    });

    _addLog("Starting clear process...");

    try {
      await _clearCategory('Haircut', DataSource.haircutFilters);
      await _clearCategory('Wedding', DataSource.weddingFilters);
      await _clearCategory('Baby', DataSource.babyFilters);
      await _clearCategory('Nature', DataSource.natureFilters);
      await _clearCategory('Travel', DataSource.travelFilters);
      await _clearCategory('Architecture', DataSource.architectureFilters);
      
      _addLog("Clear process completed successfully!");
    } catch (e) {
      _addLog("Error during clear: $e");
    } finally {
      setState(() => _isClearing = false);
    }
  }

  Future<void> _clearCategory(String category, Map<String, List<PhotoModel>> filters) async {
    _addLog("Checking category: $category");
    final client = Supabase.instance.client;
    int deletedCount = 0;

    for (final entry in filters.entries) {
      final images = entry.value;
      // We process 'All' as well to ensure we catch everything, 
      // but since we delete by URL, duplicates in the list don't matter much 
      // (delete will just succeed or find nothing).
      
      for (final image in images) {
        try {
          await client
              .from('images')
              .delete()
              .eq('url', image.url);
          // We don't increment count per image here because delete doesn't return count easily without select
          // and we might be deleting the same URL multiple times if it appears in multiple filters.
        } catch (e) {
          // Ignore errors if not found
        }
      }
    }
    _addLog("Removed images for $category");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clear Default Data'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              "This tool will remove the hardcoded 'Idea' images from your Supabase database. Use this if you want to undo a Sync or clean up the database.",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _isClearing ? null : _clearData,
              icon: _isClearing 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) 
                  : const Icon(Icons.delete_forever),
              label: Text(_isClearing ? 'Clearing...' : 'Clear Default Data'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            const Divider(),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Logs:", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[400]!),
                ),
                child: ListView.builder(
                  itemCount: _logs.length,
                  itemBuilder: (context, index) => Text(
                    _logs[index],
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 12, color: Colors.black),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
