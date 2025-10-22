class Complaint {
  final String? id;
  final int? userId;
  final List<String> complaints; 
  final String? message;
  final DateTime? createdAt;

  Complaint({
    this.id,
    this.userId,
    required this.complaints,
    this.message,
    this.createdAt,
  });
  
  factory Complaint.fromJson(Map<String, dynamic> json) {
    // Backend menggunakan PascalCase, jadi kita harus sesuaikan
    final List<dynamic> complaintListDynamic = json['Complaints'] ?? json['complaints'] ?? [];

    return Complaint(
      id: json['ID']?.toString() ?? json['id']?.toString(),
      userId: json['UserID'] as int?,
      complaints: complaintListDynamic.map((e) => e.toString()).toList(),
      message: json['Message'] as String? ?? json['message'] as String?,
      createdAt: json['CreatedAt'] != null 
          ? DateTime.parse(json['CreatedAt'] as String)
          : null,
    );
  }

  // Untuk create complaint (tanpa id dan message)
  Map<String, dynamic> toCreateJson() {
    return {
      'complaints': complaints, // lowercase untuk request
    };
  }

  // Untuk kebutuhan lain jika perlu
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'complaints': complaints,
      'message': message,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}