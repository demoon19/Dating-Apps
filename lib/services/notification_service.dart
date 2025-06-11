import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  // Buat instance dari plugin notifikasi
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Metode untuk inisialisasi plugin
  static Future<void> init() async {
    // Pengaturan untuk Android
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Pengaturan untuk iOS
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Gabungkan pengaturan
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    // Inisialisasi plugin dengan pengaturan di atas
    await _notificationsPlugin.initialize(initializationSettings);
  }

  // Metode untuk menampilkan notifikasi
  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    // Detail notifikasi untuk Android
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'dating_channel_id', // ID channel
      'Dating Notifications', // Nama channel
      channelDescription: 'Notifications for like/dislike actions',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    // Gabungkan detail notifikasi untuk setiap platform
    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);
    
    // Tampilkan notifikasi
    await _notificationsPlugin.show(id, title, body, notificationDetails);
  }
}