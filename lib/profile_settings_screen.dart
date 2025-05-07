import 'package:flutter/material.dart';
import 'package:playlistkids/profile_settings_detail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_nav_bar.dart';
import 'change_pin_screen.dart';
import 'profileSelection.dart';
import 'kidsLoginPage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileSettingsScreen extends StatefulWidget {
  @override
  _ProfileSettingsScreenState createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  String? selectedProfile;

  @override
  void initState() {
    super.initState();
    _loadSelectedProfile();
  }

  Future<void> _loadSelectedProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedProfile = prefs.getString('selectedProfile') ?? 'Unknown';
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
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32),
          child:
              selectedProfile == null
                  ? Center(child: CircularProgressIndicator())
                  : Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // ⭐ Star
                      Align(
                        alignment: Alignment.topLeft,
                        child: Transform.rotate(
                          angle: 3.14159 / 12,
                          child: Image.asset(
                            "assets/images/star.png",
                            width: 60,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // 👧 Profile Name
                      Text(
                        "${selectedProfile!}'s Profile",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Lora",
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Avatar + overlay
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: screenWidth * 0.2,
                            backgroundImage: AssetImage(
                              _getAvatarPathForProfile(selectedProfile),
                            ),
                          ),
                          Positioned(
                            right: 4,
                            bottom: 4,
                            child: CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.purple,
                              child: Icon(
                                Icons.add,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 40),

                      _buildSettingsButton(
                        "Profile Settings",
                        Icons.search,
                        onTap: () async {
                          final updated = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProfileSettingsDetailsScreen(),
                            ),
                          );

                          if (updated == true) {
                            // ⬅️ only reload if profile was updated
                            _loadSelectedProfile();
                          }
                        },
                      ),

                      _buildSettingsButton(
                        "Change Pin",
                        Icons.lock,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChangePinScreen(),
                            ),
                          );
                        },
                      ),
                      _buildSettingsButton(
                        "Delete Profile",
                        Icons.delete,
                        onTap: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder:
                                (context) => AlertDialog(
                                  title: Text("Delete Profile"),
                                  content: Text(
                                    "Are you sure you want to delete this profile? This cannot be undone.",
                                  ),
                                  actions: [
                                    TextButton(
                                      child: Text(
                                        "Cancel",
                                        style: TextStyle(color: Colors.black),
                                      ),
                                      onPressed:
                                          () => Navigator.pop(context, false),
                                    ),
                                    TextButton(
                                      child: Text(
                                        "Delete",
                                        style: TextStyle(
                                          color: Color(0xFF6A4BBC),
                                        ),
                                      ),
                                      onPressed:
                                          () => Navigator.pop(context, true),
                                    ),
                                  ],
                                ),
                          );

                          if (confirm == true) {
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.remove('selectedProfile');
                            await prefs.remove('avatarPath');
                            await prefs.remove('profileAge');
                            await prefs.remove('watchTimeLimit');

                            // Navigate back to profile selection screen
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (_) => profileSelection(),
                              ),
                              (route) => false,
                            );
                          }
                        },
                      ),

                      _buildSettingsButton(
                        "Switch Profile",
                        Icons.person,
                        iconColor: Colors.black,
                        onTap: () async {
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.remove(
                            'selectedProfile',
                          ); // Clear current profile

                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => profileSelection(),
                            ), // Go to profile picker
                          );
                        },
                      ),

                      _buildSettingsButton(
                        "Log Out",
                        Icons.logout,
                        onTap: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder:
                                (context) => AlertDialog(
                                  title: Text("Log out"),
                                  content: Text(
                                    "Are you sure you want to log out from your account?",
                                  ),
                                  actions: [
                                    TextButton(
                                      child: Text(
                                        "Cancel",
                                        style: TextStyle(color: Colors.black),
                                      ),
                                      onPressed:
                                          () => Navigator.pop(context, false),
                                    ),
                                    TextButton(
                                      child: Text(
                                        "Log out",
                                        style: TextStyle(
                                          color: Color(0xFF6A4BBC),
                                        ),
                                      ),
                                      onPressed: () async {
                                        final prefs =
                                            await SharedPreferences.getInstance();
                                        await FirebaseAuth.instance
                                            .signOut(); // 🔐 Log out
                                        await prefs
                                            .clear(); // 🧹 Clear all local data
                                        Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => KidsLoginPage(),
                                          ),
                                          (route) => false,
                                        );
                                      },
                                    ),
                                  ],
                                ),
                          );

                          // Optional: handle case if user cancels
                          if (confirm != true) return;
                        },
                      ),
                    ],
                  ),
        ),
      ),
      bottomNavigationBar: AppNavBar(parentContext: context),
    );
  }

  Widget _buildSettingsButton(
    String title,
    IconData icon, {
    Color iconColor = Colors.black,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          decoration: BoxDecoration(
            color: Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black12),
          ),
          child: Row(
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: "YouTube",
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Icon(icon, size: 20, color: iconColor),
            ],
          ),
        ),
      ),
    );
  }
}
