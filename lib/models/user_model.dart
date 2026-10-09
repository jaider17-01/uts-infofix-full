class UserModel {
  final String id;
  final String fullName;
  final String studentCode;
  final String email;
  final String program;
  final String password;
  final bool isTechnician;
  final bool isAdmin;

  UserModel({
    required this.id,
    required this.fullName,
    required this.studentCode,
    required this.email,
    required this.program,
    required this.password,
    this.isTechnician = false,
    this.isAdmin = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'studentCode': studentCode,
      'email': email,
      'program': program,
      'password': password,
      'isTechnician': isTechnician,
      'isAdmin': isAdmin,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    // Handle both boolean (from Firestore) and integer (from local storage)
    final isTech = map['isTechnician'];
    final isAdm = map['isAdmin'];
    
    return UserModel(
      id: map['id'] ?? '',
      fullName: map['fullName'] ?? '',
      studentCode: map['studentCode'] ?? '',
      email: map['email'] ?? '',
      program: map['program'] ?? '',
      password: map['password'] ?? '',
      isTechnician: isTech is bool ? isTech : (isTech == 1),
      isAdmin: isAdm is bool ? isAdm : (isAdm == 1),
    );
  }
}

