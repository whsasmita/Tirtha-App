class QuizModel {
  final int id;
  final String name;
  final String url;
  final int createdBy;
  final String createdAt;
  final String updatedAt;

  QuizModel({
    required this.id,
    required this.name,
    required this.url,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory QuizModel.fromJson(Map<String, dynamic> json) {
    return QuizModel(
      id: json['ID'] as int,
      name: json['Name'] as String,
      url: json['Url'] as String,
      createdBy: json['CreatedBy'] as int,
      createdAt: json['CreatedAt'] as String,
      updatedAt: json['UpdatedAt'] as String,
    );
  }
}