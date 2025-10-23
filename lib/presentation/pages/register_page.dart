import 'package:flutter/material.dart';
import 'package:tirtha_app/presentation/widgets/app_button.dart';
import 'package:tirtha_app/presentation/widgets/app_text_field.dart';
import 'package:tirtha_app/presentation/widgets/password_text_field.dart';
import 'package:tirtha_app/presentation/themes/color.dart';
import 'package:tirtha_app/routes/app_routes.dart';
import 'package:tirtha_app/core/services/auth_service.dart';
import 'package:timezone/timezone.dart' as tz;

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _konfirmasiPasswordController =
      TextEditingController();

  final AuthService _authService = AuthService();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _konfirmasiPasswordController.dispose();
    super.dispose();
  }

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

  Future<void> _handleRegister() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    if (_passwordController.text != _konfirmasiPasswordController.text) {
      setState(() {
        _errorMessage = "Konfirmasi Password Tidak Sama";
        _isLoading = false;
      });
      return;
    } else {
      try {
        final name = _nameController.text.trim();
        final email = _emailController.text.trim();
        final password = _passwordController.text.trim();
        
        final String timezone = _getDeviceTimezone();
        
        print('Timezone detected: $timezone');

        await _authService.register(name, email, password, timezone);

        if (mounted) {
          Navigator.pushReplacementNamed(context, AppRoutes.login);
        }
      } catch (e) {
        setState(() {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
      } finally {
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 80),

            Center(
              child: Image.asset('assets/logo_tirtha_app.png', height: 200),
            ),
            const SizedBox(height: 5),

            const Text(
              'Nama Lengkap',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            AppTextField(
              hintText: 'Masukkan nama lengkap anda',
              controller: _nameController,
              prefixIcon: Icon(Icons.person_outline, color: AppColors.primary),
            ),
            const SizedBox(height: 24),

            const Text(
              'Email',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            AppTextField(
              hintText: 'Masukkan email anda',
              controller: _emailController,
              prefixIcon: Icon(Icons.email_outlined, color: AppColors.primary),
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
              prefixIcon: Icon(Icons.lock),
            ),
            const SizedBox(height: 24),
            const Text(
              'Konfirmasi Password',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            PasswordTextField(
              hintText: 'Konfirmasi Password',
              controller: _konfirmasiPasswordController,
              prefixIcon: Icon(Icons.lock),
            ),
            const SizedBox(height: 24),

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
              text: _isLoading ? 'Loading...' : 'DAFTAR',
              onPressed: _handleRegister,
            ),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Sudah Punya Akun? ',
                  style: TextStyle(color: AppColors.textPrimary),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.login);
                  },
                  child: const Text(
                    'MASUK',
                    style: TextStyle(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}