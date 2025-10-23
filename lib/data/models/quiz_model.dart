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

class QuizResponse {
  final List<QuizModel> data;
  final int? total;
  final int? page;
  final int? limit;
  final int? totalPages;

  QuizResponse({
    required this.data,
    this.total,
    this.page,
    this.limit,
    this.totalPages,
  });

  factory QuizResponse.fromJson(Map<String, dynamic> json) {
    List<QuizModel> quizzes = [];
    
    if (json['data'] is List) {
      quizzes = (json['data'] as List)
          .map((item) => QuizModel.fromJson(item))
          .toList();
    }

    return QuizResponse(
      data: quizzes,
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