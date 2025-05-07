import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'home.dart';

class ScreenTime extends StatefulWidget {
  const ScreenTime({super.key});

  @override
  State<ScreenTime> createState() => _ScreenTimeState();
}

class _ScreenTimeState extends State<ScreenTime> {
  late Timer timer;
  Duration remainingTime = Duration.zero;
  late DateTime startTime;
  int allowedHours = 12;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadStartTime();
    timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => updateRemainingTime(),
    );
  }

  Future<void> loadStartTime() async {
    final prefs = await SharedPreferences.getInstance();
    final startTimeMillis = prefs.getInt('startTime');
    allowedHours = prefs.getInt('watchTimeLimit') ?? 12;

    if (startTimeMillis != null) {
      startTime = DateTime.fromMillisecondsSinceEpoch(startTimeMillis);
    } else {
      startTime = DateTime.now();
      await prefs.setInt('startTime', startTime.millisecondsSinceEpoch);
    }

    setState(() {
      isLoading = false;
    });
    updateRemainingTime();
  }

  void updateRemainingTime() {
    final now = DateTime.now();
    final endTime = startTime.add(Duration(hours: allowedHours));
    final diff = endTime.difference(now);

    setState(() {
      remainingTime = diff.isNegative ? Duration.zero : diff;
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final hours = remainingTime.inHours;
    final minutes = remainingTime.inMinutes % 60;
    final seconds = remainingTime.inSeconds % 60;

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final containerWidth = screenWidth * 0.8;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
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
              SizedBox(height: screenHeight * 0.04),
              Container(
                width: containerWidth,
                alignment: Alignment.center,
                child: Text(
                  "You have this much time left to watch",
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    fontFamily: "YouTube",
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: screenHeight * 0.03),
              const Icon(
                Icons.access_time,
                size: 40,
                color: Color(0xFF8B8B8B),
              ),
              SizedBox(height: screenHeight * 0.03),
              Container(
                width: containerWidth,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        Text(
                          hours.toString().padLeft(2, '0'),
                          style: TextStyle(
                            fontSize: screenWidth * 0.08,
                            fontWeight: FontWeight.bold,
                            fontFamily: "YouTube",
                          ),
                        ),
                        Text(
                          "Hours",
                          style: TextStyle(fontSize: screenWidth * 0.04),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          minutes.toString().padLeft(2, '0'),
                          style: TextStyle(
                            fontSize: screenWidth * 0.08,
                            fontWeight: FontWeight.bold,
                            fontFamily: "YouTube",
                          ),
                        ),
                        Text(
                          "Minutes",
                          style: TextStyle(fontSize: screenWidth * 0.04),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          seconds.toString().padLeft(2, '0'),
                          style: TextStyle(
                            fontSize: screenWidth * 0.08,
                            fontWeight: FontWeight.bold,
                            fontFamily: "YouTube",
                          ),
                        ),
                        Text(
                          "Seconds",
                          style: TextStyle(fontSize: screenWidth * 0.04),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.03),
              Container(
                width: containerWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${(allowedHours * 3600 - remainingTime.inSeconds) ~/ 3600}:${((allowedHours * 3600 - remainingTime.inSeconds) % 3600) ~/ 60}".padLeft(4, '0') + " hr",
                          style: TextStyle(
                            fontSize: screenWidth * 0.05,
                            fontWeight: FontWeight.w900,
                            fontFamily: "YouTube",
                          ),
                        ),
                        Text(
                          "$allowedHours.00 hr",
                          style: TextStyle(
                            fontSize: screenWidth * 0.05,
                            fontWeight: FontWeight.w900,
                            fontFamily: "YouTube",
                          ),
                        ),
                      ],
                    ),
                    LinearProgressIndicator(
                      value: (allowedHours * 3600 - remainingTime.inSeconds) /
                          (allowedHours * 3600),
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF795DA8)),
                    ),
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.04),
              Container(
                width: containerWidth,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      "Your watch time for this week is set to",
                      style: TextStyle(
                        fontSize: screenWidth * 0.04,
                        color: Colors.black,
                        fontFamily: "YouTube",
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "$allowedHours hours",
                      style: TextStyle(
                        fontSize: screenWidth * 0.06,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF795DA8),
                        fontFamily: "YouTube",
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.05),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const HomePage()),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF795DA8),
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  "Back to Home",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: screenWidth * 0.05,
                    fontWeight: FontWeight.bold,
                    fontFamily: "YouTube",
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
