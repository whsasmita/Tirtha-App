import 'package:tirtha_app/core/services/app_client.dart';
import 'package:dio/dio.dart';
import 'package:tirtha_app/data/models/user_model.dart';

class AuthService {
  Future<void> register(
    String name,
    String email,
    String password,
    String timezone,
    String phoneNumber, // 💡 Parameter phoneNumber
  ) async {
    try {
      final response = await ApiClient.dio.post(
        '/auth/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
          'timezone': timezone,
          'phone_number': phoneNumber, // 💡 Data phone_number dikirim
        },
        options: Options(
          headers: {Headers.contentTypeHeader: Headers.jsonContentType},
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Registrasi berhasil: ${response.data['message']}");
        print("phone_number: $phoneNumber");
        return;
      } else {
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
    // 💡 Tambahkan parameter timezone di sini
    String timezone,
  ) async {
    try {
      final response = await ApiClient.dio.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
          'fcm_token': fcmToken,
          // 💡 Kirimkan timezone dalam body permintaan
          'timezone': timezone,
        },
        options: Options(
          headers: {Headers.contentTypeHeader: Headers.jsonContentType},
        ),
      );

      if (response.data != null && response.data['token'] != null) {
        final token = response.data['token'];
        await ApiClient.saveToken(token);

        // 🔹 Setelah login berhasil, ambil profil user
        final profileResponse = await ApiClient.dio.get('/profile');
        final userDataMap =
            profileResponse.data['data'] as Map<String, dynamic>;
        final userData = UserModel.fromJson(userDataMap);
        
        print("Login berhasil. Timezone yang dikirim: $timezone"); // Tambahkan log

        return userData;
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
        } else if (statusCode == 400) {
          errorMessage = responseData['message'] ?? 'Permintaan tidak valid.';
        } else if (statusCode != null && statusCode >= 500) {
          errorMessage = 'Server sedang gangguan. Coba lagi nanti.';
        }
      }
      throw Exception(errorMessage);
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