import 'package:dio/dio.dart';
import 'package:tirtha_app/core/services/app_client.dart';
import 'package:tirtha_app/data/models/quiz_model.dart';

class QuizService {
  Future<void> saveQuiz(String name, String url) async {
    try {
      final response = await ApiClient.dio.post(
        '/quizzes/',
        data: {'name': name, 'url': url},
        options: Options(
          headers: {Headers.contentTypeHeader: Headers.jsonContentType},
        ),
      );

      if (response.statusCode == 201) {
        print("Quiz berhasil dibuat.");
        
        return; 

      } else {
        throw Exception(response.data['message'] ?? 'Pembuatan Quiz gagal dengan status tak terduga.');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400 || e.response?.statusCode == 422) {
        String errorMessage = e.response!.data['message']?.toString() ?? e.response!.data.toString();
        throw Exception(errorMessage);
      }
      
      if (e.response == null) {
          throw Exception('Tidak dapat terhubung ke server. Periksa koneksi internet Anda.');
      }

      throw Exception('Gagal membuat Quiz dengan kode: ${e.response?.statusCode}');
    }
  }

  Future<List<QuizModel>> fetchAllQuizzes({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await ApiClient.dio.get(
        '/quizzes/',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );
      
      if (response.data != null && response.data['data'] is List) {
        List<dynamic> dataList = response.data['data'];
        
        return dataList.map((json) => QuizModel.fromJson(json)).toList();
      }
      
      throw Exception('Format data kuis dari server tidak valid.');
      
    } on DioException catch (e) {
      String errorMessage = 'Gagal memuat kuis. Coba lagi.';
      
      if (e.response != null && e.response!.data is Map) {
        errorMessage = e.response!.data['message']?.toString() ?? 
                      e.response!.statusMessage ?? 
                      'Permintaan gagal.';
      } else if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage = 'Koneksi timeout. Periksa internet Anda.';
      } else if (e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Server tidak merespons. Coba lagi.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'Tidak dapat terhubung ke server.';
      }
      
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Terjadi kesalahan: ${e.toString()}');
    }
  }

  /// Fetch quizzes dengan total count untuk pagination
  Future<QuizResponse> fetchQuizzesWithMeta({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await ApiClient.dio.get(
        '/quizzes/',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );
      
      if (response.data != null) {
        return QuizResponse.fromJson(response.data);
      }
      
      throw Exception('Format data kuis dari server tidak valid.');
      
    } on DioException catch (e) {
      String errorMessage = 'Gagal memuat kuis. Coba lagi.';
      
      if (e.response != null && e.response!.data is Map) {
        errorMessage = e.response!.data['message']?.toString() ?? 
                      e.response!.statusMessage ?? 
                      'Permintaan gagal.';
      } else if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage = 'Koneksi timeout. Periksa internet Anda.';
      } else if (e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Server tidak merespons. Coba lagi.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'Tidak dapat terhubung ke server.';
      }
      
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Terjadi kesalahan: ${e.toString()}');
    }
  }

  Future<QuizModel> fetchQuizById(int id) async {
    try {
      final response = await ApiClient.dio.get('/quizzes/$id');
      
      if (response.statusCode == 201 && response.data != null) {
        if (response.data['data'] != null) { 
          return QuizModel.fromJson(response.data['data']);
        }
        throw Exception('Data kuis tidak ditemukan dalam respons.');
      }
      throw Exception('Gagal mendapatkan detail kuis.');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Koneksi gagal atau Quiz tidak ditemukan.');
    }
  }

  Future<void> updateQuiz(int id, String name, String url) async {
    try {
      final response = await ApiClient.dio.put(
        '/quizzes/$id',
        data: {'name': name, 'url': url},
        options: Options(
          headers: {Headers.contentTypeHeader: Headers.jsonContentType},
        ),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
         throw Exception(response.data['message'] ?? 'Gagal memperbarui kuis.');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal memperbarui kuis karena jaringan.');
    }
  }

  Future<void> deleteQuiz(int id) async {
    try {
      final response = await ApiClient.dio.delete(
        '/quizzes/$id',
      );

      if (response.statusCode != 201) {
         throw Exception(response.data['message'] ?? 'Gagal menghapus kuis.');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal menghapus kuis karena jaringan.');
    }
  }  
}