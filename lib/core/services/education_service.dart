import 'package:dio/dio.dart';
import 'package:tirtha_app/core/services/app_client.dart';
import 'package:tirtha_app/data/models/education_model.dart';

class EducationService {
  Future<void> saveEducation(String name, String url, String thumbnail) async {
    try {
      final response = await ApiClient.dio.post(
        '/educations/',
        data: {'name': name, 'url': url, 'thumbnail':thumbnail},
        options: Options(
          headers: {Headers.contentTypeHeader: Headers.jsonContentType},
        ),
      );

      if (response.statusCode == 201) {
        print("Edukasi berhasil dibuat.");
        
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

  Future<List<EducationModel>> fetchAllEducations() async {
    try {
      final response = await ApiClient.dio.get('/educations/');
      
      if (response.data != null && response.data['data'] is List) {
        List<dynamic> dataList = response.data['data'];
        
        return dataList.map((json) => EducationModel.fromJson(json)).toList();
      }
      
      throw Exception('Format data edukasi dari server tidak valid.');
      
    } on DioException catch (e) {
      String errorMessage = 'Gagal memuat edukasi. Coba lagi.';
      if (e.response != null && e.response!.data is Map) {
         errorMessage = e.response!.data['message']?.toString() ?? e.response!.statusMessage ?? 'Permintaan gagal.';
      }
      throw Exception(errorMessage);
    }
  }

  Future<EducationModel> fetchEducationById(int id) async {
    try {
      final response = await ApiClient.dio.get('/educations/$id');
      
      if (response.statusCode == 200 && response.data != null) {
        if (response.data['data'] != null) { 
          return EducationModel.fromJson(response.data['data']);
        }
        throw Exception('Data edukasi tidak ditemukan dalam respons.');
      }
      throw Exception('Gagal mendapatkan detail edukasi.');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Koneksi gagal atau Edukasi tidak ditemukan.');
    }
  }

  Future<void> updateEducation(int id, String name, String url, thumbnail) async {
    try {
      final response = await ApiClient.dio.put(
        '/educations/$id',
        data: {'name': name, 'url': url, "thumbnail":thumbnail},
        options: Options(
          headers: {Headers.contentTypeHeader: Headers.jsonContentType},
        ),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
         throw Exception(response.data['message'] ?? 'Gagal memperbarui edukasi.');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal memperbarui edukasi karena jaringan.');
    }
  }

  Future<void> deleteEducation(int id) async {
    try {
      await ApiClient.dio.delete(
        '/educations/$id',
      );

      // if (response.statusCode != 201 || response.statusCode !=200 || response.statusCode == 204) {
      //    throw Exception(response.data['message'] ?? 'Gagal menghapus edukasi.');
      // }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal menghapus edukasi karena jaringan.');
    }
  }  
}