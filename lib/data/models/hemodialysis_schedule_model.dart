class CreateHemodialysisScheduleDTO {
  final String scheduleDate;

  CreateHemodialysisScheduleDTO({
    required this.scheduleDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'schedule_date': scheduleDate,
    };
  }
}

class UpdateHemodialysisScheduleDTO {
  final String scheduleDate;
  final bool isActive; // Sekarang optional dengan default true

  UpdateHemodialysisScheduleDTO({
    required this.scheduleDate,
    this.isActive = true, // DEFAULT VALUE
  });

  Map<String, dynamic> toJson() {
    return {
      'schedule_date': scheduleDate,
      'is_active': isActive,
    };
  }
}

class HemodialysisScheduleResponseDTO {
  final int id;
  final int userId;
  final String scheduleDate;
  final bool isActive;

  HemodialysisScheduleResponseDTO({
    required this.id,
    required this.userId,
    required this.scheduleDate,
    required this.isActive,
  });

  factory HemodialysisScheduleResponseDTO.fromJson(Map<String, dynamic> json) {
    return HemodialysisScheduleResponseDTO(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      scheduleDate: json['schedule_date'] as String,
      isActive: json['is_active'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'schedule_date': scheduleDate,
      'is_active': isActive,
    };
  }
}