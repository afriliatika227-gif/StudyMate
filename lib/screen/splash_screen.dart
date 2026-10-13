
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
  late final AnimationController _textController;
  late final AnimationController _floatController;
  late final AnimationController _loadingController;

  late final Animation<double> _logoScale;
  late final Animation<double> _textFade;
  late final Animation<Offset> _textSlide;
  late final Animation<double> _floatAnimation;
  late final Animation<double> _loadingFade;

  Timer? _navigationTimer;

  static const Color warnaBiru = Color(0xFF6EA8FE);
  static const Color biruMuda = Color(0xFFDCEBFF);
  static const Color pinkMuda = Color(0xFFFFE1EF);
  static const Color kuningLampu = Color(0xFFFFC96B);

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _logoScale = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Curves.easeOutBack,
      ),
    );

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _textFade = CurvedAnimation(
      parent: _textController,
      curve: Curves.easeIn,
    );

    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _textController,
        curve: Curves.easeOutCubic,
      ),
    );

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _floatAnimation = Tween<double>(
      begin: -6,
      end: 6,
    ).animate(
      CurvedAnimation(
        parent: _floatController,
        curve: Curves.easeInOut,
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

    Future.delayed(const Duration(milliseconds: 250), () {
      if (!mounted) return;

      _textController.forward();
      _floatController.repeat(reverse: true);
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
            builder: (context) => const HomeScreen(),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _logoController.dispose();
    _textController.dispose();
    _floatController.dispose();
    _loadingController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Latar gradasi biru pastel dan pink pastel
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFE0EBFF),
                  Color(0xFFFFF5FA),
                  Color(0xFFFFE7F1),
                  Color(0xFFE7F1FF),
                ],
                stops: [0.0, 0.38, 0.70, 1.0],
              ),
            ),
          ),

          // Hiasan gradasi di sudut atas
          Positioned(
            top: -75,
            left: -65,
            child: _hiasanBulat(
              210,
              const Color(0xFFBBD5FF).withValues(alpha: 0.55),
            ),
          ),

          Positioned(
            top: 105,
            right: -65,
            child: _hiasanBulat(
              145,
              const Color(0xFFFFD3E7).withValues(alpha: 0.60),
            ),
          ),

          // Hiasan gradasi di sudut bawah
          Positioned(
            bottom: -90,
            right: -65,
            child: _hiasanBulat(
              230,
              const Color(0xFFBBD5FF).withValues(alpha: 0.60),
            ),
          ),

          Positioned(
            bottom: 90,
            left: -55,
            child: _hiasanBulat(
              130,
              const Color(0xFFFFD3E7).withValues(alpha: 0.65),
            ),
          ),

          // Dekorasi bintang kecil
          const Positioned(
            top: 145,
            right: 60,
            child: Icon(
              Icons.auto_awesome_rounded,
              color: Color(0xFF8AB8FF),
              size: 28,
            ),
          ),

          const Positioned(
            bottom: 150,
            left: 45,
            child: Icon(
              Icons.auto_awesome_rounded,
              color: Color(0xFFFFA9D0),
              size: 25,
            ),
          ),

          // Konten utama
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Buku terbuka dan lampu
                    ScaleTransition(
                      scale: _logoScale,
                      child: AnimatedBuilder(
                        animation: _floatAnimation,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(
                              0,
                              _floatAnimation.value,
                            ),
                            child: child,
                          );
                        },
                        child: SizedBox(
                          width: 190,
                          height: 165,
                          child: Stack(
                            alignment: Alignment.center,
                            clipBehavior: Clip.none,
                            children: [
                              // Lingkaran latar ikon
                              Container(
                                width: 150,
                                height: 140,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.white.withValues(alpha: 0.75),
                                      biruMuda.withValues(alpha: 0.65),
                                      pinkMuda.withValues(alpha: 0.55),
                                    ],
                                  ),
                                ),
                              ),

                              // Buku terbuka
                              const Positioned(
                                bottom: 12,
                                child: Icon(
                                  Icons.menu_book_rounded,
                                  size: 120,
                                  color: warnaBiru,
                                  shadows: [
                                    Shadow(
                                      color: Color(0x4080AFFF),
                                      blurRadius: 14,
                                      offset: Offset(0, 6),
                                    ),
                                  ],
                                ),
                              ),

                              // Lampu kecil di atas buku
                              Positioned(
                                top: 0,
                                child: Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFFFFE8A9)
                                        .withValues(alpha: 0.85),
                                    boxShadow: [
                                      BoxShadow(
                                        color: kuningLampu
                                            .withValues(alpha: 0.35),
                                        blurRadius: 18,
                                        spreadRadius: 3,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.lightbulb_rounded,
                                    color: Color(0xFFFFB84D),
                                    size: 37,
                                  ),
                                ),
                              ),

                              // Kilau kecil
                              const Positioned(
                                top: 8,
                                left: 12,
                                child: Icon(
                                  Icons.auto_awesome_rounded,
                                  color: Color(0xFFFFA9D0),
                                  size: 20,
                                ),
                              ),

                              const Positioned(
                                top: 55,
                                right: 4,
                                child: Icon(
                                  Icons.auto_awesome_rounded,
                                  color: Color(0xFF8AB8FF),
                                  size: 22,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 22),

                    // Tulisan Welcome to StudyMate
                    FadeTransition(
                      opacity: _textFade,
                      child: SlideTransition(
                        position: _textSlide,
                        child: Column(
                          children: [
                            const Text(
                              'Welcome to',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 23,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF719FE5),
                                letterSpacing: 1.0,
                              ),
                            ),

                            const SizedBox(height: 5),

                            Text(
                              'StudyMate',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.w800,
                                color: warnaBiru,
                                letterSpacing: 0.5,
                                shadows: [
                                  Shadow(
                                    color: warnaBiru.withValues(alpha: 0.15),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 8),

                            Container(
                              width: 105,
                              height: 4,
                              decoration: BoxDecoration(
                                color: const Color(0xFF9FC5FF),
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),

                            const SizedBox(height: 17),

                            const Text(
                              'Belajar, bertumbuh, dan raih prestasimu!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF858FA7),
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Animasi loading
                    FadeTransition(
                      opacity: _loadingFade,
                      child: const Text(
                        '•••',
                        style: TextStyle(
                          fontSize: 24,
                          color: warnaBiru,
                          letterSpacing: 6,
                        ),
                      ),
                    ),

                    const SizedBox(height: 22),

                    FadeTransition(
                      opacity: _loadingFade,
                      child: const Text(
                        'Version 1.0',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9AA2B2),
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

  // Membuat hiasan bulat pastel
  Widget _hiasanBulat(double ukuran, Color warna) {
    return Container(
      width: ukuran,
      height: ukuran,
      decoration: BoxDecoration(
        color: warna,
        shape: BoxShape.circle,
      ),
    );
  }
}