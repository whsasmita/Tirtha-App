import 'package:flutter/material.dart';
import 'package:tirtha_app/presentation/themes/color.dart';
import 'package:tirtha_app/presentation/widgets/top_bar.dart';
import 'package:tirtha_app/presentation/widgets/bottom_nav_v2.dart';
import 'package:tirtha_app/presentation/widgets/home_header.dart';
import 'package:tirtha_app/routes/app_routes.dart';
import 'package:tirtha_app/core/services/quiz_service.dart';
import 'package:tirtha_app/data/models/quiz_model.dart';
import 'package:tirtha_app/presentation/pages/create_quiz_page.dart';
import 'package:url_launcher/url_launcher.dart';

class QuizDashboardPage extends StatefulWidget {
  const QuizDashboardPage({super.key});

  @override
  State<QuizDashboardPage> createState() => _QuizDashboardPageState();
}

class _QuizDashboardPageState extends State<QuizDashboardPage> {
  int _selectedIndex = 2;
  final QuizService _quizService = QuizService();
  late Future<List<QuizModel>> _quizzesFuture;

  @override
  void initState() {
    super.initState();
    _quizzesFuture = _quizService.fetchAllQuizzes();
  }

  void _refreshQuizzes() {
    setState(() {
      _quizzesFuture = _quizService.fetchAllQuizzes();
    });
  }

  void _navigateToEditQuiz(int quizId) async {
    final result = await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => UpsertQuizPage(quizId: quizId)));

    if (result == true) {
      _refreshQuizzes();
    }
  }

  void _navigateToCreateQuiz() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const UpsertQuizPage(quizId: null)),
    );

    if (result == true) {
      _refreshQuizzes();
    }
  }

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

  Widget _buildQuizTableItem(BuildContext context, int no, QuizModel quiz) {
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
                child: Text(quiz.name),
              ),
            ),
            Container(
              width: 100,
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 8.0,
              ),

              child: GestureDetector(
                onTap: () {},
                child: GestureDetector(
                  onTap: () => _launchURL(quiz.url),
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
            ),
            IconButton(
              icon: const Icon(Icons.edit, size: 20, color: AppColors.primary),
              onPressed: () {
                print('Navigating to Edit Quiz ID: ${quiz.id}');
                _navigateToEditQuiz(quiz.id);
              },
            ),

            IconButton(
              icon: const Icon(
                Icons.delete_outline,
                size: 20,
                color: Colors.red,
              ),
              onPressed: () {
                _quizService.deleteQuiz(quiz.id);
                _refreshQuizzes();
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
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: const TextField(
                        decoration: InputDecoration(
                          hintText: 'cari quiz disini',
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

            FutureBuilder<List<QuizModel>>(
              future: _quizzesFuture,
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
                      return _buildQuizTableItem(context, index + 1, quiz);
                    },
                  );
                } else {
                  return const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Center(child: Text('Belum ada kuis yang dibuat.')),
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
        onPressed: _navigateToCreateQuiz,
        backgroundColor: AppColors.tertiary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
