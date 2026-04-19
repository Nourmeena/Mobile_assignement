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
    String result = await _authService.login(
      emailController.text,
      passwordController.text,
    );

    setState(() {
      message = result;
    });

    if (result == "Login Success") {
      Navigator.pushReplacementNamed(context, '/home');
    }
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
            ElevatedButton(onPressed: login, child: Text("Login")),

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
