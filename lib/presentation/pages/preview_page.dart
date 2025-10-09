import 'package:flutter/material.dart';
import 'package:tirtha_app/presentation/themes/color.dart';
import 'package:tirtha_app/presentation/widgets/app_button.dart';
import 'package:tirtha_app/routes/app_routes.dart';

class PreviewPage extends StatelessWidget {
  const PreviewPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            SizedBox(height: screenHeight * 0.15),

            Center(
              child: Image.asset(
                'assets/IconDoctor.png',
                height: screenHeight * 0.4,
                fit: BoxFit.contain,
              ),
            ),

            SizedBox(height: screenHeight * 0.1),

            RichText(
              textAlign: TextAlign.center,
              text: const TextSpan(
                style: TextStyle(
                  fontSize: 22,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
                children: <TextSpan>[
                  TextSpan(text: 'Selamat Datang di '),
                  TextSpan(
                    text: 'TIRTHA',
                    style: TextStyle(color: AppColors.secondary),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            const Text(
              'Lorem ipsum sit dolor amet. adiscipiling elit lorem ipppsum site sakalk sakksallaasaas',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey, height: 1.5),
            ),

            const Spacer(),

            AppButton(
              text: 'SELANJUTNYA',
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.login);
              },
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
