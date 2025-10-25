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
    this.aspectRatio = 0.75, // Menggunakan rasio 0.9 yang sudah diperbaiki
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
        // Column dibatasi oleh tinggi GridView
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          // Menggunakan MainAxisSize.min memastikan Column tidak mengambil ruang vertikal lebih dari yang dibutuhkan.
          // Meskipun di GridView, batasan ini sudah dipaksakan dari luar, penggunaan ini adalah praktik yang baik.
          mainAxisSize: MainAxisSize.min, 
          children: [
            // 3. Header Gambar dengan AspectRatio
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
            // Padding dan Text ini kemungkinan yang menyebabkan overflow jika terlalu tinggi.
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                title,
                textAlign: TextAlign.start,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                  // Teks ini memiliki batasan 2 baris
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            
            // HAPUS SizedBox(height: 4) yang berisiko menyebabkan overflow
            // const SizedBox(height: 4), 
          ],
        ),
      ),
    );
  }
}