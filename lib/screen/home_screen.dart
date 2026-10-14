
import 'package:flutter/material.dart';

import 'dashboard_screen.dart';
import 'mata_kuliah_screen.dart';
import 'jadwal_screen.dart';
import 'tugas_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;

  final List<Widget> pages = const [
    DashboardScreen(),
    MataKuliahScreen(),
    JadwalScreen(),
    TugasScreen(),
    ProfileScreen(),
  ];

  static const Color biru = Color(0xFF2878F0);
  static const Color latar = Color(0xFFF5F8FF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: latar,
      body: IndexedStack(
        index: selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(26),
          ),
          boxShadow: [
            BoxShadow(
              color: biru.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(4, 8, 4, 6),
            child: NavigationBarTheme(
              data: NavigationBarThemeData(
                backgroundColor: Colors.white,
                indicatorColor: const Color(0xFFE5EFFF),
                height: 68,
                elevation: 0,
                labelTextStyle: WidgetStateProperty.resolveWith(
                  (states) {
                    if (states.contains(WidgetState.selected)) {
                      return const TextStyle(
                        color: biru,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      );
                    }

                    return const TextStyle(
                      color: Color(0xFF788397),
                      fontWeight: FontWeight.w500,
                      fontSize: 11,
                    );
                  },
                ),
                iconTheme: WidgetStateProperty.resolveWith(
                  (states) {
                    if (states.contains(WidgetState.selected)) {
                      return const IconThemeData(
                        color: biru,
                        size: 24,
                      );
                    }

                    return const IconThemeData(
                      color: Color(0xFF788397),
                      size: 22,
                    );
                  },
                ),
              ),
              child: NavigationBar(
                selectedIndex: selectedIndex,
                onDestinationSelected: (index) {
                  setState(() {
                    selectedIndex = index;
                  });
                },
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.home_outlined),
                    selectedIcon: Icon(Icons.home_rounded),
                    label: 'Beranda',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.menu_book_outlined),
                    selectedIcon: Icon(Icons.menu_book_rounded),
                    label: 'Matkul',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.calendar_month_outlined),
                    selectedIcon: Icon(Icons.calendar_month_rounded),
                    label: 'Jadwal',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.assignment_outlined),
                    selectedIcon: Icon(Icons.assignment_rounded),
                    label: 'Tugas',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.person_outline_rounded),
                    selectedIcon: Icon(Icons.person_rounded),
                    label: 'Profil',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
