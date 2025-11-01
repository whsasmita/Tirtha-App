import 'package:flutter/material.dart';

class InfoCard extends StatelessWidget {
  final String title;
  final String count;
  final Color backgroundColor;
  final VoidCallback? onPressed; // Sudah Opsional (Bagus!)

  const InfoCard({
    Key? key,
    required this.title,
    required this.count,
    required this.backgroundColor,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Tentukan lebar card: full width jika onPressed null, 150 jika ada
    final double cardWidth = onPressed == null ? double.infinity : 150; 
    
    return Container(
      // Menggunakan lebar yang ditentukan
      width: cardWidth, 
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            count,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 36,
            ),
          ),
          
          // Logika Baru: Hanya tampilkan tombol jika onPressed tidak null
          if (onPressed != null) ...[ 
            const SizedBox(height: 8),
            Container(
              // Wrap dengan GestureDetector agar seluruh area tombol bisa diklik
              child: GestureDetector(
                onTap: onPressed, // Memanggil fungsi yang diberikan
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min, // Agar tidak memaksa lebar jika full width
                    children: [
                      Text(
                        'Lihat Detail',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}