import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChangePinScreen extends StatefulWidget {
  @override
  _ChangePinScreenState createState() => _ChangePinScreenState();
}

class _ChangePinScreenState extends State<ChangePinScreen> {
  final _pinController = TextEditingController();
  final _confirmController = TextEditingController();

  Future<void> _saveNewPin() async {
    final newPin = _pinController.text;
    final confirmPin = _confirmController.text;

    if (newPin.length < 4 || newPin.length > 6) {
      _showMessage('PIN must be between 4 and 6 digits');
      return;
    }

    if (newPin != confirmPin) {
      _showMessage('PINs do not match');
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('parentPin', newPin);

    _showMessage('PIN updated!');
    Navigator.pop(context);
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: BackButton(color: Colors.white),
        title: Text("Change PIN",style: TextStyle(color: Colors.white, fontFamily: "YouTube"),),
        backgroundColor: Color(0xFF6A4BBC),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(
              controller: _pinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 6,
              decoration: InputDecoration(
                labelText: 'Enter new PIN',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _confirmController,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 6,
              decoration: InputDecoration(
                labelText: 'Confirm new PIN',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveNewPin,
              child: Text("Save PIN",style: TextStyle(color: Colors.white,fontFamily: "YouTube",fontSize: 18),),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF6A4BBC),
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 40),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
