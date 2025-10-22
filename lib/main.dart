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
  print("Handling a background message: ${message.messageId}");
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
      print('Notification tapped: ${notificationResponse.payload}');
      // Handle navigation based on payload here
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

  print('User granted permission: ${settings.authorizationStatus}');
  
  // Get FCM token
  String? token = await messaging.getToken();
  print('FCM Token: $token');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize Firebase
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }
  } catch (e) {
    print('Error initialize firebase $e');
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
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
        );
      }
    });

    // Handle notification tap when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Notification tapped from background: ${message.messageId}');
      // Handle navigation based on message data
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.checkAuth();

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
        AppRoutes.quizDashboard: (context) => const QuizDashboardPage(),
        AppRoutes.createEducation: (context) => const UpsertEducationPage(),
        AppRoutes.createQuiz: (context) => const UpsertQuizPage(),

        // List Pages
        AppRoutes.listEducation: (context) => const EducationListPage(),
        AppRoutes.listQuiz: (context) => const QuizListPage(),

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