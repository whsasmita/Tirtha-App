import 'package:tirtha_app/core/services/app_client.dart';
import 'package:dio/dio.dart';
import 'package:tirtha_app/data/models/user_model.dart';
import 'dart:io';

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
          validateStatus: (status) => status! < 600,
        ),
      );

      print('📊 Response Status Register: ${response.statusCode}');
      print('📥 Response Data Register: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("✅ Registrasi berhasil: ${response.data['message']}");
        print("phone_number: $phoneNumber");
        return;
      } else if (response.statusCode == 500) {
        final responseData = response.data;
        
        if (responseData != null && responseData['data'] != null) {
          final errorData = responseData['data'].toString().toLowerCase();
          
          if (errorData.contains('duplicate') && errorData.contains('email')) {
            throw Exception('Email $email sudah terdaftar. Gunakan email lain atau silakan login.');
          } else if (errorData.contains('duplicate') && errorData.contains('phone')) {
            throw Exception('Nomor telepon sudah terdaftar. Gunakan nomor lain.');
          } else if (errorData.contains('duplicate')) {
            throw Exception('Data yang Anda masukkan sudah terdaftar. Silakan gunakan data lain.');
          }
        }
        
        final serverMessage = responseData['message']?.toString() ?? '';
        if (serverMessage.isNotEmpty && serverMessage.toLowerCase() != 'registration failed') {
          throw Exception(serverMessage);
        }
        
        throw Exception('Email sudah terdaftar. Gunakan email lain atau silakan login.');
        
      } else if (response.statusCode == 400) {
        final serverMessage = response.data['message']?.toString() ?? 'Permintaan tidak valid.';
        throw Exception(serverMessage);
      } else if (response.statusCode == 422) {
        final serverMessage = response.data['message']?.toString() ?? 'Data yang Anda masukkan tidak valid.';
        throw Exception(serverMessage);
      } else {
        final serverMessage = response.data['message']?.toString() ?? 'Registrasi gagal.';
        throw Exception(serverMessage);
      }
    } on DioException catch (e) {
      print('❌ DioException on Register:');
      print('   Status Code: ${e.response?.statusCode}');
      print('   Response Data: ${e.response?.data}');
      
      if (e.response != null && e.response!.data != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;
        
        if (statusCode == 500) {
          if (responseData['data'] != null) {
            final errorData = responseData['data'].toString().toLowerCase();
            
            if (errorData.contains('duplicate') && errorData.contains('email')) {
              throw Exception('Email sudah terdaftar. Gunakan email lain atau silakan login.');
            } else if (errorData.contains('duplicate') && errorData.contains('phone')) {
              throw Exception('Nomor telepon sudah terdaftar. Gunakan nomor lain.');
            } else if (errorData.contains('duplicate')) {
              throw Exception('Data yang Anda masukkan sudah terdaftar. Silakan gunakan data lain.');
            }
          }
          throw Exception('Email sudah terdaftar. Gunakan email lain atau silakan login.');
        }
        
        throw Exception(
          responseData['message'] ?? 'Terjadi kesalahan pada server.',
        );
      }
      
      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Koneksi timeout. Periksa jaringan Anda.');
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Server tidak merespons. Coba lagi nanti.');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('Tidak ada koneksi internet. Periksa jaringan Anda.');
      }
      
      throw Exception('Koneksi gagal. Coba lagi nanti.');
    } catch (e) {
      print('❌ Unexpected error (Register): $e');
      if (e is Exception) rethrow;
      throw Exception('Terjadi kesalahan tidak terduga. Silakan coba lagi.');
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
          validateStatus: (status) => status! < 500,
        ),
      );

      print('📊 Response Status: ${response.statusCode}');
      print('📥 Response Data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data != null && response.data['token'] != null) {
          final token = response.data['token'];
          await ApiClient.saveToken(token);

          final profileResponse = await ApiClient.dio.get('/profile');
          final userDataMap = profileResponse.data['data'] as Map<String, dynamic>;
          final userData = UserModel.fromJson(userDataMap);
          
          print("✅ Login berhasil. Timezone yang dikirim: $timezone");

          return userData;
        } else {
          throw Exception('Token tidak ditemukan dalam response.');
        }
      } else if (response.statusCode == 400) {
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
      print('❌ Unexpected error: $e');
      
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

  /// Update Profile (name dan/atau profile_picture)
  /// Menggunakan FormData karena ada file upload
  Future<void> updateProfile({
    String? name,
    File? profilePicture,
  }) async {
    try {
      // Validasi: minimal ada satu data yang diupdate
      if (name == null && profilePicture == null) {
        throw Exception('Tidak ada data yang diubah.');
      }

      FormData formData = FormData();

      // Tambahkan name jika ada
      if (name != null && name.isNotEmpty) {
        formData.fields.add(MapEntry('name', name));
        print('📝 Updating name: $name');
      }

      // Tambahkan profile_picture jika ada
      if (profilePicture != null) {
        String fileName = profilePicture.path.split('/').last;
        formData.files.add(
          MapEntry(
            'profile_picture',
            await MultipartFile.fromFile(
              profilePicture.path,
              filename: fileName,
            ),
          ),
        );
        print('📷 Updating profile picture: $fileName');
      }

      final response = await ApiClient.dio.put(
        '/profile',
        data: formData,
        options: Options(
          validateStatus: (status) => status! < 600,
        ),
      );

      print('📊 Response Status Update Profile: ${response.statusCode}');
      print('📥 Response Data Update Profile: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 202) {
        print("✅ Pembaruan profil berhasil: ${response.data['message'] ?? 'Profil berhasil diubah.'}");
        return;
      } else if (response.statusCode == 422) {
        final serverMessage = response.data['message']?.toString() ?? 'Data yang Anda masukkan tidak valid.';
        throw Exception(serverMessage);
      } else if (response.statusCode == 413) {
        throw Exception('Ukuran file terlalu besar. Maksimal 2MB.');
      } else if (response.statusCode == 415) {
        throw Exception('Format file tidak didukung. Gunakan JPG, JPEG, atau PNG.');
      } else if (response.statusCode == 500) {
        final responseData = response.data;
        final serverMessage = responseData['message']?.toString() ?? '';
        
        if (serverMessage.toLowerCase().contains('file') || 
            serverMessage.toLowerCase().contains('image')) {
          throw Exception('Gagal mengupload foto. Periksa format dan ukuran file.');
        }
        throw Exception('Server sedang gangguan. Coba lagi nanti.');
      } else {
        final serverMessage = response.data['message']?.toString() ?? 'Gagal memperbarui profil.';
        throw Exception(serverMessage);
      }
    } on DioException catch (e) {
      String errorMessage = 'Terjadi kesalahan jaringan saat memperbarui profil. Coba lagi.';

      print('❌ DioException on Update Profile:');
      print('   Status Code: ${e.response?.statusCode}');
      print('   Response Data: ${e.response?.data}');

      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;

        if (statusCode == 401 || statusCode == 403) {
          errorMessage = 'Sesi Anda telah berakhir. Silakan login kembali.';
        } else if (statusCode == 400 || statusCode == 422) {
          errorMessage = responseData['message'] ?? 'Data yang Anda masukkan tidak valid.';
        } else if (statusCode == 413) {
          errorMessage = 'Ukuran file terlalu besar. Maksimal 2MB.';
        } else if (statusCode == 415) {
          errorMessage = 'Format file tidak didukung. Gunakan JPG, JPEG, atau PNG.';
        } else if (statusCode != null && statusCode >= 500) {
          final serverMessage = responseData['message']?.toString() ?? '';
          if (serverMessage.toLowerCase().contains('file') || 
              serverMessage.toLowerCase().contains('image')) {
            errorMessage = 'Gagal mengupload foto. Periksa format dan ukuran file.';
          } else {
            errorMessage = 'Server sedang gangguan. Coba lagi nanti.';
          }
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
      print('❌ Unexpected error (Update Profile): $e');
      if (e is Exception) rethrow;
      throw Exception('Terjadi kesalahan tidak terduga saat memperbarui profil.');
    }
  }

  /// Update Password
  /// Menggunakan FormData untuk konsistensi dengan updateProfile
  Future<void> updatePassword(String newPassword) async {
    try {
      // Validasi password
      if (newPassword.isEmpty) {
        throw Exception('Password baru tidak boleh kosong.');
      }

      if (newPassword.length < 6) {
        throw Exception('Password minimal 6 karakter.');
      }

      FormData formData = FormData.fromMap({
        'password': newPassword,
      });

      final response = await ApiClient.dio.put(
        '/profile',
        data: formData,
        options: Options(
          validateStatus: (status) => status! < 600,
        ),
      );

      print('📊 Response Status Update Password: ${response.statusCode}');
      print('📥 Response Data Update Password: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 202) {
        print("✅ Pembaruan password berhasil: ${response.data['message'] ?? 'Password berhasil diubah.'}");
        return;
      } else if (response.statusCode == 422) {
        final serverMessage = response.data['message']?.toString() ?? '';
        
        if (serverMessage.toLowerCase().contains('password')) {
          throw Exception('Password baru tidak memenuhi persyaratan. Minimal 6 karakter.');
        }
        throw Exception(serverMessage.isNotEmpty ? serverMessage : 'Data yang Anda masukkan tidak valid.');
      } else if (response.statusCode == 400) {
        final serverMessage = response.data['message']?.toString() ?? 'Permintaan tidak valid.';
        throw Exception(serverMessage);
      } else if (response.statusCode == 500) {
        throw Exception('Server sedang gangguan. Coba lagi nanti.');
      } else {
        final serverMessage = response.data['message']?.toString() ?? 'Gagal memperbarui password.';
        throw Exception(serverMessage);
      }
    } on DioException catch (e) {
      String errorMessage = 'Terjadi kesalahan jaringan saat update password. Coba lagi.';

      print('❌ DioException on Update Password:');
      print('   Status Code: ${e.response?.statusCode}');
      print('   Response Data: ${e.response?.data}');

      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;

        if (statusCode == 401 || statusCode == 403) {
          errorMessage = 'Sesi Anda telah berakhir. Silakan login kembali.';
        } else if (statusCode == 400 || statusCode == 422) {
          final serverMessage = responseData['message']?.toString() ?? '';
          if (serverMessage.toLowerCase().contains('password')) {
            errorMessage = 'Password baru tidak memenuhi persyaratan. Minimal 6 karakter.';
          } else {
            errorMessage = serverMessage.isNotEmpty ? serverMessage : 'Permintaan tidak valid.';
          }
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
      print('❌ Unexpected error (Update Password): $e');
      if (e is Exception) rethrow;
      throw Exception('Terjadi kesalahan tidak terduga saat memperbarui password.');
    }
  }

  Future<void> logout() async {
    await ApiClient.deleteToken();
    print("Logout Berhasil");
  }
}