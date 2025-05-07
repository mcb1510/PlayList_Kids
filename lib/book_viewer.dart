import 'package:flutter/material.dart';
import 'screenTime.dart'; // 
class BookViewerScreen extends StatefulWidget {
  final String title;
  final List<String> pages;

  const BookViewerScreen({super.key, required this.title, required this.pages});

  @override
  State<BookViewerScreen> createState() => _BookViewerScreenState();
}

class _BookViewerScreenState extends State<BookViewerScreen> {
  int currentPage = 0;

  void nextPage() {
    if (currentPage < widget.pages.length - 1) {
      setState(() => currentPage++);
    }
  }

  void previousPage() {
    if (currentPage > 0) {
      setState(() => currentPage--);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pageUrl = widget.pages[currentPage];

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: Colors.white),
        backgroundColor: const Color(0xFF795DA8),
        centerTitle: true,
        title: Text(
          widget.title,
          style: const TextStyle(
            fontFamily: "YouTube",
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.access_time),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ScreenTime()),
              );
            },
          ),
        ],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: Image.network(
              pageUrl,
              fit: BoxFit.contain,
              loadingBuilder: (context, child, progress) =>
                  progress == null ? child : const Center(child: CircularProgressIndicator()),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: previousPage,
                ),
                Text(
                  "${currentPage + 1} / ${widget.pages.length}",
                  style: const TextStyle(
                    fontFamily: "YouTube",
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: nextPage,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
