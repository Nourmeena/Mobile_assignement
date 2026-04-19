import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../database/db_helper.dart';
import '../models/user_model.dart';

class ProfileScreen extends StatefulWidget {
  final int userId;
  const ProfileScreen({super.key, required this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // state variables
  int? _userId;
  File? _image; // for mobile
  Uint8List? _webImage; // for web
  String? _selectedLevel;

  // Controllers

  final List<String> _levels = ['Level 1', 'Level 2', 'Level 3', 'Level 4'];
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  final DBHelper _dbHelper = DBHelper();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // جلب البيانات من الداتابيز وعرضها
  Future<void> _loadUserData() async {
    UserModel? user = await _dbHelper.getUser(widget.userId);
    if (user != null) {
      setState(() {
        _userId = user.id;
        _nameController.text = user.fullName;
        _idController.text = user.studentId;
        _emailController.text = user.email;
        _selectedLevel = user.academicLevel;

        if (user.profileImage != null && !kIsWeb) {
          _image = File(user.profileImage!);
          // تصفير الكاش عشان الصورة الجديدة تظهر لو المسار متكرر
          FileImage(_image!).evict();
        }
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // حفظ البيانات (متوافق مع الهيلبر المعدل)
  Future<void> _saveProfile() async {
    String email = _emailController.text.trim();
    String studentId = _idController.text.trim();

    if (!email.endsWith('@stud.fci-cu.edu.eg')) {
      _showError('Use a valid university email (@stud.fci-cu.edu.eg)');
      return;
    }

    String idFromEmail = email.split('@')[0];
    if (idFromEmail != studentId) {
      _showError('Student ID does not match the University Email!');
      return;
    }

    // fetch the current user first to preserve the password and other data

    UserModel? currentUser = await _dbHelper.getUser(widget.userId);

    if (currentUser != null) {
      UserModel updatedUser = UserModel(
        id: widget.userId,
        fullName: _nameController.text.trim(),
        studentId: studentId,
        email: email,
        password: currentUser.password,
        gender: currentUser.gender,
        academicLevel: _selectedLevel,
        profileImage: _image?.path ?? currentUser.profileImage,
      );

      await _dbHelper.saveUser(updatedUser);

      // إعادة تحميل البيانات فوراً لتحديث الشاشة والصورة
      await _loadUserData();

      if (mounted) {
        _showSuccess('Profile Updated Successfully!');
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);

      if (pickedFile != null) {
        Uint8List bytes = await pickedFile.readAsBytes();

        setState(() {
          _webImage = bytes;
          if (!kIsWeb) {
            _image = File(pickedFile.path);
          }
        });
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 65,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: _webImage != null
                        ? MemoryImage(_webImage!)
                        : (_image != null ? FileImage(_image!) : null)
                              as ImageProvider?,
                    child: (_webImage == null && _image == null)
                        ? const Icon(Icons.person, size: 65, color: Colors.grey)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      backgroundColor: Colors.blueAccent,
                      radius: 22,
                      child: IconButton(
                        icon: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: () => _showPicker(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 35),

            buildProfileField(
              "Full Name",
              _nameController,
              Icons.person_outline,
            ),
            buildProfileField(
              "Student ID",
              _idController,
              Icons.badge_outlined,
            ),
            buildProfileField(
              "University Email",
              _emailController,
              Icons.email_outlined,
            ),
            // Add this below your University Email field
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: DropdownButtonFormField<String>(
                value: _levels.contains(_selectedLevel) ? _selectedLevel : null,
                decoration: InputDecoration(
                  labelText: "Academic Level",
                  prefixIcon: const Icon(
                    Icons.school_outlined,
                    color: Colors.blueAccent,
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Colors.grey[200]!),
                  ),
                ),
                items: _levels.map((String level) {
                  return DropdownMenuItem(value: level, child: Text(level));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedLevel = value;
                  });
                },
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: _saveProfile,
                child: const Text(
                  'Save Changes',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildProfileField(
    String label,
    TextEditingController controller,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.blueAccent),
          filled: true,
          fillColor: Colors.grey[50],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.grey[200]!),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _idController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}
