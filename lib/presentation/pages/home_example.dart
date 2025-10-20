import 'package:flutter/material.dart';
import 'package:tirtha_app/presentation/widgets/top_bar.dart'; 
import 'package:tirtha_app/presentation/widgets/bottom_nav_v1.dart';
import 'package:tirtha_app/routes/app_routes.dart';

class HomeExample extends StatefulWidget {
  const HomeExample({super.key});

  @override
  State<HomeExample> createState() => _HomeExampleState();
}

class _HomeExampleState extends State<HomeExample> {
  int _selectedIndex = 0; 

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      // Tetap di halaman ini
    } else if (index == 1) {
      Navigator.pushNamed(context, AppRoutes.listEducation); 
    } else if (index == 2) {
      Navigator.pushNamed(context, AppRoutes.profile);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      
      appBar: const TopBar(),
      
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Selamat Datang di Halaman Home",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                "Halaman ini hanya berisi teks sederhana.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
      
      bottomNavigationBar: BottomNavV1(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}