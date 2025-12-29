import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../utils/data_source.dart';
import '../../../core/models/photo_model.dart';
import '../../../core/services/supabase_service.dart';
import '../../categories/screens/category_grid_screen.dart';
import '../../categories/screens/sub_category_screen.dart';
import '../../quotes/screens/quotes_screen.dart';
import '../widgets/category_card.dart';
import '../../explore/screens/explore_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../images/screens/fullscreen_image_viewer.dart';
import '../../settings/screens/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeContent(),
    const ExploreScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Photos For", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      drawer: _buildDrawer(context),
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
          _screens[_selectedIndex],
        ],
      ),
      bottomNavigationBar: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: _onItemTapped,
            backgroundColor: Colors.black.withOpacity(0.3),
            indicatorColor: Colors.white.withOpacity(0.2),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined, color: Colors.white70),
                selectedIcon: Icon(Icons.home, color: Colors.white),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.explore_outlined, color: Colors.white70),
                selectedIcon: Icon(Icons.explore, color: Colors.white),
                label: 'Explore',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline, color: Colors.white70),
                selectedIcon: Icon(Icons.person, color: Colors.white),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.transparent, // Transparent for glassmorphism
      child: Stack(
        children: [
          // Blur for Drawer
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: Colors.black.withOpacity(0.7),
            ),
          ),
          ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                ),
                accountName: const Text(
                  "Photos For",
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                accountEmail: const Text(
                  "Explore & Share",
                  style: TextStyle(color: Colors.white70),
                ),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white.withOpacity(0.2),
                  child: const Icon(Icons.camera_alt, color: Colors.white),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.home_outlined, color: Colors.white),
                title: const Text('Home', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _selectedIndex = 0);
                },
              ),
              ExpansionTile(
                leading: const Icon(Icons.category_outlined, color: Colors.white),
                title: const Text('Categories', style: TextStyle(color: Colors.white)),
                iconColor: Colors.white,
                collapsedIconColor: Colors.white,
                children: [
                  _buildDrawerItem(context, "Haircut Ideas", Icons.content_cut, () {
                    Navigator.pop(context);
                    _navigateToCategory(context, "Haircut Ideas", DataSource.haircutImages, filters: DataSource.haircutFilters);
                  }),
                  _buildDrawerItem(context, "Wedding Photos", Icons.favorite_border, () {
                    Navigator.pop(context);
                    _navigateToCategory(context, "Wedding Photos", DataSource.weddingImages, filters: DataSource.weddingFilters);
                  }),
                  _buildDrawerItem(context, "Baby Photos", Icons.child_care, () {
                    Navigator.pop(context);
                    _navigateToCategory(context, "Baby Photos", DataSource.babyImages, filters: DataSource.babyFilters);
                  }),
                  _buildDrawerItem(context, "Nature", Icons.landscape, () {
                    Navigator.pop(context);
                    _navigateToCategory(context, "Nature", DataSource.natureImages, filters: DataSource.natureFilters);
                  }),
                  _buildDrawerItem(context, "Travel", Icons.flight, () {
                    Navigator.pop(context);
                    _navigateToCategory(context, "Travel", DataSource.travelImages, filters: DataSource.travelFilters);
                  }),
                  _buildDrawerItem(context, "Architecture", Icons.apartment, () {
                    Navigator.pop(context);
                    _navigateToCategory(context, "Architecture", DataSource.architectureImages, filters: DataSource.architectureFilters);
                  }),
                ],
              ),
              ListTile(
                leading: const Icon(Icons.format_quote_outlined, color: Colors.white),
                title: const Text('Quotes', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QuotesScreen(fallbackQuotes: DataSource.quotesList),
                    ),
                  );
                },
              ),
              const Divider(color: Colors.white24),
              ListTile(
                leading: const Icon(Icons.settings_outlined, color: Colors.white),
                title: const Text('Settings', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SettingsScreen()),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, size: 20, color: Colors.white70),
      title: Text(title, style: const TextStyle(fontSize: 14, color: Colors.white70)),
      onTap: onTap,
      contentPadding: const EdgeInsets.only(left: 32, right: 16),
    );
  }

  void _navigateToCategory(BuildContext context, String title, List<PhotoModel> images, {Map<String, List<PhotoModel>>? filters}) {
    if (filters != null && filters.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SubCategoryScreen(
            title: title,
            allImages: images,
            subCategories: filters,
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CategoryGridScreen(
            title: title,
            fallbackImages: images,
            filters: filters,
          ),
        ),
      );
    }
  }
}

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  List<PhotoModel> _trendingImages = [];
  List<Map<String, dynamic>> _allCategories = [];
  bool _isLoading = true;

  // Style configuration for known categories (used for icons and colors only)
  final Map<String, Map<String, dynamic>> _categoryStyles = {
    "haircut": {"icon": Icons.content_cut, "color": const Color(0xFF6C63FF)},
    "wedding": {"icon": Icons.favorite, "color": const Color(0xFFFF4081)},
    "baby": {"icon": Icons.child_care, "color": const Color(0xFFFF9100)},
    "nature": {"icon": Icons.landscape, "color": const Color(0xFF00E676)},
    "travel": {"icon": Icons.flight, "color": const Color(0xFF00B0FF)},
    "architecture": {"icon": Icons.apartment, "color": const Color(0xFF9E9E9E)},
    "quotes": {"icon": Icons.format_quote, "color": const Color(0xFFAA00FF)},
  };

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // Start with empty list to force DB fetch
    List<PhotoModel> images = [];
    List<Map<String, dynamic>> dbCategoriesList = [];

    try {
      // 1. Fetch Trending Images
      final response = await Supabase.instance.client
          .from('images')
          .select() 
          .order('created_at', ascending: false)
          .limit(20);
      
      final supabaseImages = (response as List)
          .map((item) => PhotoModel.fromJson(item))
          .toList();
      
      if (supabaseImages.isNotEmpty) {
        images.addAll(supabaseImages);
      }

      // 2. Fetch Categories ONLY from Supabase (as requested)
      final cats = await SupabaseService.getCategories();
      
      // Process database categories into UI models
      for (var cat in cats) {
        String name = cat['name'] as String;
        String lowerName = name.toLowerCase();
        
        // Default style
        IconData icon = Icons.category_outlined;
        Color color = Colors.primaries[name.hashCode % Colors.primaries.length].withOpacity(0.7);

        // Try to match with known styles
        _categoryStyles.forEach((key, style) {
           if (lowerName.contains(key)) {
             icon = style['icon'];
             color = style['color'];
           }
        });

        dbCategoriesList.add({
          "name": name,
          "icon": icon,
          "color": color,
        });
      }

      // 3. Always add Quotes category
      dbCategoriesList.add({
        "name": "Quotes",
        "icon": Icons.format_quote,
        "color": const Color(0xFFAA00FF),
      });

    } catch (e) {
      debugPrint('Error fetching data: $e');
    }

    if (mounted) {
      setState(() {
        _trendingImages = images;
        // Show DB categories + Quotes
        _allCategories = dbCategoriesList;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 100, 16, 16), 
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Discover",
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  "Find your next inspiration",
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 24),
                Text(
                  "Trending",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 16),
                // Snapchat Story Strip Style
                SizedBox(
                  height: 110,
                  child: _isLoading 
                      ? const Center(child: CircularProgressIndicator(color: Colors.white))
                      : _trendingImages.isEmpty 
                          ? const Center(child: Text("No trending images", style: TextStyle(color: Colors.white70)))
                          : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _trendingImages.length,
                    itemBuilder: (context, index) {
                      final photo = _trendingImages[index];
                      
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FullscreenImageViewer(photo: photo),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 16),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(3), 
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    colors: [Colors.purple, Colors.orange],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(2), 
                                  decoration: const BoxDecoration(
                                    color: Colors.black, 
                                    shape: BoxShape.circle,
                                  ),
                                  child: CircleAvatar(
                                    radius: 32,
                                    backgroundImage: NetworkImage(photo.url),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                width: 70,
                                child: Text(
                                  photo.category,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  "Categories",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          sliver: SliverMasonryGrid.count(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childCount: _allCategories.length,
            itemBuilder: (context, index) {
              final category = _allCategories[index];
              return _buildGlassCategoryCard(
                context,
                category['name'],
                category['icon'],
                category['color'],
                () {
                   if (category['name'] == 'Quotes') {
                      Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QuotesScreen(fallbackQuotes: const []),
                      ),
                    );
                   } else {
                     _navigateToCategory(context, category['name'], [], filters: {});
                   }
                },
              );
            },
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
      ],
    );
  }

  Widget _buildGlassCategoryCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
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
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 32, color: color),
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToCategory(BuildContext context, String title, List<PhotoModel> images, {Map<String, List<PhotoModel>>? filters}) {
    // Always navigate to SubCategoryScreen to check for dynamic subcategories
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SubCategoryScreen(
          title: title,
          allImages: images, // This might be empty, SubCategoryScreen will fetch if needed
          subCategories: filters ?? {}, // This might be empty, SubCategoryScreen will fetch
        ),
      ),
    );
  }
}
