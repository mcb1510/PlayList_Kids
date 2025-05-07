import 'kidsLoginPage.dart';
import 'package:flutter/material.dart';

class OnboardingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white, // Background color
      body: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Welcome!",
                style: TextStyle(
                  fontSize: screenWidth * 0.1,
                  fontFamily: "LoveYaLikeASister",
                  fontWeight: FontWeight.normal,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 50),
              Transform.rotate(
                angle: -3.14159 / 12,
                child: Image.asset(
                  "assets/images/star.png",
                  width: screenWidth * 0.6,
                ),
              ),
              SizedBox(height: 50),
              Text(
                "Fun times, fair breaks,\njust for you!",
                style: TextStyle(
                  fontSize: screenWidth * 0.08,
                  fontFamily: "LoveYaLikeASister",
                  fontWeight: FontWeight.normal,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => KidsLoginPage()),
                  );
                },
                child: Text(
                  "Get Started",
                  style: TextStyle(
                    fontSize: screenWidth * 0.05,
                    fontFamily: "YouTube",
                    fontWeight: FontWeight.normal,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF795DA8),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.3,
                    vertical: screenWidth * 0.05,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
