// DTO untuk CREATE
class CreateHemodialysisMonitoringDTO {
  final String bpBefore;
  final String bpAfter;
  final double weightBefore;
  final double weightAfter;

  CreateHemodialysisMonitoringDTO({
    required this.bpBefore,
    required this.bpAfter,
    required this.weightBefore,
    required this.weightAfter,
  });

  Map<String, dynamic> toJson() {
    return {
      'bp_before': bpBefore,
      'bp_after': bpAfter,
      'weight_before': weightBefore,
      'weight_after': weightAfter,
    };
  }
}

// DTO untuk UPDATE
class UpdateHemodialysisMonitoringDTO {
  final String bpBefore;
  final String bpAfter;
  final double weightBefore;
  final double weightAfter;

  UpdateHemodialysisMonitoringDTO({
    required this.bpBefore,
    required this.bpAfter,
    required this.weightBefore,
    required this.weightAfter,
  });

  Map<String, dynamic> toJson() {
    return {
      'bp_before': bpBefore,
      'bp_after': bpAfter,
      'weight_before': weightBefore,
      'weight_after': weightAfter,
    };
  }
}

// Model untuk item monitoring (data dari response)
class HemodialysisMonitoringItem {
  final int id;
  final int userId;
  final String monitoringDate;
  final String bpBefore;
  final String bpAfter;
  final double weightBefore;
  final double weightAfter;

  HemodialysisMonitoringItem({
    required this.id,
    required this.userId,
    required this.monitoringDate,
    required this.bpBefore,
    required this.bpAfter,
    required this.weightBefore,
    required this.weightAfter,
  });

  factory HemodialysisMonitoringItem.fromJson(Map<String, dynamic> json) {
    return HemodialysisMonitoringItem(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      monitoringDate: json['monitoring_date'] as String,
      bpBefore: json['bp_before'] as String,
      bpAfter: json['bp_after'] as String,
      weightBefore: (json['weight_before'] is int)
          ? (json['weight_before'] as int).toDouble()
          : json['weight_before'] as double,
      weightAfter: (json['weight_after'] is int)
          ? (json['weight_after'] as int).toDouble()
          : json['weight_after'] as double,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'monitoring_date': monitoringDate,
      'bp_before': bpBefore,
      'bp_after': bpAfter,
      'weight_before': weightBefore,
      'weight_after': weightAfter,
    };
  }
}

// Model untuk response lengkap (wrapper)
class HemodialysisMonitoringResponse {
  final List<HemodialysisMonitoringItem> data;
  final String message;
  final String status;

  HemodialysisMonitoringResponse({
    required this.data,
    required this.message,
    required this.status,
  });

  factory HemodialysisMonitoringResponse.fromJson(Map<String, dynamic> json) {
    return HemodialysisMonitoringResponse(
      data: (json['data'] as List)
          .map((item) => HemodialysisMonitoringItem.fromJson(
                Map<String, dynamic>.from(item),
              ))
          .toList(),
      message: json['message'] as String,
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.map((item) => item.toJson()).toList(),
      'message': message,
      'status': status,
    };
  }
}