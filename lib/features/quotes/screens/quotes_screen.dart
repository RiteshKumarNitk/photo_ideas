import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/services/supabase_service.dart';
import '../../../utils/data_source.dart';

class QuotesScreen extends StatelessWidget {
  final List<String> fallbackQuotes; // Kept for backward compatibility if needed, but we'll use DataSource.quoteCategories

  const QuotesScreen({super.key, required this.fallbackQuotes});

  @override
  Widget build(BuildContext context) {
    final categories = DataSource.quoteCategories.keys.toList();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Quote Categories", style: TextStyle(color: Colors.white)),
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
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 100, 16, 16),
            child: MasonryGridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final count = DataSource.quoteCategories[category]?.length ?? 0;
                
                return _buildGlassCategoryGridItem(
                  context, 
                  title: category, 
                  count: count,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QuoteListScreen(
                          category: category,
                          fallbackQuotes: DataSource.quoteCategories[category] ?? [],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassCategoryGridItem(
    BuildContext context, {
    required String title,
    required int count,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _getCategoryIcon(title),
                  color: Colors.white,
                  size: 32,
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  "Explore",
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String title) {
    switch (title) {
      case 'Love': return Icons.favorite;
      case 'Wedding': return Icons.favorite_border; // Or a ring icon if available
      case 'Sad': return Icons.sentiment_dissatisfied;
      case 'Motivational': return Icons.lightbulb_outline;
      case 'Funny': return Icons.sentiment_very_satisfied;
      default: return Icons.format_quote;
    }
  }
}

class QuoteListScreen extends StatefulWidget {
  final String category;
  final List<String> fallbackQuotes;

  const QuoteListScreen({
    super.key, 
    required this.category,
    required this.fallbackQuotes,
  });

  @override
  State<QuoteListScreen> createState() => _QuoteListScreenState();
}

class _QuoteListScreenState extends State<QuoteListScreen> {
  List<Map<String, dynamic>> _quotes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQuotes();
  }

  Future<void> _loadQuotes() async {
    setState(() => _isLoading = true);
    
    try {
      // Fetch from Supabase with filter
      final quotes = await SupabaseService.getQuotesByCategory(widget.category);

      if (mounted) {
        setState(() {
          if (quotes.isNotEmpty) {
            _quotes = quotes;
          } else {
            // Fallback
            _quotes = widget.fallbackQuotes.map((q) => {'text': q, 'author': 'Unknown', 'id': -1}).toList();
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading quotes: $e');
      if (mounted) {
        setState(() {
          // Fallback on error
          _quotes = widget.fallbackQuotes.map((q) => {'text': q, 'author': 'Unknown', 'id': -1}).toList();
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
        title: Text(widget.category, style: const TextStyle(color: Colors.white)),
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
          _isLoading 
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : Padding(
                padding: const EdgeInsets.fromLTRB(16, 100, 16, 16),
                child: MasonryGridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  itemCount: _quotes.length,
                  itemBuilder: (context, index) {
                    return QuoteCard(
                      quote: _quotes[index],
                      category: widget.category,
                    );
                  },
                ),
              ),
        ],
      ),
    );
  }
}

class QuoteCard extends StatefulWidget {
  final Map<String, dynamic> quote;
  final String category;

  const QuoteCard({super.key, required this.quote, this.category = 'Love'});

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
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.quote['text']!,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  "- ${widget.quote['author']}",
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white70,
                  ),
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
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.copy, size: 20, color: Colors.white70),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: '"${widget.quote['text']}" - ${widget.quote['author']}'));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Quote copied to clipboard')),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.share, size: 20, color: Colors.white70),
                        onPressed: () {
                          Share.share('"${widget.quote['text']}" - ${widget.quote['author']}');
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
