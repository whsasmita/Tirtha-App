import 'package:flutter/material.dart';
import 'package:tirtha_app/presentation/themes/color.dart';

class HomeHeader extends StatelessWidget {
  final String title;
  final Color backgroundColor;
  final String illustrationPath;

  const HomeHeader({
    Key? key,
    required this.title,
    required this.backgroundColor,
    required this.illustrationPath,
  }) : super(key: key);

  final List<String> _miniIcons = const [
    'pil.png', 'heart.png', 'temperature.png', 'IconDoctor.png', 'pil.png',
  ];

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: Container(
        height: 150,
        color: backgroundColor,
        child: Stack(
          children: [
            Positioned(
              left: -20,
              bottom: 0,
              child: Image.asset(
                illustrationPath,
                height: 150,
                fit: BoxFit.fitHeight,
                errorBuilder: (context, error, stackTrace) {
                  return const SizedBox.shrink(); // Hide image if it fails to load
                },
              ),
            ),
            Positioned(
              right: 16,
              top: 16,
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            Positioned(
              bottom: 10,
              right: 10,
              left: 160,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: _miniIcons.map((iconName) {
                  return Container(
                    width: 35,
                    height: 35,
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Image.asset(
                      'assets/$iconName',
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.error, color: AppColors.tertiary, size: 20);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}