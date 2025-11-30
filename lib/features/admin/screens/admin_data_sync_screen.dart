import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../utils/data_source.dart';
import '../../../core/models/photo_model.dart';

class AdminDataSyncScreen extends StatefulWidget {
  const AdminDataSyncScreen({super.key});

  @override
  State<AdminDataSyncScreen> createState() => _AdminDataSyncScreenState();
}

class _AdminDataSyncScreenState extends State<AdminDataSyncScreen> {
  bool _isSyncing = false;
  List<String> _logs = [];

  void _addLog(String message) {
    setState(() {
      _logs.add(message);
    });
  }

  Future<void> _syncData() async {
    setState(() {
      _isSyncing = true;
      _logs.clear();
    });

    _addLog("Starting sync process...");

    try {
      await _syncCategory('Haircut', DataSource.haircutFilters);
      await _syncCategory('Wedding', DataSource.weddingFilters);
      await _syncCategory('Baby', DataSource.babyFilters);
      await _syncCategory('Nature', DataSource.natureFilters);
      await _syncCategory('Travel', DataSource.travelFilters);
      await _syncCategory('Architecture', DataSource.architectureFilters);
      
      _addLog("Sync completed successfully!");
    } catch (e) {
      _addLog("Error during sync: $e");
    } finally {
      setState(() => _isSyncing = false);
    }
  }

  Future<void> _syncCategory(String category, Map<String, List<PhotoModel>> filters) async {
    _addLog("Syncing category: $category");
    final client = Supabase.instance.client;

    for (final entry in filters.entries) {
      final subCategory = entry.key;
      final images = entry.value;

      if (subCategory == 'All') continue; // Skip 'All' as it duplicates images

      for (final image in images) {
        // Check if exists
        final existing = await client
            .from('images')
            .select('id')
            .eq('url', image.url)
            .maybeSingle();

        if (existing == null) {
          await client.from('images').insert({
            'url': image.url,
            'category': category,
            'sub_category': subCategory,
            'posing_instructions': image.posingInstructions,
            'title': 'Imported $category Image',
            'created_at': DateTime.now().toIso8601String(),
          });
          _addLog("Imported image for $category - $subCategory");
        } else {
          // Optional: Update sub_category if missing?
          // For now, just skip
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sync Default Data'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              "This tool will import all hardcoded 'Idea' images (Haircut, Wedding, etc.) into the Supabase database. This allows you to manage them in the Admin Dashboard.",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _isSyncing ? null : _syncData,
              icon: _isSyncing 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) 
                  : const Icon(Icons.sync),
              label: Text(_isSyncing ? 'Syncing...' : 'Start Sync'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
            const SizedBox(height: 20),
            const Divider(),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Sync Logs:", style: TextStyle(fontWeight: FontWeight.bold)),
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
