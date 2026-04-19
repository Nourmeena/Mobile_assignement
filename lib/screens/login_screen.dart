import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String message = "";

  void login() async {
    final user = await _authService.login(
      emailController.text,
      passwordController.text,
    );

    if (user == null) {
      setState(() {
        message = "Invalid email or password";
      });
      return;
    }

    Navigator.pushReplacementNamed(context, '/home', arguments: user.id);
  }

  void goToSignup() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => SignupScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 50), // Spacing from the top
            Text(
              'Student Task Manager',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.blue[300],
                letterSpacing: 1.2,
                shadows: [
                  Shadow(
                    blurRadius: 10.0,
                    color: Colors.pink[100]!,
                    offset: const Offset(2.0, 2.0),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Organize your academic life',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 40), // Spacing before the first input field
            // email
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: "Email"),
            ),

            // password
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: "Password"),
              obscureText: true,
            ),

            SizedBox(height: 20),

            // login Button
            ElevatedButton(
              onPressed: login,
              child: Text("Login"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF89CFF0),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 5,
                shadowColor: const Color(0xFFF2B1D8).withOpacity(0.5),
              ),
            ),

            SizedBox(height: 10),

            // message
            Text(message, style: TextStyle(color: Colors.red)),

            SizedBox(height: 20),

            // Go to Signup
            TextButton(
              onPressed: goToSignup,
              child: Text("Don't have an account? Signup"),
            ),
          ],
        ),
      ),
    );
  }
}
