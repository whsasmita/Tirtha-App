class CreateDrugScheduleDTO {
  final String drugName;
  final String dose;
  final String scheduleDate;
  final bool at06;
  final bool at12;
  final bool at18;

  CreateDrugScheduleDTO({
    required this.drugName,
    required this.dose,
    required this.scheduleDate,
    required this.at06,
    required this.at12,
    required this.at18,
  });

  Map<String, dynamic> toJson() {
    return {
      'drug_name': drugName,
      'dose': dose,
      'schedule_date': scheduleDate,
      'at_06': at06,
      'at_12': at12,
      'at_18': at18,
    };
  }
}

class UpdateDrugScheduleDTO {
  final String drugName;
  final String dose;
  final String scheduleDate;
  final bool at06;
  final bool at12;
  final bool at18;
  final bool isActive;

  UpdateDrugScheduleDTO({
    required this.drugName,
    required this.dose,
    required this.scheduleDate,
    required this.at06,
    required this.at12,
    required this.at18,
    required this.isActive,
  });

  Map<String, dynamic> toJson() {
    return {
      'drug_name': drugName,
      'dose': dose,
      'schedule_date': scheduleDate,
      'at_06': at06,
      'at_12': at12,
      'at_18': at18,
      'is_active': isActive,
    };
  }
}

class DrugScheduleResponseDTO {
  final int id;
  final int userId;
  final String drugName;
  final String dose;
  final String scheduleDate;
  final bool at06;
  final bool at12;
  final bool at18;
  final bool isActive;

  DrugScheduleResponseDTO({
    required this.id,
    required this.userId,
    required this.drugName,
    required this.dose,
    required this.scheduleDate,
    required this.at06,
    required this.at12,
    required this.at18,
    required this.isActive,
  });

  factory DrugScheduleResponseDTO.fromJson(Map<String, dynamic> json) {
    return DrugScheduleResponseDTO(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      drugName: json['drug_name'] as String,
      dose: json['dose'] as String,
      scheduleDate: json['schedule_date'] as String,
      at06: json['at_06'] as bool,
      at12: json['at_12'] as bool,
      at18: json['at_18'] as bool,
      isActive: json['is_active'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'drug_name': drugName,
      'dose': dose,
      'schedule_date': scheduleDate,
      'at_06': at06,
      'at_12': at12,
      'at_18': at18,
      'is_active': isActive,
    };
  }
}
