import 'package:flutter/material.dart';
import 'profile_settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PinEntryScreen extends StatefulWidget {
  @override
  _PinEntryScreenState createState() => _PinEntryScreenState();
}

class _PinEntryScreenState extends State<PinEntryScreen> {
  String enteredPin = ""; // Replace with dynamic logic if needed

  void _onDigitPressed(String digit) {
    if (enteredPin.length < 6) {
      setState(() => enteredPin += digit);
    }
  }

  void _onBackspacePressed() {
    if (enteredPin.isNotEmpty) {
      setState(() {
        enteredPin = enteredPin.substring(0, enteredPin.length - 1);
      });
    }
  }

  void _submitPin() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPin =
        prefs.getString('parentPin') ?? '1234'; // Default if not set

    if (enteredPin == savedPin) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => ProfileSettingsScreen()),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Incorrect PIN")));
      setState(() => enteredPin = "");
    }
  }

  Widget _buildPinDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(6, (index) {
        bool filled = index < enteredPin.length;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: filled ? Colors.black : Colors.grey[300],
          ),
        );
      }),
    );
  }

  Widget _buildNumberButton(String number, {String? letters}) {
    return GestureDetector(
      onTap: () => _onDigitPressed(number),
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFFF0F0F0),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                number,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              if (letters != null)
                Text(
                  letters,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey[700],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          OutlinedButton(
            onPressed: () => Navigator.pop(context), // Cancel = go back
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.black),
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(
              "Cancel",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _submitPin,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF6A4BBC),
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(
              "Done",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackspaceButton() {
    return GestureDetector(
      onTap: _onBackspacePressed,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFFF0F0F0),
        ),
        child: Icon(Icons.backspace, size: 28, color: Colors.black),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 100),
            Text(
              "Enter Parent PIN",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            _buildPinDots(),
            SizedBox(height: 40),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildNumberButton("1", letters: " "),
                    _buildNumberButton("2", letters: "ABC"),
                    _buildNumberButton("3", letters: "DEF"),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildNumberButton("4", letters: "GHI"),
                    _buildNumberButton("5", letters: "JKL"),
                    _buildNumberButton("6", letters: "MNO"),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildNumberButton("7", letters: "PQRS"),
                    _buildNumberButton("8", letters: "TUV"),
                    _buildNumberButton("9", letters: "WXYZ"),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(width: 80), // Empty space to balance layout
                    _buildNumberButton("0"),
                    _buildBackspaceButton(),
                  ],
                ),
                SizedBox(height: 32),
                _buildActionButtons(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
