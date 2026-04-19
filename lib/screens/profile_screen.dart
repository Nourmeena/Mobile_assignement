import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io'; 
import 'package:flutter/foundation.dart';
import '../database/db_helper.dart';
import '../models/user_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // state variables
  File? _image;           // for mobile
  Uint8List? _webImage;   // for web
  
  // Controllers
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
    UserModel? user = await _dbHelper.getUser();
    if (user != null) {
      setState(() {
        _nameController.text = user.fullName;
        _idController.text = user.studentId;
        _emailController.text = user.email;
        
        if (user.profileImage != null && !kIsWeb) {
          _image = File(user.profileImage!);
          // تصفير الكاش عشان الصورة الجديدة تظهر لو المسار متكرر
          FileImage(_image!).evict(); 
        }
      });
    }
  }

  // حفظ البيانات (متوافق مع الهيلبر المعدل)
  Future<void> _saveProfile() async {
    UserModel user = UserModel(
      fullName: _nameController.text,
      studentId: _idController.text,
      email: _emailController.text,
      profileImage: _image?.path, 
    );

    await _dbHelper.saveUser(user);
    
    // إعادة تحميل البيانات فوراً لتحديث الشاشة والصورة
    await _loadUserData();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profile Updated Successfully!'),
          backgroundColor: Colors.green,
        ),
      );
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
                    }),
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
        });
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
            onPressed: () => Navigator.pop(context)
          )
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
                        : (_image != null ? FileImage(_image!) : null) as ImageProvider?,
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
                        icon: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                        onPressed: () => _showPicker(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 35),
            
            buildProfileField("Full Name", _nameController, Icons.person_outline),
            buildProfileField("Student ID", _idController, Icons.badge_outlined),
            buildProfileField("University Email", _emailController, Icons.email_outlined),
            
            const SizedBox(height: 30),
            
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                ),
                onPressed: _saveProfile,
                child: const Text(
                  'Save Changes', 
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildProfileField(String label, TextEditingController controller, IconData icon) {
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