// =========================================================
// MODEL INTERNAl: MedicationRefillSchedule (CamelCase, menggunakan DateTime)
// =========================================================
class MedicationRefillSchedule {
  final int id;
  final int userId;
  final DateTime refillDate; 
  final bool isActive;
  final bool notificationSent;
  final DateTime createdAt;
  final DateTime updatedAt;

  MedicationRefillSchedule({
    required this.id,
    required this.userId,
    required this.refillDate,
    required this.isActive,
    required this.notificationSent,
    required this.createdAt,
    required this.updatedAt,
  });

  // 🔥 PERBAIKAN: Menambahkan Null Check (as bool? ?? false)
  factory MedicationRefillSchedule.fromJson(Map<String, dynamic> json) {
    return MedicationRefillSchedule(
      id: json['ID'] as int,
      userId: json['UserID'] as int,
      refillDate: DateTime.parse(json['RefillDate']), 
      isActive: json['IsActive'] as bool? ?? false, // Default false jika null
      notificationSent: json['NotificationSent'] as bool? ?? false, // Default false jika null
      createdAt: DateTime.parse(json['CreatedAt']),
      updatedAt: DateTime.parse(json['UpdatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'UserID': userId,
      'RefillDate': refillDate.toIso8601String(), 
      'IsActive': isActive,
      'NotificationSent': notificationSent,
      'CreatedAt': createdAt.toIso8601String(),
      'UpdatedAt': updatedAt.toIso8601String(),
    };
  }
}

// =========================================================
// DTO REQUEST
// =========================================================
class CreateMedicationRefillDTO {
  final String refillDate; // Format 'YYYY-MM-DD'

  CreateMedicationRefillDTO({required this.refillDate});

  Map<String, dynamic> toJson() {
    return {
      'refill_date': refillDate,
    };
  }
}

class UpdateMedicationRefillDTO {
  final String? refillDate; // Format 'YYYY-MM-DD'
  final bool? isActive;

  UpdateMedicationRefillDTO({
    this.refillDate,
    this.isActive,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (refillDate != null) {
      data['refill_date'] = refillDate;
    }
    if (isActive != null) {
      data['is_active'] = isActive;
    }
    return data;
  }
}

// =========================================================
// DTO RESPONSE API: MedicationRefillResponseDTO (snake_case, menggunakan String)
// =========================================================
class MedicationRefillResponseDTO {
  final int id;
  final int userId;
  final String refillDate; // Biarkan sebagai String (YYYY-MM-DD)
  final bool isActive;
  final bool notificationSent;
  final String createdAt;
  final String updatedAt;

  MedicationRefillResponseDTO({
    required this.id,
    required this.userId,
    required this.refillDate,
    required this.isActive,
    required this.notificationSent,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MedicationRefillResponseDTO.fromJson(Map<String, dynamic> json) {
    return MedicationRefillResponseDTO(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      refillDate: json['refill_date'] as String,
      isActive: json['is_active'] as bool? ?? true,
      notificationSent: json['notification_sent'] as bool?
          ?? json['NotificationSent'] as bool?
          ?? false, // Default false jika null

      // 🔥 PERBAIKAN: Menggunakan Null Check untuk String
      createdAt: json['created_at'] as String? ?? json['CreatedAt'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? json['UpdatedAt'] as String? ?? '',
    );
  }
}