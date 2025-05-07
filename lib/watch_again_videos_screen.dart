import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'video_page.dart';
import 'screenTime.dart';

class WatchAgainVideosScreen extends StatefulWidget {
  const WatchAgainVideosScreen({super.key});

  @override
  State<WatchAgainVideosScreen> createState() => _WatchAgainVideosScreenState();
}

class _WatchAgainVideosScreenState extends State<WatchAgainVideosScreen> {
  List<Map<String, dynamic>> videoHistory = [];
  String? selectedProfile;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVideoHistory();
  }

  Future<void> _loadVideoHistory() async {
    final prefs = await SharedPreferences.getInstance();
    selectedProfile = prefs.getString('selectedProfile');

    if (selectedProfile == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    final doc =
        await FirebaseFirestore.instance
            .collection('watch_history')
            .doc(selectedProfile)
            .get();

    final data = doc.data() ?? {};
    final videos = List<Map<String, dynamic>>.from(data['videos'] ?? []);

    setState(() {
      videoHistory = videos;
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
        return 'assets/images/avatar2.png'; // fallback
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
                          "Watch Again: Videos",
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
                          videoHistory.isEmpty
                              ? const Center(
                                child: Text(
                                  "No videos watched yet!",
                                  style: TextStyle(fontSize: 18),
                                ),
                              )
                              : ListView.builder(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                itemCount: videoHistory.length,
                                itemBuilder: (context, index) {
                                  final video = videoHistory[index];
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 24),
                                    child: _buildVideoCard(video),
                                  );
                                },
                              ),
                    ),
                  ],
                ),
      ),
    );
  }

  Widget _buildVideoCard(Map<String, dynamic> video) {
    final thumbnailUrl = 'https://img.youtube.com/vi/${video["id"]}/0.jpg';

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
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              thumbnailUrl,
              width: double.infinity,
              height: 180,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            video["title"] ?? "Untitled",
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 18,
              fontFamily: "YouTube",
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Row(),
          const SizedBox(height: 4),
          Text(
            video["description"] ?? "",
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
