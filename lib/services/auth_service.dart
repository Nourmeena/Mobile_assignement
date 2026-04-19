import '../models/user_model.dart';
import '../database/db_helper.dart';

class AuthService {
  final DBHelper _db = DBHelper();

  // signup
  Future<String> signup(UserModel user, String confirmPassword) async {
    final password = user.password;
    if (user.fullName.isEmpty ||
        user.email.isEmpty ||
        user.studentId.isEmpty ||
        password == null ||
        password.isEmpty) {
      return "Please fill all required fields";
    }

    RegExp emailRandegex = RegExp(r'^\d+@stud\.fci-cu\.edu\.eg$');

    if (!emailRandegex.hasMatch(user.email)) {
      return "Invalid university email format";
    }

    String emailId = user.email.split('@')[0];
    if (emailId != user.studentId) {
      return "Student ID does not match email";
    }

    if (password.length < 8) {
      return "Password must be at least 8 characters";
    }

    if (!password.contains(RegExp(r'\d'))) {
      return "Password must contain at least one number";
    }

    if (password != confirmPassword) {
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
  Future<UserModel?> login(String email, String password) async {
    final user = await _db.getUserByEmail(email);

    if (user == null) {
      return null;
    }

    if (user.password != password) {
      return null;
    }

    return user;
  }
}
