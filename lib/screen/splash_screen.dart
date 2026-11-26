
import 'dart:async';
import 'package:flutter/material.dart';

import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _logoController;
  late final AnimationController _contentController;
  late final AnimationController _loadingController;

  late final Animation<double> _logoScale;
  late final Animation<double> _contentFade;
  late final Animation<Offset> _contentSlide;
  late final Animation<double> _loadingFade;

  Timer? _navigationTimer;

  static const Color biru = Color(0xFF82B4F5);
  static const Color teks = Color(0xFF35445C);
  static const Color muted = Color(0xFF8995A8);

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _logoScale = Tween<double>(
      begin: 0.85,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Curves.easeOutCubic,
      ),
    );

    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _contentFade = CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeIn,
    );

    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: Curves.easeOutCubic,
      ),
    );

    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _loadingFade = CurvedAnimation(
      parent: _loadingController,
      curve: Curves.easeIn,
    );

    _logoController.forward();

    Future.delayed(const Duration(milliseconds: 200), () {
      if (!mounted) return;
      _contentController.forward();
    });

    Future.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      _loadingController.forward();
    });

    _navigationTimer = Timer(
      const Duration(seconds: 3),
      () {
        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const HomeScreen(),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _logoController.dispose();
    _contentController.dispose();
    _loadingController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFE),
      body: Stack(
        children: [
          // Dekorasi pastel bagian atas
          Positioned(
            top: -85,
            right: -75,
            child: _decoration(
              210,
              const Color(0xFFE5EEFF),
            ),
          ),

          // Dekorasi pastel bagian bawah
          Positioned(
            bottom: -100,
            left: -85,
            child: _decoration(
              230,
              const Color(0xFFF9EAF2),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 30,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo buku terbuka
                    ScaleTransition(
                      scale: _logoScale,
                      child: Container(
                        width: 170,
                        height: 155,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAF2FF),
                          borderRadius: BorderRadius.circular(35),
                        ),
                        child: _buildBookLogo(),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Tulisan StudyMate
                    FadeTransition(
                      opacity: _contentFade,
                      child: SlideTransition(
                        position: _contentSlide,
                        child: Column(
                          children: [
                            const Text(
                              'Welcome to',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: muted,
                              ),
                            ),

                            const SizedBox(height: 7),

                            const Text(
                              'StudyMate',
                              style: TextStyle(
                                fontSize: 34,
                                fontWeight: FontWeight.w600,
                                color: teks,
                                letterSpacing: -0.7,
                              ),
                            ),

                            const SizedBox(height: 12),

                            const Text(
                              'Kelola aktivitas akademikmu\n'
                              'dengan lebih mudah dan teratur.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                height: 1.6,
                                color: muted,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 42),

                    // Loading
                    FadeTransition(
                      opacity: _loadingFade,
                      child: const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: biru,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    FadeTransition(
                      opacity: _loadingFade,
                      child: const Text(
                        'Version 1.0',
                        style: TextStyle(
                          fontSize: 11,
                          color: muted,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Ilustrasi buku terbuka
  Widget _buildBookLogo() {
    return SizedBox(
      width: 150,
      height: 124,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Sampul belakang buku
          Positioned(
            bottom: 17,
            child: Container(
              width: 116,
              height: 75,
              decoration: BoxDecoration(
                color: const Color(0xFF82B4F5),
                borderRadius: BorderRadius.circular(9),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF82B4F5)
                        .withValues(alpha: 0.25),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
            ),
          ),

          // Halaman kiri
          Positioned(
            left: 15,
            bottom: 23,
            child: Transform.rotate(
              angle: -0.07,
              child: _bookPage(isLeft: true),
            ),
          ),

          // Halaman kanan
          Positioned(
            right: 15,
            bottom: 23,
            child: Transform.rotate(
              angle: 0.07,
              child: _bookPage(isLeft: false),
            ),
          ),

          // Garis tengah buku
          Positioned(
            bottom: 22,
            child: Container(
              width: 3,
              height: 65,
              decoration: BoxDecoration(
                color: const Color(0xFF719FD9),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),

          // Pita pink
          Positioned(
            top: 18,
            right: 35,
            child: Container(
              width: 10,
              height: 25,
              decoration: const BoxDecoration(
                color: Color(0xFFFFAFCB),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(3),
                  bottomRight: Radius.circular(3),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Membuat halaman buku
  Widget _bookPage({required bool isLeft}) {
    return Container(
      width: 60,
      height: 65,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFEFC),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(isLeft ? 9 : 3),
          topRight: Radius.circular(isLeft ? 3 : 9),
          bottomLeft: Radius.circular(isLeft ? 5 : 3),
          bottomRight: Radius.circular(isLeft ? 3 : 5),
        ),
        border: Border.all(
          color: const Color(0xFFE4EAF2),
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(
          4,
          (index) => Container(
            margin: const EdgeInsets.only(bottom: 7),
            height: 2,
            width: index == 3 ? 25 : 37,
            decoration: BoxDecoration(
              color: const Color(0xFFD5DFEC),
              borderRadius: BorderRadius.circular(5),
            ),
          ),
        ),
      ),
    );
  }

  // Dekorasi lingkaran pastel
  Widget _decoration(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
