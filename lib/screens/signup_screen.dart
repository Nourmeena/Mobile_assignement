import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final AuthService _authService = AuthService();

  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController studentIdController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  String? selectedGender;
  int? selectedLevel;

  String message = "";

  void signup() async {
    UserModel user = UserModel(
      fullName: nameController.text.trim(),
      email: emailController.text.trim(),
      studentId: studentIdController.text.trim(),
      password: passwordController.text.trim(),
      gender: selectedGender,
      academicLevel: selectedLevel?.toString(),
    );

    String result = await _authService.signup(
      user,
      confirmPasswordController.text,
    );

    setState(() {
      message = result;
    });

    if (result == "Signup Success") {
      Navigator.pop(context); // go back to login
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Signup")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 50), // Spacing from the top
              Text(
                'Student Task Manager',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[300], // Baby Blue
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
              const SizedBox(
                height: 40,
              ), 
              // full Name
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(labelText: "Full Name"),
              ),

              // email
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(labelText: "University Email"),
              ),

              // student ID
              TextFormField(
                controller: studentIdController,
                decoration: InputDecoration(labelText: "Student ID"),
              ),

              // password
              TextFormField(
                controller: passwordController,
                decoration: InputDecoration(labelText: "Password"),
                obscureText: true,
              ),

              // confirm password
              TextFormField(
                controller: confirmPasswordController,
                decoration: InputDecoration(labelText: "Confirm Password"),
                obscureText: true,
              ),

              SizedBox(height: 10),

              // gender
              Row(
                children: [
                  Text("Gender: "),
                  Radio<String>(
                    value: "Male",
                    groupValue: selectedGender,
                    onChanged: (value) {
                      setState(() {
                        selectedGender = value;
                      });
                    },
                  ),
                  Text("Male"),
                  Radio<String>(
                    value: "Female",
                    groupValue: selectedGender,
                    onChanged: (value) {
                      setState(() {
                        selectedGender = value;
                      });
                    },
                  ),
                  Text("Female"),
                ],
              ),

              // academic Level Dropdown
              DropdownButtonFormField<int>(
                initialValue: selectedLevel,
                hint: Text("Select Academic Level"),
                items: [1, 2, 3, 4].map((level) {
                  return DropdownMenuItem(
                    value: level,
                    child: Text(level.toString()),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedLevel = value;
                  });
                },
              ),

              SizedBox(height: 20),

              // signup Button
              ElevatedButton(onPressed: signup, child: Text("Signup"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF89CFF0), 
                  foregroundColor: Colors.white, 
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15), 
                  ),
                  elevation: 5,
                  shadowColor: const Color(
                    0xFFF2B1D8,
                  ).withOpacity(0.5), 
                ),
              ),

              

              SizedBox(height: 10),

              // message
              Text(message, style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ),
    );
  }
}
