import 'package:flutter/material.dart';
import 'package:playlistkids/profileSelection.dart';
import 'package:firebase_auth/firebase_auth.dart';


class KidsLoginPage extends StatefulWidget {
  @override
  _KidsLoginPageState createState() => _KidsLoginPageState();
}

class _KidsLoginPageState extends State<KidsLoginPage> {
  bool _isPasswordVisible = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final containerWidth = screenWidth * 0.8;

    return Scaffold(
      backgroundColor: Color(0xFFF2F2F2),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Sign In Title
              Container(
                width: containerWidth,
                alignment: Alignment.centerLeft,
                child: Text(
                  "Sign In",
                  style: TextStyle(
                    fontSize: screenWidth * 0.1,
                    fontFamily: "Lora",
                    fontWeight: FontWeight.normal,
                    color: Colors.black,
                  ),
                ),
              ),

              SizedBox(height: screenHeight * 0.05),

              // Email Field
              Container(
                width: containerWidth,
                alignment: Alignment.centerLeft,
                child: Text(
                  'Email Address',
                  style: TextStyle(
                    fontFamily: "YouTube",
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ),
              SizedBox(height: 8),
              Container(
                width: containerWidth,
                child: TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.zero, // Sharp corners
                      borderSide: BorderSide(
                        color: Colors.grey, // Border color
                        width: 1.0, // Border width
                      ),
                    ),
                    contentPadding: EdgeInsets.all(16),
                    hintText: 'Enter your email',
                  ),
                  style: TextStyle(fontFamily: "YouTube"),
                  keyboardType: TextInputType.emailAddress,
                ),
              ),

              SizedBox(height: 16),

              // Password Field
              Container(
                width: containerWidth,
                alignment: Alignment.centerLeft,
                child: Text(
                  'Password',
                  style: TextStyle(
                    fontFamily: "YouTube",
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ),
              SizedBox(height: 8),
              Container(
                width: containerWidth,
                child: TextField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.zero, // Sharp corners
                      borderSide: BorderSide(
                        color: Colors.grey, // Border color
                        width: 1.0, // Border width
                      ),
                    ),
                    contentPadding: EdgeInsets.all(16),
                    hintText: 'Enter your password',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                  style: TextStyle(fontFamily: "YouTube"),
                ),
              ),

              // Forgot Password
              Container(
                width: containerWidth,
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // Handle forgot password
                  },
                  child: Text(
                    "Forgot Password?",
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      color: Color(0xFF4B3174),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 30),

              // Sign In Button
              Container(
                width: containerWidth,
                child: ElevatedButton(
                  onPressed: () async {
                    final email = _emailController.text.trim();
                    final password = _passwordController.text.trim();

                    try {
                      final credential = await FirebaseAuth.instance
                          .signInWithEmailAndPassword(email: email, password: password);

                      // ✅ Navigate only on success
                      if (credential.user != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => profileSelection()),
                        );
                      }
                    } on FirebaseAuthException catch (e) {
                      // 🔥 Show specific error
                      String errorMsg = "An error occurred. Please try again.";
                      if (e.code == 'user-not-found') {
                        errorMsg = "No user found for that email.";
                      } else if (e.code == 'wrong-password') {
                        errorMsg = "Wrong password. Try again.";
                      }

                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text("Login Failed"),
                          content: Text(errorMsg),
                          actions: [
                            TextButton(
                              child: Text("OK"),
                              onPressed: () => Navigator.pop(context),
                            )
                          ],
                        ),
                      );
                    }
                  },

                  child: Text(
                    "Sign In",
                    style: TextStyle(
                      fontSize: screenWidth * 0.05,
                      fontFamily: "YouTube",
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF795DA8),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.zero, // Sharp corners for button
                    ),
                  ),
                ),
              ),
              SizedBox(height: 30),
              Container(
                width: containerWidth,
                alignment: Alignment.centerLeft,
                child: Text(
                  'Sign In using:',
                  style: TextStyle(
                    fontFamily: "YouTube",
                    fontSize: 12,
                    color: Color(0xFF343635),
                  ),
                ),
              ),
              SizedBox(height: 10),
// Apple Button
              Container(
                width: containerWidth,
                height: 60, // Fixed height
                child: ElevatedButton(
                  onPressed: () {},
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/appleicon.png',
                        width: 24, // Standardized size
                        height: 24,
                      ),
                      SizedBox(width: 12),
                      Text(
                        "Continue with Apple",
                        style: TextStyle(
                          fontSize: screenWidth *
                              0.045, // Slightly reduced for consistency
                          fontFamily: "YouTube",
                        ),
                      ),
                    ],
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF1A1A1A),
                    foregroundColor: Colors.white,
                    minimumSize:
                        Size(double.infinity, 60), // Ensure full width/height
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),

// Google Button
              Container(
                width: containerWidth,
                height: 60, // Same fixed height
                child: ElevatedButton(
                  onPressed: () {},
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/googleicon1.png',
                        width: 24, // Same size as Apple icon
                        height: 24,
                      ),
                      SizedBox(width: 12),
                      Text(
                        "Continue with Google",
                        style: TextStyle(
                          fontSize: screenWidth * 0.045, // Same as Apple button
                          fontFamily: "YouTube",
                        ),
                      ),
                    ],
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF1A1A1A),
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 60), // Identical sizing
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
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
