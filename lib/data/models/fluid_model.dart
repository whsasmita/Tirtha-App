class CreateOrUpdateFluidLogDTO {
  final int intakeCC;
  final int outputCC;

  CreateOrUpdateFluidLogDTO({
    required this.intakeCC,
    required this.outputCC,
  });

  Map<String, dynamic> toJson() {
    return {
      'intake_cc': intakeCC,
      'output_cc': outputCC,
    };
  }

  factory CreateOrUpdateFluidLogDTO.fromJson(Map<String, dynamic> json) {
    return CreateOrUpdateFluidLogDTO(
      intakeCC: json['intake_cc'] as int,
      outputCC: json['output_cc'] as int,
    );
  }
}

class FluidBalanceLogResponseDTO {
  final int id;
  final int userId;
  final String logDate;
  final int intakeCC;
  final int outputCC;
  final int balanceCC;
  final String? warningMessage;

  FluidBalanceLogResponseDTO({
    required this.id,
    required this.userId,
    required this.logDate,
    required this.intakeCC,
    required this.outputCC,
    required this.balanceCC,
    this.warningMessage,
  });

  factory FluidBalanceLogResponseDTO.fromJson(Map<String, dynamic> json) {
    return FluidBalanceLogResponseDTO(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      logDate: json['log_date'] as String,
      intakeCC: json['intake_cc'] as int,
      outputCC: json['output_cc'] as int,
      balanceCC: json['balance_cc'] as int,
      warningMessage: json['warning_message'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'log_date': logDate,
      'intake_cc': intakeCC,
      'output_cc': outputCC,
      'balance_cc': balanceCC,
      if (warningMessage != null) 'warning_message': warningMessage,
    };
  }
}