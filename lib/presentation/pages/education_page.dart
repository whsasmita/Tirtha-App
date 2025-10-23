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

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  List<EducationModel> _allEducations = [];
  List<EducationModel> _filteredEducations = [];

  @override
  void initState() {
    super.initState();
    _loadEducations();
    _searchController.addListener(_onSearchChanged);
  }

  void _loadEducations() {
    _educationsFuture = _educationService.fetchAllEducations();
    _educationsFuture.then((data) {
      setState(() {
        _allEducations = data;
        _filteredEducations = data;
      });
    });
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
      _filteredEducations = _allEducations
          .where((edu) => edu.name.toLowerCase().contains(_searchQuery))
          .toList();
    });
  }

  void _refreshEducations() {
    _loadEducations();
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
      Navigator.pushNamed(context, AppRoutes.home);
    } else if (index == 1) {
      // Tetap di halaman ini
    } else if (index == 2) {
      Navigator.pushNamed(context, AppRoutes.quizDashboard);
    }
  }

  Future<void> _launchURL(String url) async {
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('URL tidak tersedia')),
      );
      return;
    }

    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }

    final Uri uri = Uri.parse(url);

    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membuka link: $url')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan: $e')),
        );
      }
    }
  }

  Future<void> _confirmDeleteEducation(EducationModel education) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: Text('Apakah Anda yakin ingin menghapus edukasi "${education.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        await _educationService.deleteEducation(education.id);
        _refreshEducations();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Edukasi "${education.name}" berhasil dihapus'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal menghapus edukasi: $e'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 2),
            ),
          );
        }
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
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
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
                _navigateToEditEducation(education.id);
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
              onPressed: () => _confirmDeleteEducation(education),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          hintText: 'Cari edukasi disini...',
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
                  children: const [
                    SizedBox(width: 40, child: Text("No", textAlign: TextAlign.center)),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text("Nama"),
                      ),
                    ),
                    SizedBox(width: 100, child: Text("Link")),
                    SizedBox(width: 60, child: Text("Aksi")),
                  ],
                ),
              ),
            ),
            FutureBuilder<List<EducationModel>>(
              future: _educationsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting && _allEducations.isEmpty) {
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
                } else if (_filteredEducations.isNotEmpty) {
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _filteredEducations.length,
                    itemBuilder: (context, index) {
                      final education = _filteredEducations[index];
                      return _buildEducationsTableItem(context, index + 1, education);
                    },
                  );
                } else {
                  return const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Center(child: Text('Tidak ditemukan hasil pencarian.')),
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