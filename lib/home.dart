import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'video_page.dart';
import 'game_screen.dart';
import 'book_viewer.dart';
import 'app_nav_bar.dart';
import '../utils/watch_history_service.dart';
import 'screenTime.dart';

class HomePage extends StatefulWidget {
  final int initialTab;
  const HomePage({super.key, this.initialTab = 0});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late int selectedIndex;
  final List<String> categories = ["All", "Watch", "Play", "Read"];
  final String defaultAvatar =
      'https://www.gstatic.com/youtube/img/creator/no_profile_picture.png';

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.initialTab;
    _loadSelectedProfile();
  }

  String? selectedProfile;
  Future<void> _loadSelectedProfile() async {
    final prefs = await SharedPreferences.getInstance();
    selectedProfile = prefs.getString('selectedProfile');
    print("👤 Loaded profile: $selectedProfile");

    // You can now use this name to:
    // - Load avatar
    // - Load content tied to that profile
    setState(() {});
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: List.generate(categories.length, (index) {
                    final isSelected = index == selectedIndex;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedIndex = index;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color:
                                  isSelected ? Colors.deepPurple : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border:
                                  isSelected
                                      ? null
                                      : Border.all(
                                        color: Colors.black,
                                        width: 1,
                                      ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              categories[index],
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black,
                                fontWeight: FontWeight.w900,
                                fontFamily: "YouTube",
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(top: 24.0),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [_buildContent()],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 200),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AppNavBar(parentContext: context),
    );
  }

  Widget _buildContent() {
    return FutureBuilder<DocumentSnapshot>(
      future:
          FirebaseFirestore.instance
              .collection('content')
              .doc('current_selection')
              .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();

        final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};

        final List<Map<String, dynamic>> videos =
            (data['videos'] ?? []).map<Map<String, dynamic>>((item) {
              return {
                "title": item["title"]?.toString() ?? "Untitled",
                "id": item["id"]?.toString() ?? "",
                "channel": item["channel"]?.toString() ?? "Unknown Channel",
                "description": item["description"]?.toString() ?? "",
              };
            }).toList();

        final List<Map<String, dynamic>> games =
            (data['games'] ?? []).cast<Map<String, dynamic>>();
        final List<Map<String, dynamic>> books =
            (data['books'] ?? []).cast<Map<String, dynamic>>();

        final List<Widget> allSections = [];
        if (videos.isNotEmpty)
          allSections.add(_buildVideoSection("Videos", videos));
        if (games.isNotEmpty)
          allSections.add(_buildGameSection("Games", games));
        if (books.isNotEmpty)
          allSections.add(_buildBookSection("E-Books", books));

        switch (selectedIndex) {
          case 0:
            return Column(children: allSections); // ALL tab stays horizontal
          case 1:
            return _buildVerticalList(
              "Videos",
              videos,
              _buildVerticalVideoCard,
            );
          case 2:
            return _buildVerticalList("Games", games, _buildVerticalGameCard);
          case 3:
          case 3:
            return _buildVerticalBookGrid("E-Books", books);
          default:
            return const SizedBox();
        }
      },
    );
  }

  Widget _buildVerticalBookGrid(
    String title,
    List<Map<String, dynamic>> books,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w900,
              fontFamily: "YouTube",
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 16,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 0.65, // 📐 taller than wide
            children:
                books.map((book) => _buildVerticalBookCard(book)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalList(
    String title,
    List<dynamic> items,
    Widget Function(dynamic item) itemBuilder,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children:
                items
                    .map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 40),
                        child: itemBuilder(item),
                      ),
                    )
                    .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalVideoCard(dynamic video) {
    final String thumbnailUrl =
        'https://img.youtube.com/vi/${video["id"]}/0.jpg';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (_) => VideoPage(title: video["title"], videoId: video["id"]),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  thumbnailUrl,
                  width: double.infinity,
                  height: 180,
                  fit: BoxFit.cover,
                ),
              ),
              // ▶️ Play icon overlay
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 50,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            video["title"],
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 18,
              fontFamily: "YouTube",
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const CircleAvatar(
                radius: 12,
                backgroundImage: NetworkImage(
                  'https://cdn-icons-png.flaticon.com/512/1384/1384060.png',
                ),
                backgroundColor: Colors.transparent,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  video["channel"],
                  style: const TextStyle(fontSize: 12, color: Colors.black),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            video["description"],
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalGameCard(dynamic game) {
    return GestureDetector(
      onTap: () async {
        if (selectedProfile != null) {
          await saveToWatchHistory(selectedProfile!, "games", {
            "title": game["title"],
            "url": game["url"],
            "image": game["image"],
          });
        }

        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => GameScreen(gameUrl: game["url"])),
        );
      },

      child: Container(
        height: 180,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
        child: Stack(
          children: [
            // 🎮 Game Thumbnail with dark overlay
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: ColorFiltered(
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.3),
                  BlendMode.darken,
                ),
                child:
                    game["image"] != null
                        ? Image.asset(
                          game["image"],
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        )
                        : Container(
                          color: Colors.deepPurple[100],
                          width: double.infinity,
                          height: double.infinity,
                        ),
              ),
            ),

            // 🏷️ Title at bottom center
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 10,
                ),
                child: Text(
                  game["title"],
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                    fontFamily: "YouTube",
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerticalBookCard(Map<String, dynamic> book) {
    final bookTitle = book["title"] ?? "Untitled";
    final bookPages = List<String>.from(book["bookPages"] ?? []);
    final bookCover = book["cover"];

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (_) => BookViewerScreen(title: bookTitle, pages: bookPages),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.deepPurple[50],
              image:
                  bookCover != null
                      ? DecorationImage(
                        image: NetworkImage(bookCover),
                        fit: BoxFit.cover,
                      )
                      : null,
            ),
            child:
                bookCover == null
                    ? Center(
                      child: Text(
                        bookTitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    )
                    : null,
          ),
          const SizedBox(height: 6),
          Text(
            bookTitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontFamily: "YouTube",
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoSection(String title, List<Map<String, dynamic>> videos) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        16,
        16,
        16,
        0,
      ), // 🔽 Removed bottom padding
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w900,
              fontFamily: "YouTube",
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 290, // ✅ Slightly reduced to avoid white gap
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: videos.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final video = videos[index];
                return _buildVideoCard(
                  title: video["title"],
                  videoId: video["id"],
                  channel: video["channel"],
                  description: video["description"],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoCard({
    required String title,
    required String videoId,
    required String channel,
    required String description,
  }) {
    final thumbnailUrl = 'https://img.youtube.com/vi/$videoId/0.jpg';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VideoPage(title: title, videoId: videoId),
          ),
        );
      },
      child: Container(
        width: 250,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    thumbnailUrl,
                    width: 250,
                    height: 140,
                    fit: BoxFit.cover,
                  ),
                ),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                fontFamily: "YouTube",
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundImage: NetworkImage(
                    'https://cdn-icons-png.flaticon.com/512/1384/1384060.png',
                  ),
                  backgroundColor: Colors.transparent,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    channel,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black,
                      fontFamily: "YouTube",
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontFamily: "YouTube",
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameSection(String title, List<Map<String, dynamic>> games) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w900,
              fontFamily: "YouTube",
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 140,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: games.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final game = games[index];
                return _buildGameCard(
                  game["title"],
                  game["url"],
                  game["image"],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameCard(String title, String url, String? imageAsset) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => GameScreen(gameUrl: url)),
        );
      },
      child: Container(
        width: 250,
        height: 140,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
        child: Stack(
          children: [
            // 📸 Game Thumbnail (darkened)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: ColorFiltered(
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.3), // Dark overlay
                  BlendMode.darken,
                ),
                child:
                    imageAsset != null
                        ? Image.asset(
                          imageAsset,
                          fit: BoxFit.cover,
                          width: 250,
                          height: 140,
                        )
                        : Container(color: Colors.deepPurple[100]),
              ),
            ),

            // 🏷️ Title at the bottom center
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 5,
                ),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                    fontFamily: "YouTube",
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookSection(String title, List<Map<String, dynamic>> books) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w900,
              fontFamily: "YouTube",
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 300,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: books.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final book = books[index];
                final bookTitle = book["title"] ?? "Untitled";
                final bookPages = List<String>.from(book["bookPages"] ?? []);
                final bookCover = book["cover"];

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => BookViewerScreen(
                              title: bookTitle,
                              pages: bookPages,
                            ),
                      ),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Book Thumbnail
                      Container(
                        width: 150,
                        height: 180,
                        decoration: BoxDecoration(
                          color: Colors.deepPurple[50],
                          borderRadius: BorderRadius.circular(8),
                          image:
                              bookCover != null
                                  ? DecorationImage(
                                    image: NetworkImage(bookCover),
                                    fit: BoxFit.cover,
                                  )
                                  : null,
                        ),
                        child:
                            bookCover == null
                                ? Center(
                                  child: Text(
                                    bookTitle,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                )
                                : null,
                      ),
                      const SizedBox(height: 6),

                      // Book Title
                      SizedBox(
                        width: 150,
                        child: Text(
                          bookTitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontFamily: "YouTube",
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
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
