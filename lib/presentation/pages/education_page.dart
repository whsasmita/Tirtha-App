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
  
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  
  List<EducationModel> _allEducations = [];
  List<EducationModel> _filteredEducations = [];
  
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadEducations();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadEducations() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final educations = await _educationService.fetchAllEducations();
      
      if (mounted) {
        setState(() {
          _allEducations = educations;
          _filteredEducations = educations;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
      if (_searchQuery.isEmpty) {
        _filteredEducations = _allEducations;
      } else {
        _filteredEducations = _allEducations
            .where((edu) => edu.name.toLowerCase().contains(_searchQuery))
            .toList();
      }
    });
  }

  void _navigateToEditEducation(int educationId) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => UpsertEducationPage(educationId: educationId),
      ),
    );

    if (result == true) {
      _loadEducations();
    }
  }

  void _navigateToCreateEducation() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const UpsertEducationPage(educationId: null),
      ),
    );

    if (result == true) {
      _loadEducations();
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
        _loadEducations();
        
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
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(no.toString(), textAlign: TextAlign.center),
              ),
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

  Widget _buildBody() {
    // 1. Loading State
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(40.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    // 2. Error State
    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.all(40.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.red),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadEducations,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                ),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    // 3. Empty State
    if (_filteredEducations.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(40.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _searchQuery.isNotEmpty ? Icons.search_off : Icons.school_outlined,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                _searchQuery.isNotEmpty 
                    ? 'Tidak ditemukan hasil pencarian.'
                    : 'Belum ada edukasi tersedia',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 4. Data List
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _filteredEducations.length,
      itemBuilder: (context, index) {
        final education = _filteredEducations[index];
        return _buildEducationsTableItem(context, index + 1, education);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const TopBar(),
      body: RefreshIndicator(
        onRefresh: _loadEducations,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
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
                            hintText: 'Cari edukasi di sini...',
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
              
              // Table Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    color: Colors.grey.shade100,
                  ),
                  child: IntrinsicHeight(
                    child: Row(
                      children: const [
                        SizedBox(
                          width: 40,
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              "No",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              "Nama",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 100,
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              "Link",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 96,
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              "Aksi",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Table Body
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: _buildBody(),
              ),
              
              const SizedBox(height: 80),
            ],
          ),
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