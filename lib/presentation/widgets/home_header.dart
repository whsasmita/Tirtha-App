import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget {
  final String title;
  final Color backgroundColor;
  final String illustrationPath;
  static const double sizeImage = 35;
  static const double sizeBox = 50;

  const HomeHeader({
    Key? key,
    required this.title,
    required this.backgroundColor,
    required this.illustrationPath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Stack(
        children: [
          Positioned(
            left: -20,
            bottom: 0,
            child: Image.asset(
              illustrationPath,
              height: 170,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const SizedBox.shrink();
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
                fontSize: 20,
              ),
            ),
          ),
          Positioned(
            bottom: 45,
            right: 10,
            left: 150,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: Image.asset(
                        "assets/pil.png",
                        height: sizeImage,
                        width: sizeImage,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(width: sizeBox),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: Image.asset(
                        "assets/temperature.png",
                        height: sizeImage,
                        width: sizeImage,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(width: sizeBox),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: Image.asset(
                        "assets/obat.png",
                        height: sizeImage,
                        width: sizeImage,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 25,
            right: 10,
            left: 142,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    SizedBox(width: sizeBox),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: Image.asset(
                        "assets/heart.png",
                        height: sizeImage,
                        width: sizeImage,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(width: sizeBox),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: Image.asset(
                        "assets/virus.png",
                        height: sizeImage,
                        width: sizeImage,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(width: sizeBox),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
