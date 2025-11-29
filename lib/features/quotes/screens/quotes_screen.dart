import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/services/supabase_service.dart';

class QuotesScreen extends StatefulWidget {
  final List<String> fallbackQuotes;

  const QuotesScreen({super.key, required this.fallbackQuotes});

  @override
  State<QuotesScreen> createState() => _QuotesScreenState();
}

class _QuotesScreenState extends State<QuotesScreen> {
  List<Map<String, dynamic>> _quotes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQuotes();
  }

  Future<void> _loadQuotes() async {
    setState(() => _isLoading = true);
    
    // Fetch from Supabase
    final quotes = await SupabaseService.getQuotes();

    if (mounted) {
      setState(() {
        if (quotes.isNotEmpty) {
          _quotes = quotes;
        } else {
          // Fallback - no IDs for fallback quotes, so likes won't work for them
          _quotes = widget.fallbackQuotes.map((q) => {'text': q, 'author': 'Unknown', 'id': -1}).toList();
        }
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Quotes")),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.all(8.0),
            child: MasonryGridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              itemCount: _quotes.length,
              itemBuilder: (context, index) {
                return QuoteCard(quote: _quotes[index]);
              },
            ),
          ),
    );
  }
}

class QuoteCard extends StatefulWidget {
  final Map<String, dynamic> quote;

  const QuoteCard({super.key, required this.quote});

  @override
  State<QuoteCard> createState() => _QuoteCardState();
}

class _QuoteCardState extends State<QuoteCard> {
  bool _isLiked = false;
  int _likeCount = 0;
  bool _isLikeLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.quote['id'] != -1) {
      _fetchLikeStatus();
    }
  }

  Future<void> _fetchLikeStatus() async {
    final id = widget.quote['id'] as int;
    final isLiked = await SupabaseService.isQuoteLiked(id);
    final count = await SupabaseService.getQuoteLikeCount(id);
    if (mounted) {
      setState(() {
        _isLiked = isLiked;
        _likeCount = count;
      });
    }
  }

  Future<void> _toggleLike() async {
    if (widget.quote['id'] == -1) return; // Can't like fallback quotes
    if (_isLikeLoading) return;

    setState(() => _isLikeLoading = true);
    try {
      final id = widget.quote['id'] as int;
      final newStatus = await SupabaseService.toggleQuoteLike(id);
      final newCount = await SupabaseService.getQuoteLikeCount(id);
      if (mounted) {
        setState(() {
          _isLiked = newStatus;
          _likeCount = newCount;
        });
      }
    } catch (e) {
      // Handle error
    } finally {
      if (mounted) setState(() => _isLikeLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.primaries[widget.quote['text'].length % Colors.primaries.length].withOpacity(0.2),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.quote['text']!,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                "- ${widget.quote['author']}",
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: _toggleLike,
                      child: Icon(
                        _isLiked ? Icons.favorite : Icons.favorite_border,
                        size: 20,
                        color: _isLiked ? Colors.red : Colors.white70,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$_likeCount',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.share, size: 20),
                  onPressed: () {
                    Share.share('"${widget.quote['text']}" - ${widget.quote['author']}');
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
