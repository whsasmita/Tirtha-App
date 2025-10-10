import 'package:flutter/material.dart';
import 'package:tirtha_app/presentation/themes/color.dart';
import 'package:tirtha_app/presentation/widgets/top_bar.dart';
import 'package:tirtha_app/presentation/widgets/bottom_nav_v2.dart';
import 'package:tirtha_app/presentation/widgets/home_header.dart';
import 'package:tirtha_app/routes/app_routes.dart';

class QuizDashboardPage extends StatefulWidget {
  const QuizDashboardPage({super.key});

  @override
  State<QuizDashboardPage> createState() => _QuizDashboardPageState();
}

class _QuizDashboardPageState extends State<QuizDashboardPage> {
  int _selectedIndex = 2;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      Navigator.pushNamed(context, AppRoutes.profile);
    } else if (index == 1) {
      Navigator.pushNamed(context, AppRoutes.educationDashboard);
    } else if (index == 2) {
      // Tetap di halaman ini
    }
  }

  Widget _buildQuizTable() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              color: Colors.grey.shade100,
            ),
            child: const IntrinsicHeight(
              child: Row(
                children: [
                  SizedBox(width: 40, child: Text('No', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
                  Expanded(child: Padding(padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0), child: Text('Nama', style: TextStyle(fontWeight: FontWeight.bold)))),
                  SizedBox(width: 100, child: Text('Link', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
                ],
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300)),
            child: const IntrinsicHeight(
              child: Row(
                children: [
                  SizedBox(width: 40, child: Text('1', textAlign: TextAlign.center)),
                  Expanded(child: Padding(padding: EdgeInsets.all(8.0), child: Text('Edukasi 1'))),
                  SizedBox(width: 100, child: Text('Klik disini', style: TextStyle(color: AppColors.secondary, decoration: TextDecoration.underline))),
                ],
              ),
            ),
          ),
        ],
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
                title: 'KUIS KESEHATAN',
                backgroundColor: AppColors.tertiary,
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
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade300)),
                      child: const TextField(decoration: InputDecoration(hintText: 'cari edukasi disini', hintStyle: TextStyle(color: Colors.grey), prefixIcon: Icon(Icons.search, color: Colors.grey), border: InputBorder.none, contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 10))),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(color: AppColors.tertiary, borderRadius: BorderRadius.circular(10)),
                    child: IconButton(icon: const Icon(Icons.filter_list, color: Colors.white), onPressed: () {}),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildQuizTable(),
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavV2(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}