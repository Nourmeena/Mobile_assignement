import '../models/user_model.dart';
import 'database_service.dart';

class AuthService {
  final DatabaseService _db = DatabaseService();

  // signup
  Future<String> signup(User user, String confirmPassword) async {
    if (user.fullName.isEmpty ||
        user.email.isEmpty ||
        user.studentId.isEmpty ||
        user.password.isEmpty) {
      return "Please fill all required fields";
    }

    RegExp emailRegex = RegExp(r'^\d+@stud\.fci-cu\.edu\.eg$');

    if (!emailRegex.hasMatch(user.email)) {
      return "Invalid university email format";
    }

    String emailId = user.email.split('@')[0];
    if (emailId != user.studentId) {
      return "Student ID does not match email";
    }

    if (user.password.length < 8) {
      return "Password must be at least 8 characters";
    }

    if (!user.password.contains(RegExp(r'\d'))) {
      return "Password must contain at least one number";
    }

    if (user.password != confirmPassword) {
      return "Passwords do not match";
    }

    final existingUser = await _db.getUserByEmail(user.email);
    if (existingUser != null) {
      return "User already exists";
    }

    await _db.insertUser(user);

    return "Signup Success";
  }

  // login
  Future<String> login(String email, String password) async {
    final user = await _db.getUserByEmail(email);

    if (user == null) {
      return "User not found";
    }

    if (user.password != password) {
      return "Incorrect password";
    }

    return "Login Success";
  }
}
