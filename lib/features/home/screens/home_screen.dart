import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../../utils/data_source.dart';
import '../../categories/screens/category_grid_screen.dart';
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
      appBar: AppBar(
        title: const Text("Photo Ideas"),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        indicatorColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Explore',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            ),
            accountName: Text(
              "Photo Ideas",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            accountEmail: Text(
              "Explore & Share",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: const Icon(Icons.camera_alt, color: Colors.white),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context);
              setState(() => _selectedIndex = 0);
            },
          ),
          ExpansionTile(
            leading: const Icon(Icons.category_outlined),
            title: const Text('Categories'),
            children: [
              _buildDrawerItem(context, "Haircut Ideas", Icons.content_cut, () {
                Navigator.pop(context);
                _navigateToCategory(context, "Haircut Ideas", DataSource.haircutImages, filters: DataSource.haircutFilters);
              }),
              _buildDrawerItem(context, "Wedding Photos", Icons.favorite_border, () {
                Navigator.pop(context);
                _navigateToCategory(context, "Wedding Photos", DataSource.weddingImages);
              }),
              _buildDrawerItem(context, "Baby Photos", Icons.child_care, () {
                Navigator.pop(context);
                _navigateToCategory(context, "Baby Photos", DataSource.babyImages);
              }),
              _buildDrawerItem(context, "Nature", Icons.landscape, () {
                Navigator.pop(context);
                _navigateToCategory(context, "Nature", DataSource.natureImages);
              }),
              _buildDrawerItem(context, "Travel", Icons.flight, () {
                Navigator.pop(context);
                _navigateToCategory(context, "Travel", DataSource.travelImages);
              }),
              _buildDrawerItem(context, "Architecture", Icons.apartment, () {
                Navigator.pop(context);
                _navigateToCategory(context, "Architecture", DataSource.architectureImages);
              }),
            ],
          ),
          ListTile(
            leading: const Icon(Icons.format_quote_outlined),
            title: const Text('Quotes'),
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
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Settings'),
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
    );
  }

  Widget _buildDrawerItem(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, size: 20, color: Theme.of(context).colorScheme.secondary),
      title: Text(title, style: const TextStyle(fontSize: 14)),
      onTap: onTap,
      contentPadding: const EdgeInsets.only(left: 32, right: 16),
    );
  }

  void _navigateToCategory(BuildContext context, String title, List<String> images, {Map<String, List<String>>? filters}) {
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

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Discover",
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                const SizedBox(height: 8),
                Text(
                  "Find your next inspiration",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                Text(
                  "Trending",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 150,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      // Use a mix of images for trending
                      final trendingImages = [
                        ...DataSource.haircutImages,
                        ...DataSource.weddingImages,
                      ]..shuffle();
                      final imageUrl = trendingImages[index % trendingImages.length];
                      
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FullscreenImageViewer(imageUrl: imageUrl),
                            ),
                          );
                        },
                        child: Container(
                          width: 120,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(
                              image: NetworkImage(imageUrl),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  "Categories",
                  style: Theme.of(context).textTheme.titleLarge,
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
            childCount: 7,
            itemBuilder: (context, index) {
              // Map index to category data
              switch (index) {
                case 0:
                  return CategoryCard(
                    title: "Haircut Ideas",
                    icon: Icons.content_cut,
                    color: const Color(0xFF6C63FF),
                    onTap: () => _navigateToCategory(context, "Haircut Ideas", DataSource.haircutImages, filters: DataSource.haircutFilters),
                  );
                case 1:
                  return CategoryCard(
                    title: "Wedding",
                    icon: Icons.favorite,
                    color: const Color(0xFFFF4081),
                    onTap: () => _navigateToCategory(context, "Wedding Photos", DataSource.weddingImages),
                  );
                case 2:
                  return CategoryCard(
                    title: "Baby Photos",
                    icon: Icons.child_care,
                    color: const Color(0xFFFF9100),
                    onTap: () => _navigateToCategory(context, "Baby Photos", DataSource.babyImages),
                  );
                case 3:
                  return CategoryCard(
                    title: "Nature",
                    icon: Icons.landscape,
                    color: const Color(0xFF00E676),
                    onTap: () => _navigateToCategory(context, "Nature", DataSource.natureImages),
                  );
                case 4:
                  return CategoryCard(
                    title: "Travel",
                    icon: Icons.flight,
                    color: const Color(0xFF00B0FF),
                    onTap: () => _navigateToCategory(context, "Travel", DataSource.travelImages),
                  );
                case 5:
                  return CategoryCard(
                    title: "Architecture",
                    icon: Icons.apartment,
                    color: const Color(0xFF9E9E9E),
                    onTap: () => _navigateToCategory(context, "Architecture", DataSource.architectureImages),
                  );
                case 6:
                  return CategoryCard(
                    title: "Quotes",
                    icon: Icons.format_quote,
                    color: const Color(0xFFAA00FF),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QuotesScreen(fallbackQuotes: DataSource.quotesList),
                      ),
                    ),
                  );
                default:
                  return const SizedBox.shrink();
              }
            },
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
      ],
    );
  }

  void _navigateToCategory(BuildContext context, String title, List<String> images, {Map<String, List<String>>? filters}) {
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
