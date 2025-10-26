import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
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
import 'package:tirtha_app/core/services/app_client.dart';
import 'package:provider/provider.dart';
import 'package:tirtha_app/core/config/auth_provider.dart';

// Background message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // Background message handled
}

// Create an instance of FlutterLocalNotificationsPlugin
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> initializeLocalNotifications() async {
  // Android Initialization Settings
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('notif_icon');

  // iOS Initialization Settings
  final DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );

  // Combine platform-specific settings
  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );

  // Initialize the plugin
  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) async {
      // Handle notification tap payload here
    },
  );
}

// Request notification permissions (especially for iOS)
Future<void> requestNotificationPermissions() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
    provisional: false,
  );

  // Optionally use settings.authorizationStatus if needed (no prints)
  String? token = await messaging.getToken();
  // Use token as needed (no prints)
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }
  } catch (e) {
    // Handle Firebase init error (no prints)
  }

  // Initialize local notifications
  await initializeLocalNotifications();

  // Request notification permissions
  await requestNotificationPermissions();

  // Set up background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Initialize API Client
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

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _setupForegroundNotificationHandler();
  }

  void _setupForegroundNotificationHandler() {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      // Show notification when app is in foreground
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              'default_channel',
              'Default Channel',
              channelDescription: 'This channel is used for important notifications.',
              icon: 'notif_icon',
              // largeIcon: DrawableResourceAndroidBitmap('notif_icons'),
              color: const Color.fromARGB(255, 33, 150, 243),
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
        );
      }
    });

    // Handle notification tap when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // Handle navigation based on message data (no prints)
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.checkAuth();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.preview,

      // ✅ GUNAKAN onGenerateRoute UNTUK HANDLE ARGUMENTS
      onGenerateRoute: (settings) {
        // Handle Reminder Form dengan arguments (untuk edit mode)
        if (settings.name == AppRoutes.createReminder) {
          final editData = settings.arguments; // Ambil data edit jika ada
          return MaterialPageRoute(
            builder: (context) => ReminderFormPage(editData: editData),
          );
        }

        // Routes lainnya tetap normal
        switch (settings.name) {
          case AppRoutes.preview:
            return MaterialPageRoute(builder: (context) => const PreviewPage());

          case AppRoutes.home:
            return MaterialPageRoute(builder: (context) => const HomePage());

          // Auth
          case AppRoutes.login:
            return MaterialPageRoute(builder: (context) => const LoginPage());

          case AppRoutes.register:
            return MaterialPageRoute(builder: (context) => const RegisterPage());

          case AppRoutes.profile:
            return MaterialPageRoute(builder: (context) => const ProfilePage());

          case AppRoutes.about:
            return MaterialPageRoute(builder: (context) => const AboutPage());

          // Education & Quiz Dashboard
          case AppRoutes.educationDashboard:
            return MaterialPageRoute(builder: (context) => const EducationDashboardPage());

          case AppRoutes.quizDashboard:
            return MaterialPageRoute(builder: (context) => const QuizDashboardPage());

          case AppRoutes.createEducation:
            return MaterialPageRoute(builder: (context) => const UpsertEducationPage());

          case AppRoutes.createQuiz:
            return MaterialPageRoute(builder: (context) => const UpsertQuizPage());

          // List Pages
          case AppRoutes.listEducation:
            return MaterialPageRoute(builder: (context) => const EducationListPage());

          case AppRoutes.listQuiz:
            return MaterialPageRoute(builder: (context) => const QuizListPage());

          // Reminder
          case AppRoutes.reminder:
            return MaterialPageRoute(builder: (context) => const ReminderPage());

          // Monitoring
          case AppRoutes.monitoring:
            return MaterialPageRoute(builder: (context) => const MonitoringPage());

          case AppRoutes.complaintMonitoring:
            return MaterialPageRoute(builder: (context) => const ComplaintMonitoringPage());

          case AppRoutes.createComplaintMonitoring:
            return MaterialPageRoute(builder: (context) => const CreateComplaintMonitoring());

          case AppRoutes.hemodialysisMonitoring:
            return MaterialPageRoute(builder: (context) => const HemodialysisMonitoringPage());

          case AppRoutes.createHemodialysisMonitoring:
            return MaterialPageRoute(builder: (context) => const CreateHemodialysisMonitoring());

          case AppRoutes.fluidMonitoring:
            return MaterialPageRoute(builder: (context) => const FluidMonitoringPage());

          case AppRoutes.createFluidMonitoring:
            return MaterialPageRoute(builder: (context) => const CreateFluidMonitoringPage());

          default:
            // Fallback untuk route yang tidak ditemukan
            return MaterialPageRoute(
              builder: (context) => Scaffold(
                body: Center(
                  child: Text('Route ${settings.name} not found'),
                ),
              ),
            );
        }
      },
    );
  }
}