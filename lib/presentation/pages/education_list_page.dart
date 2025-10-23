import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tirtha_app/presentation/themes/color.dart';
import 'package:tirtha_app/presentation/widgets/top_bar.dart';
import 'package:tirtha_app/presentation/widgets/bottom_nav_v1.dart';
import 'package:tirtha_app/presentation/widgets/grid_item_card.dart';
import 'package:tirtha_app/presentation/widgets/home_header.dart';
import 'package:tirtha_app/routes/app_routes.dart';
import 'package:tirtha_app/core/services/education_service.dart';
import 'package:tirtha_app/data/models/education_model.dart';

class EducationListPage extends StatefulWidget {
  const EducationListPage({super.key});

  @override
  State<EducationListPage> createState() => _EducationListPageState();
}

class _EducationListPageState extends State<EducationListPage> {
  int _selectedIndex = 1;
  final EducationService _educationService = EducationService();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  List<EducationModel> _allEducations = [];
  List<EducationModel> _filteredEducations = [];
  
  int _currentPage = 1;
  final int _limit = 10;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _error;
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _loadEducations();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent * 0.8) {
      if (!_isLoadingMore && _hasMore && _searchQuery.isEmpty) {
        _loadMoreEducations();
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

  Future<void> _loadEducations() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _currentPage = 1;
      _hasMore = true;
    });

    try {
      final response = await _educationService.fetchEducationsWithMeta(
        page: _currentPage,
        limit: _limit,
      );

      if (mounted) {
        setState(() {
          _allEducations = response.data;
          _filteredEducations = response.data;
          _hasMore = response.hasMore;
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

  Future<void> _loadMoreEducations() async {
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final response = await _educationService.fetchEducationsWithMeta(
        page: _currentPage + 1,
        limit: _limit,
      );

      if (mounted) {
        setState(() {
          _currentPage++;
          _allEducations.addAll(response.data);
          _filteredEducations = _searchQuery.isEmpty 
              ? _allEducations 
              : _allEducations
                  .where((edu) => edu.name.toLowerCase().contains(_searchQuery))
                  .toList();
          _hasMore = response.hasMore;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat lebih banyak data: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
      Navigator.pushNamed(context, AppRoutes.profile);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const TopBar(),
      body: RefreshIndicator(
        onRefresh: _loadEducations,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: HomeHeader(
                title: 'EDUKASI KESEHATAN',
                backgroundColor: AppColors.secondary,
                illustrationPath: 'assets/doctor.png',
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
            const SizedBox(height: 10),

            Expanded(
              child: _buildBody(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavV1(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
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

    if (_filteredEducations.isEmpty) {
      return Center(
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
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
        childAspectRatio: 1.4,
      ),
      itemCount: _filteredEducations.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _filteredEducations.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final item = _filteredEducations[index];
        return GridItemCard(
          title: item.name,
          imageUrl: item.thumbnail.isNotEmpty ? item.thumbnail : "assets/doctor.png",
          onTap: () => _launchURL(item.url),
        );
      },
    );
  }
}