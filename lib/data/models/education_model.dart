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
      // 💡 Perbaikan: Mengganti PascalCase ke snake_case/lowercase
      id: json['id'] as int, 
      name: json['name'] as String,
      url: json['url'] as String,
      thumbnail: json['thumbnail'] as String,
      createdBy: json['created_by'] as int, 
      // Asumsi key untuk waktu juga menggunakan snake_case
      createdAt: json['created_at'] as String, 
      updatedAt: json['updated_at'] as String,
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
