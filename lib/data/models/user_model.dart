class UserModel {
  final int id;
  final String? name;
  final String? email;
  final String? phone_number;
  final String? role;

  UserModel({
    required this.id,
    this.name,
    this.email,
    this.phone_number,
    this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      name: json['name'] as String?,
      email: json['email'] as String?,
      phone_number: json['phone_number'] as String?,
      role: json['role'] as String?,
    );
  }
}