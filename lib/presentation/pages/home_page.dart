import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tirtha_app/presentation/widgets/bottom_nav_v1.dart';
import 'package:tirtha_app/presentation/widgets/top_bar.dart';
import 'package:tirtha_app/presentation/widgets/grid_item_card.dart';
import 'package:tirtha_app/routes/app_routes.dart';
import '../widgets/menu_header.dart';
import '../widgets/section_home_card.dart';
// Import service dan model Anda
import 'package:tirtha_app/data/models/education_model.dart';
import 'package:tirtha_app/data/models/quiz_model.dart';
import 'package:tirtha_app/core/services/education_service.dart';
import 'package:tirtha_app/core/services/quiz_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  
  // State untuk education
  List<EducationModel> educationItems = [];
  bool isLoadingEducation = true;
  String? educationError;
  
  // State untuk quiz
  List<QuizModel> quizItems = [];
  bool isLoadingQuiz = true;
  String? quizError;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadEducations(),
      _loadQuizzes(),
    ]);
  }

  Future<void> _loadEducations() async {
    try {
      setState(() {
        isLoadingEducation = true;
        educationError = null;
      });
      
      final educations = await EducationService().fetchAllEducations(
        page: 1,
        limit: 10, // Ambil 10 untuk homepage
      );
      
      if (mounted) {
        setState(() {
          educationItems = educations;
          isLoadingEducation = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          educationError = e.toString().replaceAll('Exception: ', '');
          isLoadingEducation = false;
        });
      }
    }
  }

  Future<void> _loadQuizzes() async {
    try {
      setState(() {
        isLoadingQuiz = true;
        quizError = null;
      });
      
      final quizzes = await QuizService().fetchAllQuizzes(
        page: 1,
        limit: 10, // Ambil 10 untuk homepage
      );
      
      if (mounted) {
        setState(() {
          quizItems = quizzes;
          isLoadingQuiz = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          quizError = e.toString().replaceAll('Exception: ', '');
          isLoadingQuiz = false;
        });
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      // Tetap di halaman ini (Home)
    } else if (index == 1) {
      Navigator.pushNamed(context, AppRoutes.listEducation);
    } else if (index == 2) {
      Navigator.pushNamed(context, AppRoutes.profile);
    }
  }

  void _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tidak dapat membuka link: $url')),
        );
      }
    }
  }

  Future<void> _openWhatsApp() async {
    const String phoneNumber = '6283114755807';
    const String message = "Halo, saya ingin bertanya";

    final Uri whatsappUrl = Uri.parse(
      'whatsapp://send?phone=$phoneNumber&text=${Uri.encodeComponent(message)}',
    );

    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(whatsappUrl);
    } else {
      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Error'),
              content: const Text(
                'Aplikasi WhatsApp tidak ditemukan di perangkat Anda.',
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    }
  }

  Widget _buildEducationSection() {
    if (isLoadingEducation) {
      return const SizedBox(
        height: 220,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (educationError != null) {
      return SizedBox(
        height: 220,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 8),
              Text(
                educationError!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _loadEducations,
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    if (educationItems.isEmpty) {
      return const SizedBox(
        height: 220,
        child: Center(
          child: Text('Belum ada edukasi tersedia'),
        ),
      );
    }

    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: educationItems.length,
        itemBuilder: (context, index) {
          final item = educationItems[index];
          return Container(
            width: 160,
            margin: const EdgeInsets.only(right: 12),
            child: GridItemCard(
              imageUrl: item.thumbnail,
              title: item.name,
              onTap: () => _launchURL(item.url),
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuizSection() {
    if (isLoadingQuiz) {
      return const SizedBox(
        height: 220,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (quizError != null) {
      return SizedBox(
        height: 220,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 8),
              Text(
                quizError!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _loadQuizzes,
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    if (quizItems.isEmpty) {
      return const SizedBox(
        height: 220,
        child: Center(
          child: Text('Belum ada kuis tersedia'),
        ),
      );
    }

    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: quizItems.length,
        itemBuilder: (context, index) {
          final item = quizItems[index];
          return Container(
            width: 160,
            margin: const EdgeInsets.only(right: 12),
            child: GridItemCard(
              imageUrl: 'assets/quiz.jpg', // Default image untuk quiz
              title: item.name,
              onTap: () => _launchURL(item.url),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const TopBar(),
      extendBodyBehindAppBar: false,
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Welcome - Centered
                Center(
                  child: Column(
                    children: [
                      RichText(
                        text: const TextSpan(
                          style: TextStyle(fontSize: 20, color: Colors.black),
                          children: [
                            TextSpan(text: 'Selamat Datang di '),
                            TextSpan(
                              text: 'TIRTHA',
                              style: TextStyle(
                                color: Color(0xFF00BFA5),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'WAHYU HS',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Menu Header
                MenuHeader(
                  menuItems: [
                    MenuHeaderItem(
                      icon: Icons.monitor_heart_outlined,
                      title: 'Pantau\nTubuh',
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.monitoring);
                      },
                    ),
                    MenuHeaderItem(
                      icon: Icons.description_outlined,
                      title: 'Kuis',
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.listQuiz);
                      },
                    ),
                    MenuHeaderItem(
                      icon: Icons.alarm,
                      title: 'Pengingat',
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.reminder);
                      },
                    ),
                    MenuHeaderItem(
                      icon: Icons.chat_bubble_outline,
                      title: 'Tanya\nPetugas',
                      onTap: _openWhatsApp,
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Edukasi Terbaru Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Edukasi Terbaru',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.listEducation);
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFFFF9800),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: const Text('Selengkapnya'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Education Cards Grid (Horizontal Scroll)
                _buildEducationSection(),
                const SizedBox(height: 32),

                // Pantau Tubuh Section Card
                SectionHomeCard(
                  title: 'Pantau Tubuh Anda',
                  description:
                      'Dengan fitur ini anda bisa memantau kondisi tubuh anda',
                  buttonText: 'Cek Sekarang',
                  onButtonPressed: () {
                    Navigator.pushNamed(context, AppRoutes.monitoring);
                  },
                  illustration: Image.asset(
                    'assets/medical_history.png',
                    width: 80,
                    height: 80,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 24),

                // Kuis Terbaru Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Kuis Terbaru',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.listQuiz);
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFFFF9800),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: const Text('Selengkapnya'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Quiz Cards Grid (Horizontal Scroll)
                _buildQuizSection(),
                const SizedBox(height: 24),

                // Tanya Petugas Section Card
                SectionHomeCard(
                  title: 'Tanya Petugas',
                  description:
                      'Konsultasi dengan petugas kesehatan melalui WhatsApp',
                  buttonText: 'Hubungi Sekarang',
                  backgroundColor: const Color(0xFF00BFA5),
                  buttonColor: const Color(0xFFFF9800),
                  onButtonPressed: _openWhatsApp,
                  illustration: Image.asset(
                    'assets/reminder_section.png',
                    width: 80,
                    height: 80,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 24),

                // Lupa Jadwal / Pengingat Section Card
                SectionHomeCard(
                  title: 'Sering Lupa Jadwal?',
                  description:
                      'Atur pengingat untuk jadwal kontrol dan minum obat Anda',
                  buttonText: 'Buat Pengingat',
                  backgroundColor: const Color(0xFFFF9800),
                  buttonColor: const Color(0xFF4CAF50),
                  onButtonPressed: () {
                    Navigator.pushNamed(context, AppRoutes.reminder);
                  },
                  illustration: Image.asset(
                    'assets/alarm.png',
                    width: 80,
                    height: 80,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
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