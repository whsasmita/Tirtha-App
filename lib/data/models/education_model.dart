class EducationModel {
  final int id;
  final String name;
  final String url;
  final String thumbnail;
  final int createdBy;
  final String? createdAt; // Diubah menjadi nullable
  final String? updatedAt; // Diubah menjadi nullable

  EducationModel({
    required this.id,
    required this.name,
    required this.url,
    required this.thumbnail,
    required this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  factory EducationModel.fromJson(Map<String, dynamic> json) {
    return EducationModel(
      // Menggunakan snake_case dan penanganan nullable
      id: json['id'] as int, 
      name: json['name'] as String,
      url: json['url'] as String,
      thumbnail: json['thumbnail'] as String,
      createdBy: json['created_by'] as int, // Menggunakan 'created_by'
      createdAt: json['created_at'] as String?, 
      updatedAt: json['updated_at'] as String?, 
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
    
    // 💡 Perbaikan: Ambil dataList dengan aman. Jika json['data'] null, dataList akan menjadi null.
    final dataList = json['data'];

    // Hanya coba map jika dataList bukan null DAN merupakan List
    if (dataList is List) {
      educations = dataList
          .map((item) => EducationModel.fromJson(item))
          .toList();
    }
    // Jika dataList adalah null (sesuai log Anda) atau bukan List, `educations` tetap list kosong `[]`.

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