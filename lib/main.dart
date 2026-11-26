
import 'package:flutter/material.dart';
import 'screen/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const StudyMateApp());
}

class StudyMateApp extends StatelessWidget {
  const StudyMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    const biruUtama = Color(0xFF8DBBFA);
    const teksUtama = Color(0xFF35445C);
    const latar = Color(0xFFF8FAFD);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'StudyMate',

      theme: ThemeData(
        useMaterial3: true,

        // Font utama aplikasi
        fontFamily: 'Roboto',

        // Warna dasar aplikasi
        colorScheme: ColorScheme.fromSeed(
          seedColor: biruUtama,
          brightness: Brightness.light,
          surface: Colors.white,
        ),

        scaffoldBackgroundColor: latar,

        // Pengaturan AppBar
        appBarTheme: const AppBarTheme(
          backgroundColor: latar,
          foregroundColor: teksUtama,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: teksUtama,
          ),
        ),

        // Pengaturan teks
        textTheme: const TextTheme(
          headlineSmall: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: teksUtama,
          ),
          titleLarge: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: teksUtama,
          ),
          titleMedium: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: teksUtama,
          ),
          bodyLarge: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: teksUtama,
          ),
          bodyMedium: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: Color(0xFF778397),
          ),
          labelLarge: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),

        // Pengaturan tombol
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: biruUtama,
            foregroundColor: teksUtama,
            elevation: 0,
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 13,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: biruUtama,
            foregroundColor: teksUtama,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        // Pengaturan kolom input
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 15,
          ),
          hintStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: Color(0xFF9AA4B2),
          ),
          labelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: teksUtama,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xFFE2E7EF),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xFFE2E7EF),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: biruUtama,
              width: 1.5,
            ),
          ),
        ),

        // Pengaturan kartu
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(
              color: Color(0xFFEDF0F5),
            ),
          ),
        ),

        // Pengaturan dialog
        dialogTheme: DialogThemeData(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          titleTextStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: teksUtama,
          ),
          contentTextStyle: const TextStyle(
            fontSize: 14,
            color: Color(0xFF778397),
            height: 1.5,
          ),
        ),

        // Pengaturan ikon
        iconTheme: const IconThemeData(
          color: teksUtama,
          size: 22,
        ),
      ),

      home: const SplashScreen(),
    );
  }
}
