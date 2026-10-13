
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
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _logoScale,
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF4FF),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const Icon(
                    Icons.menu_book_rounded,
                    size: 50,
                    color: warnaBiru,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              FadeTransition(
                opacity: _textFade,
                child: SlideTransition(
                  position: _textSlide,
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
                    child: const Text(
                      'StudyMate',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: warnaBiru,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              FadeTransition(
                opacity: _textFade,
                child: const Text(
                  'Kelola aktivitas akademikmu',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              FadeTransition(
                opacity: _loadingFade,
                child: const Text(
                  '•••',
                  style: TextStyle(
                    fontSize: 20,
                    color: warnaBiru,
                    letterSpacing: 5,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              FadeTransition(
                opacity: _loadingFade,
                child: const Text(
                  'Version 1.0',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
