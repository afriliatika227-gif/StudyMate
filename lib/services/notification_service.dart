
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'deadline_reminders_v2';
  static const String _channelName = 'Pengingat Deadline StudyMate';

  static const AndroidNotificationChannel _channel =
      AndroidNotificationChannel(
    _channelId,
    _channelName,
    description: 'Pengingat tugas dan batas waktu StudyMate',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
  );

  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );

    await _plugin.initialize(settings: settings);

    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await android?.createNotificationChannel(_channel);
    await android?.requestNotificationsPermission();
    await android?.requestExactAlarmsPermission();

    _initialized = true;
  }

  static NotificationDetails get _details => const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: 'Pengingat deadline tugas StudyMate',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          icon: '@mipmap/ic_launcher',
        ),
      );

  static Future<void> showTestNotification() async {
    await initialize();

    await _plugin.show(
      id: 999999,
      title: 'Tes Notifikasi StudyMate 🔔',
      body: 'Ini adalah tes suara notifikasi StudyMate.',
      notificationDetails: _details,
    );
  }

  static Future<void> scheduleTestNotification() async {
    await initialize();

    final waktuTes =
        tz.TZDateTime.now(tz.local).add(const Duration(minutes: 1));

    await _jadwalkan(
      id: 999998,
      judul: 'Tes Notifikasi StudyMate 🔔',
      isi: 'Ini adalah tes notifikasi satu menit kemudian.',
      waktu: waktuTes,
    );
  }

  static Future<void> scheduleTaskReminders({
    required int taskId,
    required String title,
    required DateTime deadline,
  }) async {
    await initialize();
    await cancelTaskReminders(taskId);

    final sekarang = tz.TZDateTime.now(tz.local);
    final batasWaktu = tz.TZDateTime.from(deadline, tz.local);

    if (!batasWaktu.isAfter(sekarang)) return;

    final namaTugas = title.trim().isEmpty ? 'Tugas' : title.trim();

    await _jadwalkan(
      id: taskId * 1000 + 4,
      judul: 'Deadline Tugas! 🔔',
      isi: 'Waktu pengumpulan "$namaTugas" sudah tiba.',
      waktu: batasWaktu,
    );

    final sehariSebelum =
        batasWaktu.subtract(const Duration(hours: 24));

    if (sehariSebelum.isAfter(sekarang)) {
      await _jadwalkan(
        id: taskId * 1000 + 1,
        judul: 'Pengingat Deadline',
        isi: 'Besok deadline "$namaTugas". Yuk, persiapkan!',
        waktu: sehariSebelum,
      );
    }

    final tigaPuluhMenitSebelum =
        batasWaktu.subtract(const Duration(minutes: 30));

    if (tigaPuluhMenitSebelum.isAfter(sekarang)) {
      await _jadwalkan(
        id: taskId * 1000 + 2,
        judul: 'Deadline 30 Menit Lagi!',
        isi: 'Jangan lupa selesaikan "$namaTugas".',
        waktu: tigaPuluhMenitSebelum,
      );
    }

    final malamSebelum = tz.TZDateTime(
      tz.local,
      batasWaktu.year,
      batasWaktu.month,
      batasWaktu.day,
    ).subtract(const Duration(days: 1)).add(
          const Duration(hours: 20),
        );

    if (malamSebelum.isAfter(sekarang) &&
        malamSebelum.isBefore(batasWaktu)) {
      await _jadwalkan(
        id: taskId * 1000 + 3,
        judul: 'Persiapan Deadline',
        isi: 'Periksa kembali tugas "$namaTugas" untuk besok.',
        waktu: malamSebelum,
      );
    }
  }

  static Future<void> _jadwalkan({
    required int id,
    required String judul,
    required String isi,
    required tz.TZDateTime waktu,
  }) async {
    await _plugin.zonedSchedule(
      id: id,
      title: judul,
      body: isi,
      scheduledDate: waktu,
      notificationDetails: _details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  static Future<void> cancelTaskReminders(int taskId) async {
    for (final suffix in [1, 2, 3, 4]) {
      await _plugin.cancel(id: taskId * 1000 + suffix);
    }
  }

  static Future<void> cancelTestNotification() async {
    await _plugin.cancel(id: 999998);
    await _plugin.cancel(id: 999999);
  }
}