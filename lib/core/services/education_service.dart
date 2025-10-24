// education_service.dart (Perbaikan final)

import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tirtha_app/core/services/app_client.dart';
import 'package:tirtha_app/data/models/education_model.dart';

class EducationService {
  Future<void> saveEducation(String name, String url, XFile thumbnail) async {
    try {
      final thumbnailFile = await MultipartFile.fromFile(
        thumbnail.path,
        filename: thumbnail.name,
      );

      final FormData formData = FormData.fromMap({
        'name': name,
        'url': url,
        'thumbnail': thumbnailFile,
      });

      final response = await ApiClient.dio.post(
        '/educations/',
        data: formData,
      );

      if (response.statusCode == 201) {
        return; 
      } else {
        throw Exception(response.data['message'] ?? 'Pembuatan Edukasi gagal dengan status tak terduga.');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400 || e.response?.statusCode == 422) {
        String errorMessage = e.response!.data['message']?.toString() ?? e.response!.data.toString();
        throw Exception(errorMessage);
      }
      
      if (e.response == null) {
        throw Exception('Tidak dapat terhubung ke server. Periksa koneksi internet Anda.');
      }

      throw Exception('Gagal membuat Edukasi dengan kode: ${e.response?.statusCode}');
    }
  }

  Future<List<EducationModel>> fetchAllEducations({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await ApiClient.dio.get(
        '/educations/',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );
      
      // 💡 Perbaikan KRITIS: Ambil data['data'] dengan aman. Jika null, perlakukan sebagai List kosong.
      final dataList = response.data?['data'];
      
      if (dataList is List) {
        // Jika dataList adalah List (bahkan kosong), proses mapping.
        return dataList.map((json) => EducationModel.fromJson(json)).toList();
      }
      
      // 💡 Jika dataList adalah null (sesuai log Anda) atau bukan List, kembalikan List kosong.
      return [];
      
    } on DioException catch (e) {
      String errorMessage = 'Gagal memuat edukasi. Coba lagi.';
      
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
      // Ini akan menangkap error dari EducationModel.fromJson jika terjadi
      throw Exception('Terjadi kesalahan: ${e.toString()}');
    }
  }

  Future<EducationResponse> fetchEducationsWithMeta({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await ApiClient.dio.get(
        '/educations/',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );
      
      if (response.data != null && response.data is Map<String, dynamic>) {
        // EducationResponse.fromJson sudah diperbaiki untuk menangani data: null
        return EducationResponse.fromJson(response.data);
      }
      
      // Jika respons keseluruhan tidak valid, kembalikan EducationResponse kosong.
      return EducationResponse(data: []);
      
    } on DioException catch (e) {
      String errorMessage = 'Gagal memuat edukasi. Coba lagi.';
      
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

  Future<void> updateEducation(int id, String name, String url, XFile? thumbnail) async {
    try {
      final Map<String, dynamic> dataMap = {
        'name': name,
        'url': url,
      };

      if (thumbnail != null) {
        final thumbnailFile = await MultipartFile.fromFile(
          thumbnail.path,
          filename: thumbnail.name,
        );
        dataMap['thumbnail'] = thumbnailFile;
      }
      
      final FormData formData = FormData.fromMap(dataMap);

      final response = await ApiClient.dio.put(
        '/educations/$id',
        data: formData,
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(response.data['message'] ?? 'Gagal memperbarui edukasi.');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal memperbarui edukasi karena jaringan.');
    }
  }
  
  Future<EducationModel> fetchEducationById(int id) async {
    try {
      final response = await ApiClient.dio.get('/educations/$id');
      final dynamic responseData = response.data['data']; 

      if (response.statusCode == 200 && responseData is Map<String, dynamic>) {
        return EducationModel.fromJson(responseData);
      }
      
      throw Exception('Data edukasi tidak valid atau tidak ditemukan.');

    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Koneksi gagal atau Edukasi tidak ditemukan.');
    } catch (e) {
      throw Exception('Gagal mendapatkan detail edukasi: ${e.toString()}');
    }
  }

  Future<void> deleteEducation(int id) async {
    try {
      await ApiClient.dio.delete('/educations/$id');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal menghapus edukasi karena jaringan.');
    }
  } 
}