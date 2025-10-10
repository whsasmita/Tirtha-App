import 'package:flutter/material.dart';
import 'package:tirtha_app/presentation/themes/color.dart';
import 'package:tirtha_app/presentation/widgets/top_bar.dart';
import 'package:tirtha_app/presentation/widgets/bottom_nav_v2.dart';
import 'package:tirtha_app/presentation/widgets/home_header.dart';
import 'package:tirtha_app/routes/app_routes.dart';

class EducationDashboardPage extends StatefulWidget {
  const EducationDashboardPage({super.key});

  @override
  State<EducationDashboardPage> createState() => _EducationDashboardPageState();
}

class _EducationDashboardPageState extends State<EducationDashboardPage> {
  int _selectedIndex = 1;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      Navigator.pushNamed(context, AppRoutes.profile);
    } else if (index == 1) {
      // Tetap di halaman ini
    } else if (index == 2) {
      Navigator.pushNamed(context, AppRoutes.quizDashboard);
    }
  }

  Widget _buildEducationTableItem(
    BuildContext context,
    String no,
    String name,
    String link,
  ) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            SizedBox(width: 40, child: Text(no, textAlign: TextAlign.center)),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(name),
              ),
            ),
            Container(
              width: 100,
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 8.0,
              ),
              child: Text(
                link,
                style: const TextStyle(
                  color: Colors.black,
                  decorationColor: AppColors.secondary,
                ),
              ),
            ),

            IconButton(
              icon: const Icon(Icons.edit, size: 20, color: AppColors.primary),
              onPressed: () {
                // TODO: Logika untuk mengedit item
              },
            ),
            IconButton(
              icon: const Icon(
                Icons.delete_outline,
                size: 20,
                color: Colors.red,
              ),
              onPressed: () {
                // TODO: Logika untuk menghapus item
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const TopBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: HomeHeader(
                title: 'DASHBOARD EDUKASI',
                backgroundColor: AppColors.secondary,
                illustrationPath: 'assets/doctor.png',
              ),
            ),
            const SizedBox(height: 20),
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
            const SizedBox(height: 20),
            _buildEducationTableItem(context, 'No', 'Nama', 'Link'),
            _buildEducationTableItem(context, '1', 'Edukasi 1', 'Klik disini'),
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavV2(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.createEducation);
        },
        backgroundColor: AppColors.secondary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
