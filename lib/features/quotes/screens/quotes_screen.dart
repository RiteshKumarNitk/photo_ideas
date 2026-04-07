import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/services/api_service.dart';
import '../../../utils/data_source.dart';
import '../../auth/screens/login_screen.dart';

class QuotesScreen extends StatefulWidget {
  final List<String> fallbackQuotes;

  const QuotesScreen({super.key, required this.fallbackQuotes});

  @override
  State<QuotesScreen> createState() => _QuotesScreenState();
}

class _QuotesScreenState extends State<QuotesScreen> {
  List<Map<String, dynamic>> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final quotes = await ApiService.getQuotes();

      // Group quotes by category
      final Map<String, int> categoryCounts = {};
      for (var quote in quotes) {
        final cat = quote['category'] as String? ?? 'General';
        categoryCounts[cat] = (categoryCounts[cat] ?? 0) + 1;
      }

      // If no categories from API, use fallback categories
      if (categoryCounts.isEmpty) {
        categoryCounts.addAll({
          'Love': 10,
          'Wedding': 8,
          'Sad': 6,
          'Motivational': 12,
          'Funny': 8,
        });
      }

      final cats = categoryCounts.entries
          .map((e) => {'name': e.key, 'count': e.value})
          .toList();

      if (mounted) {
        setState(() {
          _categories = cats;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading quote categories: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final staticCategories = DataSource.quoteCategories.keys.toList();
    final displayCategories = _isLoading
        ? staticCategories
        : _categories.map((c) => c['name'] as String).toList();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          "Quote Categories",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
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
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(color: Colors.black.withOpacity(0.4)),
          ),
          _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                )
              : Padding(
                  padding: const EdgeInsets.fromLTRB(16, 100, 16, 16),
                  child: MasonryGridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    itemCount: displayCategories.length,
                    itemBuilder: (context, index) {
                      final category = displayCategories[index];
                      int count = 0;
                      if (!_isLoading && _categories.isNotEmpty) {
                        final catData = _categories.firstWhere(
                          (c) => c['name'] == category,
                          orElse: () => {'count': 0},
                        );
                        count = catData['count'] as int? ?? 0;
                      }
                      if (count == 0) {
                        count =
                            DataSource.quoteCategories[category]?.length ?? 0;
                      }

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
                                fallbackQuotes:
                                    DataSource.quoteCategories[category] ?? [],
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$count quotes',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.white70),
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
      case 'Love':
        return Icons.favorite;
      case 'Wedding':
        return Icons.favorite_border;
      case 'Sad':
        return Icons.sentiment_dissatisfied;
      case 'Motivational':
        return Icons.lightbulb_outline;
      case 'Funny':
        return Icons.sentiment_very_satisfied;
      default:
        return Icons.format_quote;
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
      final quotes = await ApiService.getQuotesByCategory(widget.category);

      if (mounted) {
        setState(() {
          if (quotes.isNotEmpty) {
            _quotes = quotes;
          } else {
            _quotes = widget.fallbackQuotes
                .map((q) => {'content': q, 'author': 'Unknown', 'id': '-1'})
                .toList();
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading quotes: $e');
      if (mounted) {
        setState(() {
          _quotes = widget.fallbackQuotes
              .map((q) => {'content': q, 'author': 'Unknown', 'id': '-1'})
              .toList();
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
        title: Text(
          widget.category,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
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
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(color: Colors.black.withOpacity(0.4)),
          ),
          _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                )
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
    final id = widget.quote['id'].toString();
    final status = await ApiService.getQuoteLikeStatus(id);
    if (mounted) {
      setState(() {
        _isLiked = status['liked'] ?? false;
        _likeCount = status['count'] ?? 0;
      });
    }
  }

  Future<void> _toggleLike() async {
    if (widget.quote['id'] == -1) return;
    if (_isLikeLoading) return;

    if (!ApiService.isAuthenticated) {
      _showLoginPrompt();
      return;
    }

    setState(() => _isLikeLoading = true);
    try {
      final id = widget.quote['id'].toString();
      final newStatus = await ApiService.toggleQuoteLike(id);
      final newCount = await ApiService.getQuoteLikeStatus(id);
      if (mounted) {
        setState(() {
          _isLiked = newStatus;
          _likeCount = newCount['count'] ?? _likeCount;
        });
      }
    } catch (e) {
    } finally {
      if (mounted) setState(() => _isLikeLoading = false);
    }
  }

  void _showLoginPrompt() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Sign In Required',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'You need to sign in to like quotes and save them to your favorites.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
            child: const Text('Sign In', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
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
                widget.quote['content'] ?? widget.quote['text'] ?? '',
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
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.white70),
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
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: Colors.white70),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.copy,
                          size: 20,
                          color: Colors.white70,
                        ),
                        onPressed: () {
                          Clipboard.setData(
                            ClipboardData(
                              text:
                                  '"${widget.quote['text']}" - ${widget.quote['author']}',
                            ),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Quote copied to clipboard'),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.share,
                          size: 20,
                          color: Colors.white70,
                        ),
                        onPressed: () {
                          Share.share(
                            '"${widget.quote['text']}" - ${widget.quote['author']}',
                          );
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
