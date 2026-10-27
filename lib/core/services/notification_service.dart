import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Service untuk menangani notifikasi lokal di aplikasi LangkahAwal.
///
/// Fitur:
/// - Inisialisasi plugin & channel notifikasi
/// - Permintaan izin (permission request) di Android 13+ & iOS
/// - Menjadwalkan pengingat evaluasi KPSP berkala
/// - Membatalkan pengingat
class NotificationService {
  NotificationService._();

  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'kpsp_reminder_channel';
  static const String _channelName = 'Pengingat Evaluasi KPSP';
  static const String _channelDescription =
      'Notifikasi pengingat untuk melakukan evaluasi berkala tumbuh kembang anak (KPSP).';

  /// Inisialisasi notification service & timezone data.
  static Future<void> initialize() async {
    try {
      // Inisialisasi timezone database untuk penjadwalan
      tz.initializeTimeZones();

      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const darwinSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
      );

      await _notificationsPlugin.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          debugPrint('Notification clicked with payload: ${response.payload}');
        },
      );

      // Setup Android Channel
      final androidPlatform = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlatform != null) {
        const androidChannel = AndroidNotificationChannel(
          _channelId,
          _channelName,
          description: _channelDescription,
          importance: Importance.high,
          playSound: true,
          enableVibration: true,
        );

        await androidPlatform.createNotificationChannel(androidChannel);

        // Minta izin notifikasi (Android 13+)
        await androidPlatform.requestNotificationsPermission();
      }
    } catch (e, stack) {
      debugPrint('Error initializing NotificationService: $e\n$stack');
    }
  }

  /// Menampilkan notifikasi langsung (bisa untuk konfirmasi saat toggle dinyalakan).
  static Future<void> showNotification({
    int id = 0,
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );

      const darwinDetails = DarwinNotificationDetails();

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: darwinDetails,
      );

      await _notificationsPlugin.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: notificationDetails,
        payload: payload,
      );
    } catch (e) {
      debugPrint('Error showing notification: $e');
    }
  }

  /// Menjadwalkan pengingat evaluasi KPSP untuk seorang anak.
  ///
  /// Secara default, jika [scheduledDate] tidak diberikan,
  /// jadwal akan diatur untuk 30 hari ke depan pada jam 09:00 pagi.
  static Future<void> scheduleKpspReminder({
    required int id,
    required String childName,
    int? nextMilestoneAge,
    DateTime? scheduledDate,
  }) async {
    try {
      final targetDate = scheduledDate ??
          DateTime.now().add(const Duration(days: 30)).copyWith(
                hour: 9,
                minute: 0,
                second: 0,
                millisecond: 0,
              );

      final tzDateTime = tz.TZDateTime.from(targetDate, tz.local);

      final title = 'Jadwal Evaluasi KPSP: $childName 👶';
      final body = nextMilestoneAge != null
          ? 'Waktunya cek milestone usia $nextMilestoneAge bulan untuk $childName. Pantau terus perkembangannya!'
          : 'Yuk luangkan waktu untuk memantau perkembangan Si Kecil hari ini!';

      const androidDetails = AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );

      const darwinDetails = DarwinNotificationDetails();

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: darwinDetails,
      );

      await _notificationsPlugin.zonedSchedule(
        id: id,
        scheduledDate: tzDateTime,
        notificationDetails: notificationDetails,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        title: title,
        body: body,
        payload: 'kpsp_reminder_$id',
      );
      debugPrint('KPSP Reminder scheduled for $childName at $tzDateTime');
    } catch (e) {
      debugPrint('Error scheduling KPSP reminder: $e');
    }
  }

  /// Membatalkan pengingat berdasarkan ID.
  static Future<void> cancelReminder(int id) async {
    try {
      await _notificationsPlugin.cancel(id: id);
      debugPrint('Reminder with ID $id cancelled');
    } catch (e) {
      debugPrint('Error cancelling reminder $id: $e');
    }
  }

  /// Membatalkan seluruh jadwal pengingat.
  static Future<void> cancelAllReminders() async {
    try {
      await _notificationsPlugin.cancelAll();
      debugPrint('All reminders cancelled');
    } catch (e) {
      debugPrint('Error cancelling all reminders: $e');
    }
  }
}
