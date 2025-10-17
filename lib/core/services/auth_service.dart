import 'package:tirtha_app/core/services/app_client.dart';   
import 'package:dio/dio.dart';
import 'package:tirtha_app/data/models/user_model.dart';

class AuthService {
  Future<void> register(String name, String email, String password) async {
    try {
      final response = await ApiClient.dio.post(
        '/auth/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
        },
        options: Options(
          headers: {
            Headers.contentTypeHeader: Headers.jsonContentType,
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Registrasi berhasil: ${response.data['message']}");
        return;
      } else {
        throw Exception(response.data['message'] ?? 'Registrasi gagal.');
      }
    } on DioException catch (e) {
      if (e.response != null && e.response!.data != null) {
        throw Exception(e.response!.data['message'] ?? 'Terjadi kesalahan pada server.');
      }
      throw Exception('Koneksi gagal. Coba lagi nanti.');
    }
  }

  Future<void> login(String email, String password) async {
    try {
      final response = await ApiClient.dio.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
        options: Options(
          headers: {Headers.contentTypeHeader: Headers.jsonContentType},
        ),
      );

      if (response.data != null && response.data['token'] != null) {
        final token = response.data['token'];
        await ApiClient.saveToken(token);
        return;
      } else {
        throw Exception('Respons server tidak valid. Token tidak ditemukan.');
      }
    } on DioException catch (e) {
      String errorMessage = 'Terjadi kesalahan jaringan. Coba lagi.';

      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;

        if (statusCode == 401 || statusCode == 403) {
          errorMessage = 'Email atau password salah.';
        } 
        else if (statusCode == 400) {
            if (responseData is Map && responseData['message'] != null) {
                errorMessage = responseData['message'].toString();
            } else {
                errorMessage = 'Permintaan tidak valid. Cek kembali data yang Anda masukkan.';
            }
        }
        else if (statusCode != null && statusCode >= 500) {
          errorMessage = 'Server sedang mengalami gangguan. Mohon coba beberapa saat lagi.';
        }
        
      } else {
        errorMessage = 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.';
      }

      throw Exception(errorMessage);
    }
  }

  Future<UserModel> getUserProfile() async {
    try {
      final response = await ApiClient.dio.get('/profile');
      
      final userData = UserModel.fromJson(response.data);
      return userData;
    } on DioException catch (e) {
      if (e.response != null && e.response!.data != null) {
        throw Exception(e.response!.data['message']);
      }
      throw Exception('Gagal mengambil data profil.');
    }
  }

  Future<void> logout() async {
    await ApiClient.deleteToken();
    print("Logout Berhasil");
  }
}
