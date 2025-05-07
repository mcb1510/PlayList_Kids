import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_nav_bar.dart';

class ProfileSettingsDetailsScreen extends StatefulWidget {
  const ProfileSettingsDetailsScreen({super.key});

  @override
  State<ProfileSettingsDetailsScreen> createState() => _ProfileSettingsDetailsScreenState();
}

class _ProfileSettingsDetailsScreenState extends State<ProfileSettingsDetailsScreen> {
  String selectedAge = "9-10 yrs";
  String selectedAvatar = 'assets/images/avatar1.png';
  int totalWatchTime = 10;
  int setWatchTime = 12;

  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedAge = prefs.getString('profileAge') ?? '9-10 yrs';
      selectedAvatar = prefs.getString('avatarPath') ?? 'assets/images/avatar1.png';
      _nameController.text = prefs.getString('selectedProfile') ?? 'Unknown';
      setWatchTime = prefs.getInt('watchTimeLimit') ?? 12;
    });
  }

  Future<void> _saveProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profileAge', selectedAge);
    await prefs.setInt('watchTimeLimit', setWatchTime);
    await prefs.setInt('startTime', DateTime.now().millisecondsSinceEpoch);
    await prefs.setString('selectedProfile', _nameController.text);
    Navigator.pop(context, true); // ✅ return "true" to signal an update

  }

  Widget _buildAgeButton(String label) {
    final isSelected = selectedAge == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedAge = label),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected ? Color(0xFF6A4BBC) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF6A4BBC)),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Color(0xFF6A4BBC),
                fontWeight: FontWeight.bold,
                fontFamily: "YouTube",
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWatchTile(String label, String value, {bool showEdit = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(label, style: TextStyle(fontSize: 16, fontFamily: "YouTube", fontWeight: FontWeight.w500)),
              Spacer(),
              if (showEdit)
                GestureDetector(
                  onTap: _editWatchTime,
                  child: Icon(Icons.edit, size: 16, color: Color(0xFF6A4BBC)),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontFamily: "YouTube",
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF6A4BBC),
            ),
          ),
        ],
      ),
    );
  }

  void _editWatchTime() {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController controller = TextEditingController(text: setWatchTime.toString());
        return AlertDialog(
          title: Text("Set Watch Time (hours)", style: TextStyle(fontFamily: "YouTube")),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            style: TextStyle(fontFamily: "YouTube"),
            decoration: InputDecoration(border: OutlineInputBorder()),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel", style: TextStyle(fontFamily: "YouTube")),
            ),
            TextButton(
              onPressed: () {
                final int? val = int.tryParse(controller.text);
                if (val != null && val > 0) {
                  setState(() {
                    setWatchTime = val;
                  });
                }
                Navigator.pop(context);
              },
              child: Text("Save", style: TextStyle(fontFamily: "YouTube")),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final name = _nameController.text;

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: AppNavBar(parentContext: context),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Transform.rotate(
                  angle: 3.14159 / 12,
                  child: Image.asset("assets/images/star.png", width: 60),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "$name's Profile",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, fontFamily: "Lora"),
              ),
              const SizedBox(height: 24),
              CircleAvatar(
                radius: screenWidth * 0.2,
                backgroundImage: AssetImage(selectedAvatar),
              ),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerLeft,
                child: Text("Name :", style: TextStyle(fontSize: 16, fontFamily: "YouTube", fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                style: TextStyle(fontFamily: "YouTube"),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Color(0xFFF5F5F5),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerLeft,
                child: Text("Age :", style: TextStyle(fontSize: 16, fontFamily: "YouTube", fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildAgeButton("3–5 yrs"),
                  _buildAgeButton("6–8 yrs"),
                  _buildAgeButton("9-10 yrs"),
                ],
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(child: _buildWatchTile("Total Watch Time", "$totalWatchTime hours")),
                  const SizedBox(width: 12),
                  Expanded(child: _buildWatchTile("Set Watch Time", "$setWatchTime hours", showEdit: true)),
                ],
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF6A4BBC),
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text("Save", style: TextStyle(fontSize: 20, color: Colors.white, fontFamily: "YouTube")),
              ),
              SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
