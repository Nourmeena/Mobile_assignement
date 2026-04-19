class UserModel {
  int? id;
  String fullName;
  String studentId;
  String email;
  String? profileImage;

  UserModel({
    this.id,
    required this.fullName,
    required this.studentId,
    required this.email,
    this.profileImage,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'studentId': studentId,
      'email': email,
      'profileImage': profileImage,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      fullName: map['fullName'],
      studentId: map['studentId'],
      email: map['email'],
      profileImage: map['profileImage'],
    );
  }
}