// lib/main.dart

import 'package:flutter/material.dart';
import 'package:tirtha_app/presentation/pages/home_page.dart';
import 'package:tirtha_app/presentation/pages/monitoring/complaint/complaint_monitoring_page.dart';
import 'package:tirtha_app/presentation/pages/monitoring/complaint/create_complaint_monitoring.dart';
import 'package:tirtha_app/presentation/pages/monitoring/fluid/create_fluid_monitoring.dart';
import 'package:tirtha_app/presentation/pages/monitoring/fluid/fluid_monitoring_page.dart';
import 'package:tirtha_app/presentation/pages/monitoring/hemodialysis/create_hemodialysis_monitoring.dart';
import 'package:tirtha_app/presentation/pages/monitoring/hemodialysis/hemodialysis_monitoringi_page.dart';
import 'package:tirtha_app/presentation/pages/monitoring/monitoring_page.dart';
import 'package:tirtha_app/presentation/pages/reminder/reminderForm.dart';
import 'package:tirtha_app/presentation/pages/reminder/reminder_page.dart';
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

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
    Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.preview,
      routes: {
        AppRoutes.preview: (context) => const PreviewPage(),
        AppRoutes.home: (context) => const HomePage(),

        // Auth
        AppRoutes.login: (context) => const LoginPage(),
        AppRoutes.register: (context) => const RegisterPage(),
        AppRoutes.profile: (context) => const ProfilePage(),
        AppRoutes.about: (context) => const AboutPage(),

        // Education & Quiz Dashboard
        AppRoutes.educationDashboard: (context) => const EducationDashboardPage(),
        AppRoutes.createEducation: (context) => const CreateEducationPage(),
        AppRoutes.quizDashboard: (context) => const QuizDashboardPage(),
        AppRoutes.createQuiz: (context) => const CreateQuizPage(),

        // List Pages
        AppRoutes.listEducation: (context) => const EducationListPage(),
        AppRoutes.listQuiz: (context) => const QuizPage(),

        // Reminder
        AppRoutes.reminder: (context) => const ReminderPage(),
        AppRoutes.createReminder: (context) => const ReminderFormPage(),

        // Monitoring
        AppRoutes.monitoring: (context) => const MonitoringPage(),

        AppRoutes.complaintMonitoring: (context) => const ComplaintMonitoringPage(),
        AppRoutes.createComplaintMonitoring: (context) => const CreateComplaintMonitoring(),

        AppRoutes.hemodialysisMonitoring: (context) => const HemodialysisMonitoringPage(),
        AppRoutes.createHemodialysisMonitoring: (context) => const CreateHemodialysisMonitoring(),

        AppRoutes.fluidMonitoring: (context) => const FluidMonitoringPage(),
        AppRoutes.createFluidMonitoring: (context) => const CreateFluidMonitoringPage(),
      },
    );
  }

}
