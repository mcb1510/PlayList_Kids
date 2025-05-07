import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/watch_history_service.dart';
import 'screenTime.dart'; // Import your ScreenTime page here

class VideoPage extends StatefulWidget {
  final String title;
  final String videoId;

  const VideoPage({
    super.key,
    required this.title,
    required this.videoId,
  });

  @override
  State<VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  late YoutubePlayerController _controller;
  bool showRewindIcon = false;
  bool showForwardIcon = false;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        enableCaption: false,
      ),
    );

    _saveVideoToHistory(); // Save to Firestore when video opens
  }

  Future<void> _saveVideoToHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final profile = prefs.getString('selectedProfile');
    if (profile == null) return;

    await saveToWatchHistory(profile, 'videos', {
      'title': widget.title,
      'id': widget.videoId,
      'channel': 'Unknown Channel',
      'description': '',
    });
  }

  void _showIcon(bool isForward) {
    setState(() {
      if (isForward) {
        showForwardIcon = true;
      } else {
        showRewindIcon = true;
      }
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        showForwardIcon = false;
        showRewindIcon = false;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
      ),
      builder: (context, player) {
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: _controller.value.isFullScreen
              ? null
              : AppBar(
                  backgroundColor: const Color(0xFF795DA8),
                  elevation: 0,
                  centerTitle: true,
                  title: Text(
                    widget.title,
                    style: const TextStyle(
                      fontFamily: "YouTube",
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  iconTheme: const IconThemeData(color: Colors.white),
                ),
          body: Stack(
            children: [
              Center(
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      YoutubePlayer(
                        controller: _controller,
                        showVideoProgressIndicator: true,
                      ),
                      Positioned.fill(
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onDoubleTap: () {
                                  final current = _controller.value.position;
                                  _controller.seekTo(
                                      current - const Duration(seconds: 10));
                                  _showIcon(false);
                                },
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onDoubleTap: () {
                                  final current = _controller.value.position;
                                  _controller.seekTo(
                                      current + const Duration(seconds: 10));
                                  _showIcon(true);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (showRewindIcon)
                        const Positioned(
                          left: 32,
                          child: Icon(Icons.replay_10,
                              size: 64, color: Colors.white),
                        ),
                      if (showForwardIcon)
                        const Positioned(
                          right: 32,
                          child: Icon(Icons.forward_10,
                              size: 64, color: Colors.white),
                        ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: SafeArea(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ScreenTime()),
                      );
                    },
                    child: const Icon(
                      Icons.access_time,
                      size: 32,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
