import 'package:flutter/material.dart';
import 'home.dart';
import 'PinEntryScreen.dart';
import 'watchAgainCategoriesScreen.dart';

class AppNavBar extends StatelessWidget {
  final BuildContext parentContext;

  const AppNavBar({super.key, required this.parentContext});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        // White curved background bar
        Container(
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(32),
              topRight: Radius.circular(32),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, -2),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Home button (always goes to HomePage with All tab)
              SizedBox(
                width: 120,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushAndRemoveUntil(
                      parentContext,
                      MaterialPageRoute(
                        builder: (_) => const HomePage(initialTab: 0),
                      ),
                      (route) => false,
                    );
                  },
                  child: _buildNavItem(Icons.home, "Home", true),
                ),
              ),
              const SizedBox(width: 100),
              // Parental Control button
              SizedBox(
                width: 120,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      parentContext,
                      MaterialPageRoute(builder: (_) => PinEntryScreen()),
                    );
                  },
                  child: _buildNavItem(
                    Icons.lock_outline,
                    "Parental Control",
                    false,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Floating Replay Button in Center
        Positioned(
          top: -32,
          child: Container(
            height: 100,
            width: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF6A4BBC),
              border: Border.all(color: const Color(0xFFA9C0FF), width: 6),
            ),
            child: IconButton(
              icon: const Icon(Icons.replay, color: Colors.white, size: 36),
              onPressed: () {
                Navigator.push(
                  parentContext,
                  MaterialPageRoute(
                    builder: (_) => const WatchAgainCategoriesScreen(),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: isActive ? const Color(0xFF4A2D8C) : Colors.grey),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontFamily: "YouTube",
            color: isActive ? const Color(0xFF4A2D8C) : Colors.grey,
          ),
        ),
      ],
    );
  }
}
