class CreateControlScheduleDTO {
  final String controlDate;

  CreateControlScheduleDTO({
    required this.controlDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'control_date': controlDate,
      // is_active default true di backend
    };
  }
}

class UpdateControlScheduleDTO {
  final String controlDate;
  final bool isActive;

  UpdateControlScheduleDTO({
    required this.controlDate,
    this.isActive = true, // DEFAULT TRUE
  });

  Map<String, dynamic> toJson() {
    return {
      'control_date': controlDate,
      'is_active': isActive, // KIRIM KE API
    };
  }
}

class ControlScheduleResponseDTO {
  final int id;
  final int userId;
  final String controlDate;
  final bool isActive;

  ControlScheduleResponseDTO({
    required this.id,
    required this.userId,
    required this.controlDate,
    required this.isActive,
  });

  factory ControlScheduleResponseDTO.fromJson(Map<String, dynamic> json) {
    return ControlScheduleResponseDTO(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      controlDate: json['control_date'] as String,
      isActive: json['is_active'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'control_date': controlDate,
      'is_active': isActive,
    };
  }
}