import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_nav_bar.dart';
import 'watch_again_videos_screen.dart';
import 'watch_again_games_screen.dart';
import 'watch_again_books_screen.dart';
import 'screenTime.dart';

class WatchAgainCategoriesScreen extends StatefulWidget {
  const WatchAgainCategoriesScreen({super.key});

  @override
  State<WatchAgainCategoriesScreen> createState() =>
      _WatchAgainCategoriesScreenState();
}

class _WatchAgainCategoriesScreenState
    extends State<WatchAgainCategoriesScreen> {
  String? selectedProfile;

  @override
  void initState() {
    super.initState();
    _loadSelectedProfile();
  }

  Future<void> _loadSelectedProfile() async {
    final prefs = await SharedPreferences.getInstance();
    selectedProfile = prefs.getString('selectedProfile');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Transform.rotate(
                      angle: 3.14159 / 12,
                      child: Image.asset("assets/images/star.png", width: 60),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ScreenTime(),
                              ), // ⏰ Go to countdown
                            );
                          },
                          child: const Icon(
                            Icons.access_time,
                            size: 40,
                            color: Color(0xFF8B8B8B),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ClipOval(
                          child: Image.asset(
                            _getAvatarPathForProfile(selectedProfile),
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                "Wanna Watch Again?",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  fontFamily: "YouTube",
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _buildCategoryTile(
                      context,
                      title: 'Videos',
                      image: 'assets/images/videos.png',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const WatchAgainVideosScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildCategoryTile(
                      context,
                      title: 'Games',
                      image: 'assets/images/sonic.png',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const WatchAgainGamesScreen(),
                          ),
                        );
                        // TODO: Navigate to Watch Again Books
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildCategoryTile(
                      context,
                      title: 'E-Books',
                      image: 'assets/images/kids-books.png',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const WatchAgainBooksScreen(),
                          ),
                        );
                        // TODO: Navigate to Watch Again Games
                      },
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AppNavBar(parentContext: context),
    );
  }

  Widget _buildCategoryTile(
    BuildContext context, {
    required String title,
    required String image,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              image,
              height: 140,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Container(
            height: 140,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.black38,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: "YouTube",
            ),
          ),
        ],
      ),
    );
  }

  String _getAvatarPathForProfile(String? name) {
    switch (name) {
      case 'Luke':
        return 'assets/images/avatar1.png';
      case 'Lucy':
        return 'assets/images/avatar2.png';
      case 'Emma':
        return 'assets/images/avatar3.png';
      default:
        return 'assets/images/avatar2.png'; // fallback
    }
  }
}
