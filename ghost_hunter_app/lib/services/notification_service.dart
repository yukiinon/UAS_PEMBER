import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:math';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = 
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _notifications.initialize(initializationSettings);
  }

  static Future<void> showGhostDetectedNotification(String ghostName) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'ghost_channel',
      'Notifikasi Hantu',
      channelDescription: 'Notifikasi untuk deteksi hantu',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _notifications.show(
      0,
      '👻 Hantu Terdeteksi!',
      'Anda bertemu dengan: $ghostName',
      platformChannelSpecifics,
    );
  }

  static Future<void> showRandomGhostAlert() async {
    final List<String> messages = [
      'Aktivitas hantu terdeteksi di sekitar!',
      'Energi paranormal tinggi di area Anda',
      'Waktu yang tepat untuk berburu hantu!',
      'Arwah-arwah gelisah malam ini...',
      'Fenomena aneh dilaporkan di sekitar'
    ];

    final random = Random();
    final message = messages[random.nextInt(messages.length)];

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'ghost_alert_channel',
      'Peringatan Hantu',
      channelDescription: 'Peringatan aktivitas hantu acak',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _notifications.show(
      1,
      '👻 Peringatan Hantu',
      message,
      platformChannelSpecifics,
    );
  }
}