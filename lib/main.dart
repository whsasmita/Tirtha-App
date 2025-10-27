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

// PENAMBAHAN: DEFINISI GLOBAL KEY UNTUK NAVIGASI
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Create an instance of FlutterLocalNotificationsPlugin
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// Background message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // Background message handled
}

Future<void> initializeLocalNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('ic_stat_notification');

  final DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) async {
      // Navigate ke ReminderPage saat notification di-tap
      navigatorKey.currentState?.pushNamed(AppRoutes.reminder);
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

  // 1. Definisikan status inisialisasi di luar
  bool firebaseInitialized = false;

  try {
    // Initialize Firebase
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
      // Tetapkan nilainya setelah berhasil
      firebaseInitialized = true;
    }
  } catch (e) {
    // Biarkan firebaseInitialized tetap false (nilai default) jika gagal
  }

  // Lanjutkan inisialisasi lainnya...
  await initializeLocalNotifications();
  await requestNotificationPermissions();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  ApiClient.init();

  runApp(
    MultiProvider(
      providers: [
        // Gunakan variabel yang sudah diinisialisasi
        ChangeNotifierProvider(
          create:
              (context) => AuthProvider(isFirebaseReady: firebaseInitialized),
        ),
      ],
      child: MyApp(isFirebaseReady: firebaseInitialized),
    ),
  );
}

class MyApp extends StatefulWidget {
  final bool isFirebaseReady;

  const MyApp({super.key, required this.isFirebaseReady});

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
              icon: 'ic_stat_notification',
              color: const Color.fromARGB(255, 33, 150, 243),
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
          payload: 'reminder', // Identifier untuk ReminderPage
        );
      }
    });

    // Handle notification tap when app is in background/terminated
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // Navigate ke ReminderPage
      navigatorKey.currentState?.pushNamed(AppRoutes.reminder);
    });

    // Handle notification tap when app terminated
    _checkInitialMessage();
  }

  Future<void> _checkInitialMessage() async {
    // Check if app was opened from notification when terminated
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    
    if (initialMessage != null) {
      // App dibuka dari notification saat dalam keadaan terminated
      // Delay untuk memastikan app sudah fully initialized
      Future.delayed(const Duration(seconds: 1), () {
        navigatorKey.currentState?.pushNamed(AppRoutes.reminder);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      home: const AuthChecker(), // ✅ Gunakan AuthChecker untuk auto-login
      
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
            return MaterialPageRoute(
              builder: (context) => const RegisterPage(),
            );

          case AppRoutes.profile:
            return MaterialPageRoute(builder: (context) => const ProfilePage());

          case AppRoutes.about:
            return MaterialPageRoute(builder: (context) => const AboutPage());

          // Education & Quiz Dashboard
          case AppRoutes.educationDashboard:
            return MaterialPageRoute(
              builder: (context) => const EducationDashboardPage(),
            );

          case AppRoutes.quizDashboard:
            return MaterialPageRoute(
              builder: (context) => const QuizDashboardPage(),
            );

          case AppRoutes.createEducation:
            return MaterialPageRoute(
              builder: (context) => const UpsertEducationPage(),
            );

          case AppRoutes.createQuiz:
            return MaterialPageRoute(
              builder: (context) => const UpsertQuizPage(),
            );

          // List Pages
          case AppRoutes.listEducation:
            return MaterialPageRoute(
              builder: (context) => const EducationListPage(),
            );

          case AppRoutes.listQuiz:
            return MaterialPageRoute(
              builder: (context) => const QuizListPage(),
            );

          // Reminder
          case AppRoutes.reminder:
            return MaterialPageRoute(
              builder: (context) => const ReminderPage(),
            );

          // Monitoring
          case AppRoutes.monitoring:
            return MaterialPageRoute(
              builder: (context) => const MonitoringPage(),
            );

          case AppRoutes.complaintMonitoring:
            return MaterialPageRoute(
              builder: (context) => const ComplaintMonitoringPage(),
            );

          case AppRoutes.createComplaintMonitoring:
            return MaterialPageRoute(
              builder: (context) => const CreateComplaintMonitoring(),
            );

          case AppRoutes.hemodialysisMonitoring:
            return MaterialPageRoute(
              builder: (context) => const HemodialysisMonitoringPage(),
            );

          case AppRoutes.createHemodialysisMonitoring:
            return MaterialPageRoute(
              builder: (context) => const CreateHemodialysisMonitoring(),
            );

          case AppRoutes.fluidMonitoring:
            return MaterialPageRoute(
              builder: (context) => const FluidMonitoringPage(),
            );

          case AppRoutes.createFluidMonitoring:
            return MaterialPageRoute(
              builder: (context) => const CreateFluidMonitoringPage(),
            );

          default:
            // Fallback untuk route yang tidak ditemukan
            return MaterialPageRoute(
              builder:
                  (context) => Scaffold(
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

// ✅ WIDGET BARU: AuthChecker untuk cek status login otomatis
class AuthChecker extends StatelessWidget {
  const AuthChecker({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Panggil checkAuth saat pertama kali build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          authProvider.checkAuth();
        });

        // Cek status authentication
        if (authProvider.isLoading) {
          // Tampilkan loading saat mengecek auth
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Jika sudah login, langsung ke HomePage
        if (authProvider.isAuthenticated) {
          return const HomePage();
        }

        // Jika belum login, ke PreviewPage
        return const PreviewPage();
      },
    );
  }
}