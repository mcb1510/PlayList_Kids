import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'game_screen.dart';
import 'screenTime.dart';

class WatchAgainGamesScreen extends StatefulWidget {
  const WatchAgainGamesScreen({super.key});

  @override
  State<WatchAgainGamesScreen> createState() => _WatchAgainGamesScreenState();
}

class _WatchAgainGamesScreenState extends State<WatchAgainGamesScreen> {
  List<Map<String, dynamic>> gameHistory = [];
  String? selectedProfile;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGameHistory();
  }

  Future<void> _loadGameHistory() async {
    final prefs = await SharedPreferences.getInstance();
    selectedProfile = prefs.getString('selectedProfile');

    if (selectedProfile == null) {
      setState(() => isLoading = false);
      return;
    }

    final doc =
        await FirebaseFirestore.instance
            .collection('watch_history')
            .doc(selectedProfile)
            .get();

    final data = doc.data() ?? {};
    final games = List<Map<String, dynamic>>.from(data['games'] ?? []);

    setState(() {
      gameHistory = games;
      isLoading = false;
    });
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
        return 'assets/images/avatar2.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),
      body: SafeArea(
        child:
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                  children: [
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          Transform.rotate(
                            angle: 3.14159 / 12,
                            child: Image.asset(
                              "assets/images/star.png",
                              width: 60,
                            ),
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
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Watch Again: Games",
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 24,
                            fontFamily: "YouTube",
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child:
                          gameHistory.isEmpty
                              ? const Center(
                                child: Text(
                                  "No games played yet!",
                                  style: TextStyle(fontSize: 18),
                                ),
                              )
                              : ListView.builder(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                itemCount: gameHistory.length,
                                itemBuilder: (context, index) {
                                  final game = gameHistory[index];
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 24),
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (_) => GameScreen(
                                                  gameUrl: game["url"],
                                                ),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        height: 160,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          image:
                                              game["image"] != null
                                                  ? DecorationImage(
                                                    image: AssetImage(
                                                      game["image"],
                                                    ),
                                                    fit: BoxFit.cover,
                                                  )
                                                  : null,
                                          color: Colors.deepPurple[100],
                                        ),
                                        alignment: Alignment.bottomLeft,
                                        padding: const EdgeInsets.all(12),
                                        child: Text(
                                          game["title"] ?? "Untitled Game",
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.white,
                                            fontFamily: "YouTube",
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                    ),
                  ],
                ),
      ),
    );
  }
}
