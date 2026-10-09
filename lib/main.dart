
import 'package:flutter/material.dart';

import 'screen/splash_screen.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Siapkan notifikasi.
  await NotificationService.initialize();

  // Jadwalkan notifikasi tes satu menit kemudian.
  await NotificationService.scheduleTestNotification();

  runApp(const StudyMateApp());
}

class StudyMateApp extends StatelessWidget {
  const StudyMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'StudyMate',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6EA8FE),
        ),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}