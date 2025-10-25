import 'package:tirtha_app/core/services/app_client.dart';
import 'package:dio/dio.dart';
import 'package:tirtha_app/data/models/user_model.dart';

class AuthService {
  Future<void> register(
    String name,
    String email,
    String password,
    String timezone,
    String phoneNumber,
  ) async {
    try {
      final response = await ApiClient.dio.post(
        '/auth/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
          'timezone': timezone,
          'phone_number': phoneNumber,
        },
        options: Options(
          headers: {Headers.contentTypeHeader: Headers.jsonContentType},
          validateStatus: (status) => status! < 500, // ✅ Terima semua status < 500
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Registrasi berhasil: ${response.data['message']}");
        print("phone_number: $phoneNumber");
        return;
      } else {
        // Handle error response dari server
        throw Exception(response.data['message'] ?? 'Registrasi gagal.');
      }
    } on DioException catch (e) {
      if (e.response != null && e.response!.data != null) {
        throw Exception(
          e.response!.data['message'] ?? 'Terjadi kesalahan pada server.',
        );
      }
      throw Exception('Koneksi gagal. Coba lagi nanti.');
    }
  }

  Future<UserModel> login(
    String email,
    String password,
    String? fcmToken,
    String timezone,
  ) async {
    try {
      final response = await ApiClient.dio.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
          'fcm_token': fcmToken,
          'timezone': timezone,
        },
        options: Options(
          headers: {Headers.contentTypeHeader: Headers.jsonContentType},
          validateStatus: (status) => status! < 500, // ✅ Terima semua status < 500
        ),
      );

      print('📊 Response Status: ${response.statusCode}');
      print('📥 Response Data: ${response.data}');

      // ✅ Cek status code terlebih dahulu
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Login berhasil, cek token
        if (response.data != null && response.data['token'] != null) {
          final token = response.data['token'];
          await ApiClient.saveToken(token);

          // Ambil profil user
          final profileResponse = await ApiClient.dio.get('/profile');
          final userDataMap = profileResponse.data['data'] as Map<String, dynamic>;
          final userData = UserModel.fromJson(userDataMap);
          
          print("✅ Login berhasil. Timezone yang dikirim: $timezone");

          return userData;
        } else {
          throw Exception('Token tidak ditemukan dalam response.');
        }
      } else if (response.statusCode == 400) {
        // 🔥 Handle status 400 - Login failed
        final serverMessage = response.data['message']?.toString() ?? '';
        
        if (serverMessage.toLowerCase().contains('login failed') ||
            serverMessage.toLowerCase().contains('invalid') ||
            serverMessage.toLowerCase().contains('wrong')) {
          throw Exception('Email atau password yang Anda masukkan salah.');
        } else {
          throw Exception(serverMessage.isNotEmpty ? serverMessage : 'Permintaan tidak valid.');
        }
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('Email atau password yang Anda masukkan salah.');
      } else if (response.statusCode == 404) {
        throw Exception('Akun tidak ditemukan. Silakan daftar terlebih dahulu.');
      } else if (response.statusCode == 422) {
        throw Exception('Data yang Anda masukkan tidak valid.');
      } else {
        // Status code lainnya
        final serverMessage = response.data['message']?.toString() ?? 'Login gagal.';
        throw Exception(serverMessage);
      }
    } on DioException catch (e) {
      String errorMessage = 'Terjadi kesalahan jaringan. Coba lagi.';

      print('❌ DioException caught:');
      print('   Status Code: ${e.response?.statusCode}');
      print('   Response Data: ${e.response?.data}');
      print('   Error Type: ${e.type}');

      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;

        if (statusCode == 400) {
          final serverMessage = responseData['message']?.toString().toLowerCase() ?? '';
          
          if (serverMessage.contains('login') || 
              serverMessage.contains('email') || 
              serverMessage.contains('password') ||
              serverMessage.contains('kredensial') ||
              serverMessage.contains('invalid')) {
            errorMessage = 'Email atau password yang Anda masukkan salah.';
          } else {
            errorMessage = responseData['message'] ?? 'Permintaan tidak valid.';
          }
        } else if (statusCode == 401 || statusCode == 403) {
          errorMessage = 'Email atau password yang Anda masukkan salah.';
        } else if (statusCode == 404) {
          errorMessage = 'Akun tidak ditemukan. Silakan daftar terlebih dahulu.';
        } else if (statusCode == 422) {
          errorMessage = 'Data yang Anda masukkan tidak valid.';
        } else if (statusCode != null && statusCode >= 500) {
          errorMessage = 'Server sedang gangguan. Coba lagi nanti.';
        }
      } else if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage = 'Koneksi timeout. Periksa jaringan Anda.';
      } else if (e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Server tidak merespons. Coba lagi nanti.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'Tidak ada koneksi internet. Periksa jaringan Anda.';
      }
      
      throw Exception(errorMessage);
    } catch (e) {
      // Tangani error umum lainnya (termasuk Exception yang di-throw manual)
      print('❌ Unexpected error: $e');
      
      // Jika sudah Exception dengan pesan custom, lempar ulang
      if (e is Exception) {
        rethrow;
      }
      
      throw Exception('Terjadi kesalahan tidak terduga. Silakan coba lagi.');
    }
  }

  Future<UserModel> getUserProfile() async {
    try {
      final response = await ApiClient.dio.get('/profile');

      final userDataMap = response.data['data'] as Map<String, dynamic>; 
    
      final userData = UserModel.fromJson(userDataMap);
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