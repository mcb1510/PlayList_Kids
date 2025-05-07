import 'package:flutter/material.dart';
import 'screenTime.dart';
import 'package:shared_preferences/shared_preferences.dart';

class profileSelection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final containerWidth = screenWidth * 0.8;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Star Logo
              Padding(
                padding: EdgeInsets.only(top: screenHeight * 0.08),
                child: Container(
                  width: containerWidth,
                  alignment: Alignment.centerLeft,
                  child: Transform.rotate(
                    angle: 3.14159 / 12,
                    child: Image.asset(
                      "assets/images/star.png",
                      width: screenWidth * 0.2,
                    ),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.04),

              // Who's Watching?
              Container(
                width: containerWidth,
                alignment: Alignment.center,
                child: Text(
                  "Who's Watching?",
                  style: TextStyle(
                    fontSize: screenWidth * 0.08,
                    fontFamily: "Lora",
                    fontWeight: FontWeight.normal,
                    color: Colors.black,
                  ),
                ),
              ),

              SizedBox(height: screenHeight * 0.05),

              // First Avatar Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ProfileAvatar(
                    imagePath: "assets/images/avatar1.png",
                    profileName: "Luke",
                    onTap: () async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setString('selectedProfile', 'Luke');
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => ScreenTime()),
                      );
                    },
                  ),
                  _ProfileAvatar(
                    imagePath: "assets/images/avatar2.png",
                    profileName: "Lucy",
                    onTap: () async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setString('selectedProfile', 'Lucy');
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => ScreenTime()),
                      );
                    },
                  ),
                ],
              ),

              SizedBox(height: screenHeight * 0.05),

              // Second Avatar Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ProfileAvatar(
                    imagePath: "assets/images/avatar3.png",
                    profileName: "Emma",
                    onTap: () async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setString('selectedProfile', 'Emma');
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => ScreenTime()),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Reusable Avatar Widget
class _ProfileAvatar extends StatelessWidget {
  final String imagePath;
  final String profileName;
  final VoidCallback onTap;

  const _ProfileAvatar({
    Key? key,
    required this.imagePath,
    required this.profileName,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(1.0),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Color(0xFF4B3174), width: 1.0),
              borderRadius: BorderRadius.circular(1.0),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(1.0),
              child: Image.asset(
                imagePath,
                width: screenWidth * 0.4,
                height: screenWidth * 0.4,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            profileName,
            style: TextStyle(
              fontSize: 18,
              fontFamily: "YouTube",
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
