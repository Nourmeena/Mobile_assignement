import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io'; 
import 'package:flutter/foundation.dart'; //


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // state variables
  File? _image;           // for mobile
  Uint8List? _webImage;   // for web
  
  final _nameController = TextEditingController(text: "Fatimah Atif");
  final _idController = TextEditingController(text: "20201234");
  final _emailController = TextEditingController(text: "20201234@stud.fci-cu.edu.eg");
  
  final ImagePicker _picker = ImagePicker();
  //for picking images from gallery or camera
  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      
      if (pickedFile != null) {
        // for web, we need to read as bytes; for mobile, we can use the file path
        var f = await pickedFile.readAsBytes();
        
        setState(() {
          _webImage = f; // save for web
          
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
            
            //data fields
            buildProfileField("Full Name", _nameController, Icons.person_outline),
            buildProfileField("Student ID", _idController, Icons.badge_outlined),
            buildProfileField("University Email", _emailController, Icons.email_outlined),
            
            const SizedBox(height: 30),
            
            //save button 
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Profile Updated: ${_nameController.text}'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
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