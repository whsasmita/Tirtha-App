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
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Mendapatkan FCM Token dari Firebase
  Future<String?> _getFcmToken() async {
    try {
      String? token = await FirebaseMessaging.instance.getToken();
      
      if (token != null) {
        print('╔════════════════════════════════════════╗');
        print('║          FCM TOKEN BERHASIL            ║');
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

  /// Handle Login dengan FCM Token
  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // Validasi input
    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Email dan Password tidak boleh kosong.';
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
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

      // 2. Login dengan email, password, dan FCM token
      print('🔄 Proses login ke server...');
      final user = await _authService.login(email, password, fcmToken);

      print('✅ Login berhasil!');
      print('👤 User: ${user.name ?? 'Unknown'}');
      print('📧 Email: ${user.email ?? 'Unknown'}');
      
      if (fcmToken != null) {
        print('🔔 FCM Token berhasil disimpan ke database');
      }

      // 3. Navigate ke home page
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      }
    } catch (e) {
      print('❌ Error during login: $e');
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 80),
            Center(
              child: Image.asset('assets/logo_tirtha_app.png', height: 280),
            ),
            const SizedBox(height: 5),
            const Text(
              'Email / No HP',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            AppTextField(
              hintText: 'Masukkan email / nomor telepon',
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
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {},
                child: const Text(
                  'Lupa Password',
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
            ),

            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
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
          ],
        ),
      ),
    );
  }
}