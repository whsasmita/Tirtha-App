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

class EducationResponse {
  final List<EducationModel> data;
  final int? total;
  final int? page;
  final int? limit;
  final int? totalPages;

  EducationResponse({
    required this.data,
    this.total,
    this.page,
    this.limit,
    this.totalPages,
  });

  factory EducationResponse.fromJson(Map<String, dynamic> json) {
    List<EducationModel> educations = [];
    
    if (json['data'] is List) {
      educations = (json['data'] as List)
          .map((item) => EducationModel.fromJson(item))
          .toList();
    }

    return EducationResponse(
      data: educations,
      total: json['total'] as int?,
      page: json['page'] as int?,
      limit: json['limit'] as int?,
      totalPages: json['total_pages'] as int?,
    );
  }

  bool get hasMore {
    if (totalPages != null && page != null) {
      return page! < totalPages!;
    }
    return false;
  }
}
