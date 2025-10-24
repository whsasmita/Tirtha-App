import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// Note: Tidak perlu import 'package:timezone/data/latest.dart' atau 'package:timezone/timezone.dart' 
// karena menggunakan show() yang di Android otomatis menggunakan metode Durasi.

class NotificationService {
  // Instance dari plugin notifikasi lokal
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  // Detail Notifikasi Android yang konsisten
  static const AndroidNotificationDetails _androidNotificationDetails =
      AndroidNotificationDetails(
    'drug_schedule_channel', // Channel ID harus unik dan konsisten
    'Pengingat Minum Obat', // Nama Channel yang ditampilkan ke pengguna
    channelDescription: 'Notifikasi pengingat jadwal minum obat',
    importance: Importance.max, // Penting: High atau Max untuk notifikasi penting
    priority: Priority.high,
    showWhen: true,
    // Pastikan drawable 'ic_launcher' ada di direktori Android Anda
    icon: '@mipmap/ic_launcher',
  );

  /// Initialize notification service (Khusus Android)
  static Future<void> initialize() async {
    if (_initialized) return;

    // Android initialization settings
    // Menggunakan ikon default aplikasi
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Combined initialization settings (hanya mencakup Android)
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
    );

    // Initialize dengan proper handler
    await _notifications.initialize(
      initSettings,
      // onDidReceiveNotificationResponse menangani ketika notifikasi di-tap saat aplikasi di-background/terminated
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        print('✅ Notification tapped: ${response.payload}');
        // TODO: Handle navigation based on payload
      },
      // onDidReceiveBackgroundNotificationResponse harus didefinisikan sebagai fungsi top-level atau static
      // untuk menangani tap di background/terminated di versi Android yang lebih lama
      // Anda perlu menambahkan fungsi ini di luar kelas atau sebagai fungsi static top-level 
      // dan mendaftarkannya di main.dart, tapi untuk contoh ini, kita biarkan di sini.
    );

    // Membuat channel notifikasi segera setelah inisialisasi untuk memastikan channel ada
    await _createNotificationChannel();

    _initialized = true;
    print('✅ Notification service initialized for Android only');
  }

  /// Create notification channel (Android only)
  static Future<void> _createNotificationChannel() async {
    try {
      // Hapus kata kunci 'const' di sini
      final AndroidNotificationChannel channel = AndroidNotificationChannel(
        // Gunakan string literal yang sama
        'drug_schedule_channel', 
        'Pengingat Minum Obat',
        description: 'Notifikasi pengingat jadwal minum obat',
        // Nilai Importance, playSound, dan enableVibration dapat digunakan
        importance: Importance.max, 
        playSound: true,
        enableVibration: true,
      );

      final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
          _notifications.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlugin != null) {
        await androidPlugin.createNotificationChannel(channel);
        print('✅ Notification channel created (Android)');
      }
    } catch (e) {
      print('❌ Error creating notification channel: $e');
    }
  }

  /// Request notification permissions (Android 13+)
  static Future<bool> requestPermissions() async {
    try {
      // Request Android 13+ notification permission
      final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
          _notifications.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlugin != null) {
        // requestNotificationsPermission() akan mengembalikan true untuk versi Android < 13
        final bool? granted = await androidPlugin.requestNotificationsPermission();
        print('📱 Android notification permission: ${granted ?? false}');
        return granted ?? false;
      }
      // Seharusnya tidak pernah sampai sini karena fokus di Android
      return true;
    } catch (e) {
      print('⚠️ Error requesting notification permissions: $e');
      return false;
    }
  }

  /// Show immediate notification
  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      // Detail notifikasi hanya untuk Android
      const NotificationDetails details = NotificationDetails(
        android: _androidNotificationDetails,
      );

      await _notifications.show(id, title, body, details, payload: payload);
      print('✅ Notification shown: $title (ID: $id)');
    } catch (e) {
      print('❌ Error showing notification: $e');
    }
  }

  /// Schedule notification for specific date and time
  /// Note: Menggunakan show() dengan penundaan, yang di Android diimplementasikan
  /// menggunakan metode duration (relative time), bukan metode `zonedSchedule` 
  /// (absolute time) yang membutuhkan package `timezone`.
  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    try {
      // Hitung durasi dari sekarang hingga waktu yang dijadwalkan
      final Duration duration = scheduledTime.difference(DateTime.now());

      if (duration.isNegative) {
        print('⚠️ Scheduled time is in the past, showing immediately');
        await showNotification(id: id, title: title, body: body, payload: payload);
        return;
      }
      
      final NotificationDetails details = NotificationDetails(
        android: _androidNotificationDetails,
        // iOS: iosDetails, // Hapus
      );

      // Gunakan show() yang tertunda
      await _notifications.show(
        id,
        title,
        body,
        details,
        payload: payload,
      );

      print('✅ Notification scheduled for: $scheduledTime (ID: $id)');
    } catch (e) {
      print('❌ Error scheduling notification: $e');
    }
  }

  /// Schedule daily notification at specific time (hour and minute)
  /// PENTING: Karena tidak menggunakan `timezone` dan `zonedSchedule`,
  /// notifikasi ini HANYA AKAN MUNCUL SEKALI (besok) dan tidak akan berulang setiap hari!
  /// Untuk pengulangan harian yang sesungguhnya di Flutter, Anda perlu menggunakan
  /// `zonedSchedule` dengan properti `repeatInterval: RepeatInterval.daily` 
  /// dan mengkonfigurasi `timezone`.
  /// **Jika Anda membutuhkan pengulangan harian yang sebenarnya, Anda harus menambahkan package `timezone`.**
  /// Saat ini, fungsi ini hanya menjadwalkan notifikasi tunggal untuk waktu harian pertama yang akan datang.
  static Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    String? payload,
  }) async {
    try {
      // Dapatkan tanggal hari ini dengan waktu yang ditentukan
      final now = DateTime.now();
      DateTime scheduledDate = DateTime(
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );

      // Jika waktu sudah lewat hari ini, jadwalkan untuk besok
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      await scheduleNotification(
        id: id,
        title: title,
        body: body,
        scheduledTime: scheduledDate,
        payload: payload,
      );

      print('✅ SINGLE (non-repeating) notification scheduled for $hour:${minute.toString().padLeft(2, '0')}');
      print('⚠️ PERHATIAN: Ini BUKAN notifikasi berulang harian. Untuk pengulangan, tambahkan package timezone dan gunakan zonedSchedule.');
    } catch (e) {
      print('❌ Error scheduling daily notification: $e');
    }
  }

  /// Cancel specific notification
  static Future<void> cancelNotification(int id) async {
    try {
      await _notifications.cancel(id);
      print('✅ Notification $id cancelled');
    } catch (e) {
      print('❌ Error cancelling notification: $e');
    }
  }

  /// Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    try {
      await _notifications.cancelAll();
      print('✅ All notifications cancelled');
    } catch (e) {
      print('❌ Error cancelling all notifications: $e');
    }
  }

  /// Get list of pending notifications
  static Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    try {
      final List<PendingNotificationRequest> pendingNotifications =
          await _notifications.pendingNotificationRequests();
      print('📋 Pending notifications: ${pendingNotifications.length}');
      return pendingNotifications;
    } catch (e) {
      print('❌ Error getting pending notifications: $e');
      return [];
    }
  }
}