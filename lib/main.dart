import 'package:flutter/material.dart';
import 'package:tirtha_app/routes/app_routes.dart';
import 'package:tirtha_app/presentation/pages/login_page.dart';
import 'package:tirtha_app/presentation/pages/register_page.dart';
import 'package:tirtha_app/presentation/pages/education_page.dart';
import 'package:tirtha_app/presentation/pages/preview_page.dart';
import 'package:tirtha_app/presentation/pages/profile_page.dart';
import 'package:tirtha_app/presentation/pages/create_education_page.dart';
import 'package:tirtha_app/presentation/pages/quiz_page.dart';
import 'package:tirtha_app/presentation/pages/create_quiz_page.dart';
import 'package:tirtha_app/presentation/pages/about_page.dart';
import 'package:tirtha_app/presentation/pages/education_list_page.dart';
import 'package:tirtha_app/presentation/pages/quiz_list_page.dart';
import 'package:tirtha_app/presentation/pages/home_example.dart';
import 'package:tirtha_app/core/services/app_client.dart';
import 'package:provider/provider.dart';
import 'package:tirtha_app/core/config/auth_provider.dart';

void main() {
  ApiClient.init();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    authProvider.checkAuth();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.preview,
      routes: {
        AppRoutes.preview: (context) => const PreviewPage(),
        AppRoutes.login: (context) => const LoginPage(),
        AppRoutes.register: (context) => const RegisterPage(),
        AppRoutes.educationDashboard:
            (context) => const EducationDashboardPage(),
        AppRoutes.quizDashboard: (context) => const QuizDashboardPage(),
        AppRoutes.profile: (context) => const ProfilePage(),
        AppRoutes.about: (context) => const AboutPage(),
        AppRoutes.createEducation: (context) => const UpsertEducationPage(),
        AppRoutes.createQuiz: (context) => const UpsertQuizPage(),
        AppRoutes.listEducation: (context) => const EducationListPage(),
        AppRoutes.listQuiz: (context) => const QuizListPage(),
        AppRoutes.homeUser: (context) => const HomeExample(),
      },
    );
  }
}
