import 'package:flutter/material.dart';
import 'package:tirtha_app/presentation/widgets/app_button.dart';
import 'package:tirtha_app/presentation/widgets/app_text_field.dart';
import 'package:tirtha_app/presentation/themes/color.dart';
import 'package:tirtha_app/routes/app_routes.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({Key? key}) : super(key: key);

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

            Center(child: Image.asset('assets/logo_tirtha_app.png', height: 280)),
            const SizedBox(height: 5),

            const Text(
              'Nama Lengkap',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const AppTextField(
              hintText: 'Masukkan nama lengkap anda',
              prefixIcon: Icon(Icons.person_outline, color: AppColors.primary),
            ),
            const SizedBox(height: 24),

            const Text(
              'Email',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const AppTextField(
              hintText: 'Masukkan email anda',
              prefixIcon: Icon(Icons.email_outlined, color: AppColors.primary),
            ),
            const SizedBox(height: 24),

            const Text(
              'No HP (WhatsApp)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const AppTextField(
              hintText: 'Masukkan nomor telepon',
              prefixIcon: Icon(Icons.phone_outlined, color: AppColors.primary),
            ),
            const SizedBox(height: 24),

            const Text(
              'Password',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const AppTextField(
              hintText: 'Masukkan password',
              obscureText: true,
              prefixIcon: Icon(Icons.lock_outline, color: AppColors.primary),
              suffixIcon: Icon(Icons.visibility, color: AppColors.primary),
            ),
            const SizedBox(height: 24),

            AppButton(
              text: 'DAFTAR',
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.login);
              },
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
