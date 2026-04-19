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
    User user = User(
      fullName: nameController.text,
      email: emailController.text,
      studentId: studentIdController.text,
      password: passwordController.text,
      gender: selectedGender,
      academicLevel: selectedLevel,
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
              ElevatedButton(onPressed: signup, child: Text("Signup")),

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
