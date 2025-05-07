import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'book_viewer.dart';
import 'screenTime.dart';

class WatchAgainBooksScreen extends StatefulWidget {
  const WatchAgainBooksScreen({super.key});

  @override
  State<WatchAgainBooksScreen> createState() => _WatchAgainBooksScreenState();
}

class _WatchAgainBooksScreenState extends State<WatchAgainBooksScreen> {
  List<Map<String, dynamic>> bookHistory = [];
  String? selectedProfile;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBookHistory();
  }

  Future<void> _loadBookHistory() async {
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
    final books = List<Map<String, dynamic>>.from(data['books'] ?? []);

    setState(() {
      bookHistory = books;
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
                          "Watch Again: Books",
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
                          bookHistory.isEmpty
                              ? const Center(
                                child: Text(
                                  "No books read yet!",
                                  style: TextStyle(fontSize: 18),
                                ),
                              )
                              : GridView.count(
                                crossAxisCount: 2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 16,
                                padding: const EdgeInsets.all(16),
                                childAspectRatio: 0.65,
                                children:
                                    bookHistory.map((book) {
                                      final bookTitle =
                                          book["title"] ?? "Untitled";
                                      final bookCover = book["cover"];
                                      final List<String> pages =
                                          List<String>.from(
                                            book["bookPages"] ?? [],
                                          );
                                      return GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (_) => BookViewerScreen(
                                                    title: bookTitle,
                                                    pages: pages,
                                                  ),
                                            ),
                                          );
                                        },
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Container(
                                              height: 200,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                color: Colors.deepPurple[50],
                                                image:
                                                    bookCover != null
                                                        ? DecorationImage(
                                                          image: NetworkImage(
                                                            bookCover,
                                                          ),
                                                          fit: BoxFit.cover,
                                                        )
                                                        : null,
                                              ),
                                              child:
                                                  bookCover == null
                                                      ? Center(
                                                        child: Text(
                                                          bookTitle,
                                                          textAlign:
                                                              TextAlign.center,
                                                          style:
                                                              const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                              ),
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
                                    }).toList(),
                              ),
                    ),
                  ],
                ),
      ),
    );
  }
}
