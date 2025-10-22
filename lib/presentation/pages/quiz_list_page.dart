import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tirtha_app/presentation/themes/color.dart';
import 'package:tirtha_app/presentation/widgets/top_bar.dart';
import 'package:tirtha_app/presentation/widgets/bottom_nav_v1.dart';
import 'package:tirtha_app/presentation/widgets/grid_item_card.dart';
import 'package:tirtha_app/presentation/widgets/home_header.dart';
import 'package:tirtha_app/routes/app_routes.dart';
import 'package:tirtha_app/core/services/quiz_service.dart';
import 'package:tirtha_app/data/models/quiz_model.dart';

class QuizListPage extends StatefulWidget {
  const QuizListPage({Key? key}) : super(key: key);

  @override
  State<QuizListPage> createState() => _QuizListPageState();
}

class _QuizListPageState extends State<QuizListPage> {
  int _selectedIndex = 2;
  final QuizService _quizService = QuizService();
  late Future<List<QuizModel>> _quizFuture;
  List<QuizModel> _allQuizzes = [];
  List<QuizModel> _filteredQuizzes = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _quizFuture = _loadQuizzes();
  }

  Future<List<QuizModel>> _loadQuizzes() async {
    final quizzes = await _quizService.fetchAllQuizzes();
    setState(() {
      _allQuizzes = quizzes;
      _filteredQuizzes = quizzes;
    });
    return quizzes;
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);

    if (index == 0) {
      Navigator.pushNamed(context, AppRoutes.homeUser);
    } else if (index == 1) {
      Navigator.pushNamed(context, AppRoutes.educationDashboard);
    } else if (index == 2) {
      Navigator.pushNamed(context, AppRoutes.profile);
    }
  }

  void _filterQuizzes(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredQuizzes = _allQuizzes;
      } else {
        _filteredQuizzes = _allQuizzes
            .where((quiz) => quiz.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  Future<void> _launchURL(String url) async {
    if (url.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('URL tidak tersedia')));
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: HomeHeader(
              title: 'KUIS KESEHATAN',
              backgroundColor: AppColors.tertiary,
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
                      onChanged: _filterQuizzes,
                      decoration: const InputDecoration(
                        hintText: 'Cari kuis di sini...',
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
            child: FutureBuilder<List<QuizModel>>(
              future: _quizFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Gagal memuat kuis: ${snapshot.error}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  );
                } else if (_filteredQuizzes.isNotEmpty) {
                  return GridView.builder(
                    padding: const EdgeInsets.all(16.0),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16.0,
                      mainAxisSpacing: 16.0,
                      childAspectRatio: 1.4,
                    ),
                    itemCount: _filteredQuizzes.length,
                    itemBuilder: (context, index) {
                      final item = _filteredQuizzes[index];
                      return GridItemCard(
                        title: item.name,
                        imageUrl: 'assets/quiz.jpg',
                        onTap: () => _launchURL(item.url),
                      );
                    },
                  );
                } else {
                  return const Center(child: Text('Kuis tidak ditemukan.'));
                }
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
