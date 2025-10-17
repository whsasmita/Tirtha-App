import 'package:flutter/material.dart';
import 'package:tirtha_app/presentation/themes/color.dart';
import 'package:tirtha_app/presentation/widgets/top_bar.dart';
import 'package:tirtha_app/presentation/widgets/bottom_nav_v2.dart';
import 'package:tirtha_app/presentation/widgets/home_header.dart';
import 'package:tirtha_app/routes/app_routes.dart';
import 'package:tirtha_app/core/services/education_service.dart';
import 'package:tirtha_app/data/models/education_model.dart';
import 'package:tirtha_app/presentation/pages/create_education_page.dart';
import 'package:url_launcher/url_launcher.dart';

class EducationDashboardPage extends StatefulWidget {
  const EducationDashboardPage({super.key});

  @override
  State<EducationDashboardPage> createState() => _EducationDashboardPageState();
}

class _EducationDashboardPageState extends State<EducationDashboardPage> {
  int _selectedIndex = 1;
  final EducationService _educationService = EducationService();
  late Future<List<EducationModel>> _educationsFuture;

  @override
  void initState() {
    super.initState();
    _educationsFuture = _educationService.fetchAllEducations();
  }

  void _refreshEducations() {
    setState(() {
      _educationsFuture = _educationService.fetchAllEducations();
    });
  }

  void _navigateToEditEducation(int educationId) async {
    final result = await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => UpsertEducationPage(educationId: educationId)));

    if (result == true) {
      _refreshEducations();
    }
  }

  void _navigateToCreateEducation() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const UpsertEducationPage(educationId: null)),
    );

    if (result == true) {
      _refreshEducations();
    }
  }

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

  Future<void> _launchURL(String url) async {
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

  Widget _buildEducationsTableItem(BuildContext context, int no, EducationModel education) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            SizedBox(
              width: 40,
              child: Text(no.toString(), textAlign: TextAlign.center),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(education.name),
              ),
            ),
            Container(
              width: 100,
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 8.0,
              ),

              child: GestureDetector(
                  onTap: () => _launchURL(education.url),
                  child: const Text(
                    'Klik disini',
                    style: TextStyle(
                      color: AppColors.secondary,
                      decoration: TextDecoration.underline,
                      decorationColor: AppColors.secondary,
                    ),
                  ),
                ),
            ),
            IconButton(
              icon: const Icon(Icons.edit, size: 20, color: AppColors.primary),
              onPressed: () {
                print('Navigating to Edit Quiz ID: ${education.id}');
                _navigateToEditEducation(education.id);
              },
            ),

            IconButton(
              icon: const Icon(
                Icons.delete_outline,
                size: 20,
                color: Colors.red,
              ),
              onPressed: () {
                _educationService.deleteEducation(education.id);
                _refreshEducations();
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
                title: 'EDUKASI KESEHATAN',
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
                      color: AppColors.secondary,
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

            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: IntrinsicHeight(
                child: Row(
                  children: [
                    SizedBox(
                      width: 40,
                      child: Text("No", textAlign: TextAlign.center),
                    ),
                    const Expanded(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text("Nama"),
                      ),
                    ),
                    Container(
                      width: 100,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 8.0,
                      ),
                      child: const Text("Link"),
                    ),
                    const SizedBox(width: 10),
                    const Text("Aksi"),
                    const SizedBox(width: 30),
                  ],
                ),
              ),
            ),

            FutureBuilder<List<EducationModel>>(
              future: _educationsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                } else if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Center(
                      child: Text('Gagal memuat data: ${snapshot.error}'),
                    ),
                  );
                } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final quiz = snapshot.data![index];
                      return _buildEducationsTableItem(context, index + 1, quiz);
                    },
                  );
                } else {
                  return const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Center(child: Text('Belum ada edukasi yang dibuat.')),
                  );
                }
              },
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavV2(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateEducation,
        backgroundColor: AppColors.secondary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}