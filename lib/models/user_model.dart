class UserModel {
  int? id;
  String fullName;
  String studentId;
  String email;
  String? password;
  String? gender;
  String? academicLevel;
  String? profileImage;

  UserModel({
    this.id,
    required this.fullName,
    required this.studentId,
    required this.email,
    this.password,
    this.gender,
    this.academicLevel,
    this.profileImage,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'studentId': studentId,
      'email': email,
      'password': password,
      'gender': gender,
      'academicLevel': academicLevel,
      'profileImage': profileImage,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      fullName: map['fullName'] ?? '',
      studentId: map['studentId'] ?? '',
      email: map['email'] ?? '',
      password: map['password'],
      gender: map['gender'],
      academicLevel: map['academicLevel'],
      profileImage: map['profileImage'],
    );
  }
}
