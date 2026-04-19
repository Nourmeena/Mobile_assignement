class User {
  int? id;
  String fullName;
  String email;
  String studentId;
  String password;
  String? gender;
  int? academicLevel;
  String? imagePath;

  User({
    this.id,
    required this.fullName,
    required this.email,
    required this.studentId,
    required this.password,
    this.gender,
    this.academicLevel,
    this.imagePath,
  });

  // from object to Map to store in database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'studentId': studentId,
      'password': password,
      'gender': gender,
      'academicLevel': academicLevel,
      'imagePath': imagePath,
    };
  }

  // from Map to object when reading from database
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      fullName: map['fullName'],
      email: map['email'],
      studentId: map['studentId'],
      password: map['password'],
      gender: map['gender'],
      academicLevel: map['academicLevel'],
      imagePath: map['imagePath'],
    );
  }
}
