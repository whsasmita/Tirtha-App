// File: profile_page.dart (Diperbarui)

import 'package:flutter/material.dart';
import 'package:tirtha_app/presentation/themes/color.dart';
import 'package:tirtha_app/presentation/widgets/bottom_nav_v1.dart';
import 'package:tirtha_app/presentation/widgets/bottom_nav_v2.dart';
import 'package:tirtha_app/presentation/widgets/top_bar.dart';
import 'package:tirtha_app/presentation/widgets/info_card.dart';
import 'package:tirtha_app/routes/app_routes.dart';
import 'package:tirtha_app/core/services/auth_service.dart';
import 'package:tirtha_app/core/services/education_service.dart';
import 'package:tirtha_app/core/services/quiz_service.dart';
import 'package:tirtha_app/data/models/user_model.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _selectedIndex = 2;
  final AuthService _authService = AuthService();
  final AuthService _profileService = AuthService();
  final EducationService _educationService = EducationService();
  final QuizService _quizService = QuizService();

  Future<UserModel>? _getUserProfile;
  Future<int>? _educationCount;
  Future<int>? _quizCount;

  @override
  void initState() {
    super.initState();
    _getUserProfile = _profileService.getUserProfile();
  }

  Future<int> _getEducationCount() async {
    try {
      // Memanggil API dengan fetchAllEducations, perlu dipastikan API mengembalikan total count
      // atau mengimplementasikan fetchEducationsWithMeta jika API mendukung pagination meta data.
      final educations = await _educationService.fetchAllEducations();
      return educations.length;
    } catch (e) {
      return 0;
    }
  }

  Future<int> _getQuizCount() async {
    try {
      final quizzes = await _quizService.fetchAllQuizzes();
      return quizzes.length;
    } catch (e) {
      return 0;
    }
  }

  void _onItemTappedUser(int index) {
    setState(() => _selectedIndex = index);

    if (index == 0) {
      Navigator.pushNamed(context, AppRoutes.home);
    } else if (index == 1) {
      Navigator.pushNamed(context, AppRoutes.listEducation);
    } else if (index == 2) {
      // Halaman profil
    }
  }

  void _onItemTappedAdmin(int index) {
    setState(() => _selectedIndex = index);

    if (index == 0) {
      Navigator.pushNamed(context, AppRoutes.home);
    } else if (index == 1) {
      Navigator.pushNamed(context, AppRoutes.educationDashboard);
    } else if (index == 2) {
      Navigator.pushNamed(context, AppRoutes.quizDashboard);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserModel>(
      future: _getUserProfile,
      builder: (context, snapshot) {
        Widget bottomNav = const SizedBox.shrink();

        if (snapshot.hasData) {
          final role = snapshot.data!.role ?? 'user';
          if (role == 'admin') {
            bottomNav = BottomNavV2(
              // Asumsi index 0 adalah yang aktif saat di halaman Profile/Dashboard Admin
              selectedIndex: 0, 
              onItemTapped: _onItemTappedAdmin,
            );
          } else {
            bottomNav = BottomNavV1(
              selectedIndex: _selectedIndex,
              onItemTapped: _onItemTappedUser,
            );
          }
        }

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: const TopBar(),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 24.0,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: _buildProfileHeader(snapshot),
                ),
                const SizedBox(height: 24),
                
                if (snapshot.hasData && snapshot.data!.role == 'admin') ...[
                  const Center(
                    child: Text(
                      'Dashboard',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // Card Edukasi
                      FutureBuilder<int>(
                        future: _getEducationCount(),
                        builder: (context, eduSnapshot) {
                          String count = '0';
                          
                          if (eduSnapshot.connectionState == ConnectionState.waiting) {
                            count = '...';
                          } else if (eduSnapshot.hasError) {
                            count = '0';
                            print('Error education count: ${eduSnapshot.error}');
                          } else if (eduSnapshot.hasData) {
                            count = eduSnapshot.data.toString();
                          }
                          
                          // Hapus GestureDetector pembungkus!
                          return InfoCard(
                            title: 'EDUKASI',
                            count: count,
                            backgroundColor: AppColors.secondary,
                            // Langsung berikan logic navigasi ke onPressed InfoCard
                            onPressed: () {
                              Navigator.pushNamed(
                                  context, AppRoutes.educationDashboard);
                            },
                          );
                        },
                      ),
                      
                      // Card Kuis
                      FutureBuilder<int>(
                        future: _getQuizCount(),
                        builder: (context, quizSnapshot) {
                          String count = '0';
                          
                          if (quizSnapshot.connectionState == ConnectionState.waiting) {
                            count = '...';
                          } else if (quizSnapshot.hasError) {
                            count = '0';
                            print('Error quiz count: ${quizSnapshot.error}');
                          } else if (quizSnapshot.hasData) {
                            count = quizSnapshot.data.toString();
                          }
                          
                          // Hapus GestureDetector pembungkus!
                          return InfoCard(
                            title: 'KUIS',
                            count: count,
                            backgroundColor: AppColors.tertiary,
                            // Langsung berikan logic navigasi ke onPressed InfoCard
                            onPressed: () {
                              Navigator.pushNamed(
                                  context, AppRoutes.quizDashboard);
                            },
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
                
                // Card "Tentang Kami"
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.about);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Tentang Kami',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Divider(),
                        Text('V 1.0'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Tombol Keluar
                ElevatedButton(
                  onPressed: () {
                    // Pastikan pushNamed ke AppRoutes.preview dilakukan sebelum logout
                    // agar riwayat navigasi terhapus sebelum pindah ke halaman login/preview.
                    _authService.logout(); // Panggil logout service
                    Navigator.pushNamedAndRemoveUntil(
                      context, 
                      AppRoutes.preview, 
                      (Route<dynamic> route) => false, // Hapus semua route sebelumnya
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout, color: Colors.white),
                      SizedBox(width: 10),
                      Text(
                        'KELUAR',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: bottomNav,
        );
      },
    );
  }

  Widget _buildProfileHeader(AsyncSnapshot<UserModel> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(
          child: CircularProgressIndicator(color: Colors.white));
    } else if (snapshot.hasError) {
      return Center(
        child: Text(
          'Gagal memuat data: ${snapshot.error}',
          style: const TextStyle(color: Colors.white),
        ),
      );
    } else if (snapshot.hasData) {
      final user = snapshot.data!;
      return Column(
        children: [
          const Text(
            'PROFIL SAYA',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const CircleAvatar(
                radius: 40,
                backgroundColor: Colors.white,
                backgroundImage: AssetImage('assets/doctor.png'),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name.toString(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    user.role ?? "Role tidak tersedia",
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 30,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.tertiary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding:
                            const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      child: const Text(
                        'Edit Profil',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      );
    } else {
      return const Center(
        child: Text(
          'Tidak ada data profil.',
          style: TextStyle(color: Colors.white),
        ),
      );
    }
  }
}