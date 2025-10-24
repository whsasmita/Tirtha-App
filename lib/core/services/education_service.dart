import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tirtha_app/core/services/app_client.dart';
import 'package:tirtha_app/data/models/education_model.dart';

class EducationService {
  Future<void> saveEducation(String name, String url, XFile thumbnail) async {
    try {
      // 1. Buat MultipartFile dari XFile
      final thumbnailFile = await MultipartFile.fromFile(
        thumbnail.path,
        filename: thumbnail.name,
      );

      // 2. Buat FormData
      final FormData formData = FormData.fromMap({
        'name': name,
        'url': url,
        'thumbnail': thumbnailFile, // Kirim file sebagai 'thumbnail'
      });

      final response = await ApiClient.dio.post(
        '/educations/',
        data: formData, // Kirim FormData
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
    
    // 💡 Perbaikan: Jika data['data'] ada dan berupa List (bahkan kosong),
    // kembalikan hasil mapping. Jika tidak, lemparkan Exception.
    if (response.data != null && response.data['data'] is List) {
      List<dynamic> dataList = response.data['data'];
      
      // Jika dataList kosong, map() akan mengembalikan list kosong yang valid.
      return dataList.map((json) => EducationModel.fromJson(json)).toList();
    }
    
    // Jika respons.data tidak ada atau 'data' bukan List, ini adalah format yang tidak valid.
    throw Exception('Format data edukasi dari server tidak valid.');
    
  } on DioException catch (e) {
    // ... (kode penanganan error sudah cukup baik)
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
    // Menangkap error dari EducationModel.fromJson (jika masih ada) atau error lain
    throw Exception('Terjadi kesalahan: ${e.toString()}');
  }
}

  /// Fetch education dengan total count untuk pagination
  // Di EducationService class

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
    
    // 💡 Perbaikan: Pastikan respons tidak null sebelum diproses oleh EducationResponse.fromJson
    if (response.data != null && response.data is Map<String, dynamic>) {
      // EducationResponse.fromJson sudah memiliki logika untuk menangani list kosong []
      return EducationResponse.fromJson(response.data);
    }
    
    // Jika respons kosong atau bukan map, anggap tidak valid.
    throw Exception('Format data edukasi dari server tidak valid.');
    
  } on DioException catch (e) {
    // ... (kode penanganan error yang sama)
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
        // Jika ada thumbnail baru, tambahkan ke data sebagai MultipartFile
        final thumbnailFile = await MultipartFile.fromFile(
          thumbnail.path,
          filename: thumbnail.name,
        );
        dataMap['thumbnail'] = thumbnailFile;
      }
      
      final FormData formData = FormData.fromMap(dataMap);

      final response = await ApiClient.dio.put(
        '/educations/$id',
        data: formData, // Kirim FormData
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(response.data['message'] ?? 'Gagal memperbarui edukasi.');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal memperbarui edukasi karena jaringan.');
    }
  }

  // NOTE: Anda harus menyesuaikan method di bawah ini dengan EducationModel Anda yang sebenarnya
  
  Future<EducationModel> fetchEducationById(int id) async {
    try {
      final response = await ApiClient.dio.get('/educations/$id');
      
      // 💡 Pastikan respons.data['data'] ada dan berupa Map
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