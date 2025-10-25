import 'package:flutter/material.dart';
import 'package:tirtha_app/presentation/themes/color.dart';

class GridItemCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final VoidCallback? onTap;
  final double aspectRatio;

  const GridItemCard({
    Key? key,
    required this.imageUrl,
    required this.title,
    this.onTap,
    this.aspectRatio = 0.75, // Default disesuaikan untuk card lebih tinggi
  }) : super(key: key);

  bool get _isNetworkImage => imageUrl.startsWith('http') || imageUrl.startsWith('https');

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Gambar dengan AspectRatio
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
                child: _isNetworkImage
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey.shade200,
                            child: const Center(
                              child: Icon(Icons.broken_image, color: AppColors.primary),
                            ),
                          );
                        },
                      )
                    : Image.asset(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey.shade200,
                            child: const Center(
                              child: Icon(Icons.image_not_supported, color: AppColors.primary),
                            ),
                          );
                        },
                      ),
              ),
            ),
            
            // Container untuk text dengan batasan tinggi
            Container(
              padding: const EdgeInsets.all(8.0),
              constraints: const BoxConstraints(
                minHeight: 40, // Tinggi minimum untuk text
                maxHeight: 50, // Batasi tinggi maksimum
              ),
              child: Center(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}