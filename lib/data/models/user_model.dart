class UserModel {
  final int id;
  final String? name;
  final String? email;
  final String? password;         // Ditambahkan
  final String? profilePicture;   // Ditambahkan
  final String? phone_number;
  final String? role;

  UserModel({
    required this.id,
    this.name,
    this.email,
    this.password,                // Ditambahkan
    this.profilePicture,          // Ditambahkan
    this.phone_number,
    this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      name: json['name'] as String?,
      email: json['email'] as String?,
      password: json['password'] as String?, // Dipetakan dari JSON
      profilePicture: json['profile_picture'] as String?, // Dipetakan dari JSON
      phone_number: json['phone_number'] as String?,
      role: json['role'] as String?,
    );
  }

  // Opsional: Menambahkan metode toJson untuk mengirim data kembali ke API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'profile_picture': profilePicture,
      'phone_number': phone_number,
      'role': role,
    };
  }
}