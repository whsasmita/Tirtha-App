import 'package:flutter/material.dart';
import 'package:tirtha_app/presentation/themes/color.dart';
import 'package:tirtha_app/presentation/widgets/top_bar.dart';
import 'package:tirtha_app/presentation/widgets/bottom_nav_v1.dart';
import 'package:tirtha_app/presentation/widgets/grid_item_card.dart';
import 'package:tirtha_app/presentation/widgets/home_header.dart';

class QuizPage extends StatelessWidget {
  const QuizPage({Key? key}) : super(key: key);

  final List<Map<String, String>> quizItems = const [
    {
      'title': 'Kuis Tirtha tentang penyakit tubuh dan cairan',
      'image': 'assets/quiz.jpg',
    },
    {
      'title': 'Kuis Tirtha tentang penyakit tubuh dan cairan',
      'image': 'assets/quiz.jpg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const TopBar(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: HomeHeader(
              title: 'KUIS KESEHATAN',
              backgroundColor: AppColors.tertiary,
              illustrationPath: 'assets/doctor.png',
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: const TextField(
                      decoration: InputDecoration(
                        hintText: 'cari edukasi disini',
                        hintStyle: TextStyle(color: Colors.grey),
                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.secondary, // Warna hijau
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.filter_list, color: Colors.white),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                childAspectRatio: 0.7,
              ),
              itemCount: quizItems.length * 3,
              itemBuilder: (context, index) {
                final item = quizItems[index % quizItems.length];
                return GridItemCard(
                  imageUrl: item['image']!,
                  title: item['title']!,
                  onTap: null,
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavV1(
        selectedIndex: 2,
        onItemTapped: (index) {
          // TODO: Tambahkan logika navigasi untuk BottomNavV2 di sini
        },
      ),
    );
  }
}