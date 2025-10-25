import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:tirtha_app/presentation/widgets/app_button.dart';
import 'package:tirtha_app/presentation/widgets/app_text_field.dart';
import 'package:tirtha_app/presentation/widgets/password_text_field.dart';
import 'package:tirtha_app/presentation/themes/color.dart';
import 'package:tirtha_app/routes/app_routes.dart';
import 'package:tirtha_app/core/services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final AuthService _authService = AuthService();

  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Menampilkan dialog error
  /// Menampilkan dialog error
  void _showErrorDialog(String message) {
    // Tentukan title berdasarkan message
    String title = 'Terjadi Kesalahan';
    IconData icon = Icons.error_outline;
    Color iconColor = Colors.red;

    if (message.toLowerCase().contains('email') && 
        message.toLowerCase().contains('password')) {
      title = 'Login Gagal';
      icon = Icons.lock_person_outlined;
      iconColor = Colors.orange;
    } else if (message.toLowerCase().contains('akun tidak ditemukan')) {
      title = 'Akun Tidak Ditemukan';
      icon = Icons.person_off_outlined;
      iconColor = Colors.orange;
    } else if (message.toLowerCase().contains('koneksi') ||
        message.toLowerCase().contains('jaringan') ||
        message.toLowerCase().contains('internet')) {
      title = 'Masalah Koneksi';
      icon = Icons.wifi_off;
    } else if (message.toLowerCase().contains('server') ||
        message.toLowerCase().contains('timeout')) {
      title = 'Server Bermasalah';
      icon = Icons.cloud_off;
    } else if (message.toLowerCase().contains('tidak lengkap') ||
        message.toLowerCase().contains('tidak boleh kosong')) {
      title = 'Input Tidak Lengkap';
      icon = Icons.warning_amber_rounded;
      iconColor = Colors.orange;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding: const EdgeInsets.all(24),
          title: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 48,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
            ),
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Mengerti',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // 💡 Salin fungsi _getDeviceTimezone dari RegisterPage
  String _getDeviceTimezone() {
    final now = DateTime.now();
    final offset = now.timeZoneOffset;

    final offsetInHours = offset.inHours;

    switch (offsetInHours) {
      case 7:
        return 'Asia/Jakarta';
      case 8:
        return 'Asia/Makassar';
      case 9:
        return 'Asia/Jayapura';
      default:
        final sign = offset.isNegative ? '-' : '+';
        final hours = offset.inHours.abs().toString().padLeft(2, '0');
        final minutes = (offset.inMinutes.abs() % 60).toString().padLeft(2, '0');
        return 'UTC$sign$hours:$minutes';
    }
  }

  /// Mendapatkan FCM Token dari Firebase
  Future<String?> _getFcmToken() async {
    try {
      String? token = await FirebaseMessaging.instance.getToken();

      if (token != null) {
        print('╔════════════════════════════════════════╗');
        print('║           FCM TOKEN BERHASIL           ║');
        print('╠════════════════════════════════════════╣');
        print('║ Token: $token');
        print('╚════════════════════════════════════════╝');
      } else {
        print('⚠️ FCM Token tidak tersedia');
      }

      return token;
    } catch (e) {
      print('❌ Error mendapatkan FCM token: $e');
      return null;
    }
  }

  /// Handle Login dengan FCM Token dan Timezone
  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // Validasi input
    if (email.isEmpty || password.isEmpty) {
      _showErrorDialog('Email dan Password tidak boleh kosong.');
      return;
    }

    // Validasi format email sederhana
    if (!email.contains('@') || !email.contains('.')) {
      _showErrorDialog('Format email tidak valid.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 1. Dapatkan FCM Token
      print('🔄 Mengambil FCM Token...');
      String? fcmToken = await _getFcmToken();

      if (fcmToken != null) {
        print('✅ FCM Token berhasil didapatkan');
      } else {
        print('⚠️ Login tanpa FCM Token (notifikasi mungkin tidak berfungsi)');
      }
      
      // 2. 💡 Dapatkan Timezone Perangkat
      final String timezone = _getDeviceTimezone();
      print('🌎 Timezone detected: $timezone');


      // 3. Login dengan email, password, FCM token, dan timezone
      print('🔄 Proses login ke server...');
      // 💡 Teruskan timezone ke _authService.login()
      final user = await _authService.login(email, password, fcmToken, timezone);

      print('✅ Login berhasil!');
      print('👤 User: ${user.name ?? 'Unknown'}');
      print('📧 Email: ${user.email ?? 'Unknown'}');

      if (fcmToken != null) {
        print('🔔 FCM Token berhasil disimpan ke database');
      }

      // 4. Navigate ke home page
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      }
    } catch (e) {
      print('❌ Error during login: $e');

      // Ambil pesan error
      String errorMessage = e.toString();

      // Hapus prefix "Exception: " jika ada
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.substring('Exception: '.length);
      }

      print('📝 Error message: $errorMessage');

      // Tampilkan dialog error dengan pesan dari AuthService
      if (mounted) {
        _showErrorDialog(errorMessage);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),
              Center(
                child: Image.asset('assets/logo_tirtha_app.png', height: 200),
              ),
              const SizedBox(height: 5),
              const Text(
                'Email',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              AppTextField(
                hintText: 'Masukkan email',
                controller: _emailController,
                prefixIcon: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Icon(Icons.person_outline, color: AppColors.primary),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Password',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              PasswordTextField(
                hintText: 'Password',
                controller: _passwordController,
                prefixIcon: const Icon(Icons.lock),
              ),
              // const SizedBox(height: 8),
              // Align(
              //   alignment: Alignment.centerRight,
              //   child: TextButton(
              //     onPressed: () {},
              //     child: const Text(
              //       'Lupa Password',
              //       style: TextStyle(color: AppColors.primary),
              //     ),
              //   ),
              // ),

              const SizedBox(height: 24),
              AppButton(
                text: _isLoading ? 'Loading...' : 'MASUK',
                onPressed: _isLoading ? () {} : _handleLogin,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Belum Punya Akun? ',
                    style: TextStyle(color: AppColors.textPrimary),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.register);
                    },
                    child: const Text(
                      'BUAT AKUN',
                      style: TextStyle(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}