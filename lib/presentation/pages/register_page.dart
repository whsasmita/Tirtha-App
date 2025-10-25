import 'package:flutter/material.dart';
import 'package:tirtha_app/presentation/widgets/app_button.dart';
import 'package:tirtha_app/presentation/widgets/app_text_field.dart';
import 'package:tirtha_app/presentation/widgets/password_text_field.dart';
import 'package:tirtha_app/presentation/themes/color.dart';
import 'package:tirtha_app/routes/app_routes.dart';
import 'package:tirtha_app/core/services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _konfirmasiPasswordController = TextEditingController();

  final AuthService _authService = AuthService();

  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    _passwordController.dispose();
    _konfirmasiPasswordController.dispose();
    super.dispose();
  }

  /// Menampilkan dialog error dengan styling yang lebih friendly
  void _showErrorDialog(String message) {
    String title = 'Terjadi Kesalahan';
    IconData icon = Icons.error_outline;
    Color iconColor = Colors.red;
    Color buttonColor = Colors.red;

    // Deteksi jenis error dan sesuaikan UI
    if (message.toLowerCase().contains('email') && 
        (message.toLowerCase().contains('sudah terdaftar') || 
         message.toLowerCase().contains('sudah digunakan') ||
         message.toLowerCase().contains('duplicate'))) {
      title = 'Email Sudah Terdaftar';
      icon = Icons.email_outlined;
      iconColor = Colors.orange;
      buttonColor = AppColors.secondary;
    } else if (message.toLowerCase().contains('nomor telepon') && 
               message.toLowerCase().contains('sudah terdaftar')) {
      title = 'Nomor Telepon Sudah Terdaftar';
      icon = Icons.phone_outlined;
      iconColor = Colors.orange;
      buttonColor = AppColors.secondary;
    } else if (message.toLowerCase().contains('password tidak sama') ||
        message.toLowerCase().contains('konfirmasi password')) {
      title = 'Password Tidak Sama';
      icon = Icons.lock_outline;
      iconColor = Colors.orange;
      buttonColor = AppColors.tertiary;
    } else if (message.toLowerCase().contains('tidak lengkap') ||
        message.toLowerCase().contains('tidak boleh kosong') ||
        message.toLowerCase().contains('wajib diisi')) {
      title = 'Input Tidak Lengkap';
      icon = Icons.warning_amber_rounded;
      iconColor = Colors.orange;
      buttonColor = AppColors.tertiary;
    } else if (message.toLowerCase().contains('password') &&
        message.toLowerCase().contains('minimal')) {
      title = 'Password Terlalu Pendek';
      icon = Icons.lock_outline;
      iconColor = Colors.orange;
      buttonColor = AppColors.tertiary;
    } else if (message.toLowerCase().contains('format') &&
        message.toLowerCase().contains('email')) {
      title = 'Format Email Salah';
      icon = Icons.email_outlined;
      iconColor = Colors.orange;
      buttonColor = AppColors.tertiary;
    } else if (message.toLowerCase().contains('koneksi') ||
        message.toLowerCase().contains('jaringan')) {
      title = 'Masalah Koneksi';
      icon = Icons.wifi_off;
    } else if (message.toLowerCase().contains('server')) {
      title = 'Server Bermasalah';
      icon = Icons.cloud_off;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding: EdgeInsets.zero,
          content: Container(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon dengan background circle
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
                const SizedBox(height: 20),
                
                // Title
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                
                // Message
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonColor,
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
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Menampilkan dialog sukses
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding: EdgeInsets.zero,
          content: Container(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Success Icon
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_outline,
                    color: Colors.green,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 20),
                
                // Title
                const Text(
                  'Registrasi Berhasil!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                
                // Message
                Text(
                  'Akun Anda berhasil dibuat.\nSilakan login untuk melanjutkan.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.pushReplacementNamed(context, AppRoutes.login);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Lanjut ke Login',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
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
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phoneNumber = _phoneNumberController.text.trim();
    final password = _passwordController.text.trim();
    final konfirmasiPassword = _konfirmasiPasswordController.text.trim();

    // Validasi input kosong
    if (name.isEmpty) {
      _showErrorDialog('Nama lengkap wajib diisi.');
      return;
    }

    if (email.isEmpty) {
      _showErrorDialog('Email wajib diisi.');
      return;
    }

    if (phoneNumber.isEmpty) {
      _showErrorDialog('Nomor telepon wajib diisi.');
      return;
    }

    if (password.isEmpty) {
      _showErrorDialog('Password wajib diisi.');
      return;
    }

    if (konfirmasiPassword.isEmpty) {
      _showErrorDialog('Konfirmasi password wajib diisi.');
      return;
    }

    // Validasi format email
    if (!email.contains('@') || !email.contains('.')) {
      _showErrorDialog('Format email tidak valid. Gunakan format yang benar (contoh: nama@email.com).');
      return;
    }

    // Validasi panjang password
    if (password.length < 6) {
      _showErrorDialog('Password minimal 6 karakter untuk keamanan akun Anda.');
      return;
    }

    // Validasi password match
    if (password != konfirmasiPassword) {
      _showErrorDialog('Konfirmasi password tidak sama dengan password yang Anda masukkan.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final String timezone = _getDeviceTimezone();
      
      print('📤 Request: {name: $name, email: $email, password: $password, timezone: $timezone, phone_number: $phoneNumber}');

      await _authService.register(
        name,
        email,
        password,
        timezone,
        phoneNumber,
      );

      if (mounted) {
        _showSuccessDialog();
      }
    } catch (e) {
      print('❌ Error during registration: $e');
      
      String errorMessage = e.toString();
      
      // Hapus prefix "Exception: " jika ada
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.substring('Exception: '.length);
      }
      
      print('📝 Error message: $errorMessage');
      
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
                'Nama Lengkap',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              AppTextField(
                hintText: 'Masukkan nama lengkap anda',
                controller: _nameController,
                prefixIcon: const Icon(Icons.person_outline, color: AppColors.primary),
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
                prefixIcon: const Icon(Icons.email_outlined, color: AppColors.primary),
              ),
              const SizedBox(height: 24),

              const Text(
                'Nomor Telepon',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              AppTextField(
                hintText: 'Masukkan nomor telepon anda',
                controller: _phoneNumberController,
                keyboardType: TextInputType.phone,
                prefixIcon: const Icon(Icons.phone_outlined, color: AppColors.primary),
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
              const SizedBox(height: 24),
              
              const Text(
                'Konfirmasi Password',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              PasswordTextField(
                hintText: 'Konfirmasi Password',
                controller: _konfirmasiPasswordController,
                prefixIcon: const Icon(Icons.lock),
              ),
              const SizedBox(height: 24),

              AppButton(
                text: _isLoading ? 'Mendaftar...' : 'DAFTAR',
                onPressed: _isLoading ? () {} : _handleRegister,
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
      ),
    );
  }
}