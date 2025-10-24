import 'package:flutter/material.dart';
import 'package:tirtha_app/presentation/themes/color.dart';

class GridItemCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final VoidCallback? onTap;
  // 1. Tambahkan parameter aspectRatio dengan nilai default
  final double aspectRatio; 

  const GridItemCard({
    Key? key,
    required this.imageUrl,
    required this.title,
    this.onTap,
    // 2. Tambahkan ke constructor
    this.aspectRatio = 1.4, // Nilai default 1.4 sesuai GridView di EducationListPage
  }) : super(key: key);

  // Helper untuk menentukan apakah URL adalah URL web atau path asset lokal
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
            // 3. Ganti Expanded dengan AspectRatio
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
              child: AspectRatio(
                aspectRatio: aspectRatio, // Menerapkan rasio dari luar
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
            
            // Teks Judul
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                title,
                textAlign: TextAlign.start,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}