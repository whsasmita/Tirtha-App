class EducationModel {
  final int id;
  final String name;
  final String url;
  final String thumbnail;
  final int createdBy;
  final String createdAt;
  final String updatedAt;

  EducationModel({
    required this.id,
    required this.name,
    required this.url,
    required this.thumbnail,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory EducationModel.fromJson(Map<String, dynamic> json) {
    return EducationModel(
      id: json['ID'] as int,
      name: json['Name'] as String,
      url: json['Url'] as String,
      thumbnail: json['Thumbnail'] as String,
      createdBy: json['CreatedBy'] as int,
      createdAt: json['CreatedAt'] as String,
      updatedAt: json['UpdatedAt'] as String,
    );
  }
}
