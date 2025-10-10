import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tirtha_app/presentation/themes/color.dart';
import 'package:tirtha_app/presentation/widgets/top_bar.dart';
import 'package:tirtha_app/presentation/widgets/bottom_nav_v1.dart';
import 'package:tirtha_app/presentation/widgets/grid_item_card.dart';
import 'package:tirtha_app/presentation/widgets/home_header.dart';
import 'package:tirtha_app/routes/app_routes.dart';

class EducationListPage extends StatefulWidget {
  const EducationListPage({super.key});

  @override
  State<EducationListPage> createState() => _EducationDashboardPageState();
}

class _EducationDashboardPageState extends State<EducationListPage> {
  int _selectedIndex = 1;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      
    } else if (index == 1) {
      // Tetap di halaman ini
    } else if (index == 2) {
      Navigator.pushNamed(context, AppRoutes.profile);
    }
  }

  final List<Map<String, String>> educationItems = const [
    {
      'title': 'Edukasi 1',
      'image': 'assets/thumbnail_yt.png',
      'url': 'https://youtu.be/GNbFOhuOjlY?si=Ugz_N07ia7LyFR5H',
    },
    {
      'title': 'Edukasi 2',
      'image': 'assets/thumbnail_yt.png',
      'url': 'https://youtu.be/GNbFOhuOjlY?si=Ugz_N07ia7LyFR5H',
    },
    {
      'title': 'Edukasi 3',
      'image': 'assets/thumbnail_yt.png',
      'url': 'https://youtu.be/GNbFOhuOjlY?si=Ugz_N07ia7LyFR5H',
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
              illustrationPath:
                  'assets/doctor.png',
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
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 10,
                        ),
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
                childAspectRatio: 1.4,
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
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
