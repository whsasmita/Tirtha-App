import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tirtha_app/presentation/themes/color.dart';
import 'package:tirtha_app/presentation/widgets/top_bar.dart';
import 'package:tirtha_app/presentation/widgets/bottom_nav_v1.dart';
import 'package:tirtha_app/presentation/widgets/grid_item_card.dart';
import 'package:tirtha_app/presentation/widgets/home_header.dart';

class EducationPage extends StatelessWidget {
  const EducationPage({Key? key}) : super(key: key);

  final List<Map<String, String>> educationItems = const [
    {
      'title': 'Komunikasi & Edukasi Penting Bagi Masyarakat',
      'image': 'assets/thumbnail_education.png',
      'url': 'https://www.youtube.com/watch?v=youtube_link_1',
    },
    {
      'title': 'Pentingnya Kepatuhan Cairan dalam Hemodialisis',
      'image': 'assets/thumbnail_education.png',
      'url': 'https://www.youtube.com/watch?v=youtube_link_2',
    },
    {
      'title': 'Gaya Hidup Sehat untuk Pasien Gagal Ginjal',
      'image': 'assets/thumbnail_education.png',
      'url': 'https://www.youtube.com/watch?v=youtube_link_3',
    },
  ];

  void _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      print('Could not launch $url');
    }
  }

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
              title: 'EDUKASI KESEHATAN',
              backgroundColor: AppColors.secondary,
              illustrationPath: 'assets/doctor.png', // Ilustrasi dokter untuk edukasi
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
                    color: AppColors.tertiary,
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
              itemCount: educationItems.length * 3,
              itemBuilder: (context, index) {
                final item = educationItems[index % educationItems.length];
                return GridItemCard(
                  imageUrl: item['image']!,
                  title: item['title']!,
                  onTap: () => _launchURL(item['url']!),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavV1(
        selectedIndex: 1,
        onItemTapped: (index) {
          // TODO: Tambahkan logika navigasi untuk BottomNavV2 di sini
        },
      ),
    );
  }
}