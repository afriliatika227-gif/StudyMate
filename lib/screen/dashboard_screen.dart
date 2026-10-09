import 'package:flutter/material.dart';

import 'mata_kuliah_screen.dart';
import 'tugas_screen.dart';
import 'jadwal_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),

      // =========================
      // APP BAR
      // =========================
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'StudyMate',
          style: TextStyle(
            color: Color(0xFF6EA8FE),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),

      // =========================
      // BODY
      // =========================
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =========================
            // SAPAAN
            // =========================
            const Text(
              'Halo, Tika Afrilia 👋',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              'Kelola aktivitas akademikmu dengan mudah.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 25),

            // =========================
            // RINGKASAN
            // =========================
            Row(
              children: [
                // =========================
                // MATA KULIAH
                // =========================
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const MataKuliahScreen(),
                        ),
                      );
                    },
                    child: _summaryCard(
                      icon: Icons.menu_book_rounded,
                      number: '6',
                      title: 'Mata Kuliah',
                      color: const Color(0xFFEAF4FF),
                      iconColor: const Color(0xFF6EA8FE),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // =========================
                // TUGAS AKTIF
                // =========================
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TugasScreen(),
                        ),
                      );
                    },
                    child: _summaryCard(
                      icon: Icons.assignment_rounded,
                      number: '4',
                      title: 'Tugas Aktif',
                      color: const Color(0xFFFFF0F5),
                      iconColor: const Color(0xFFE88DA8),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // =========================
            // DEADLINE TERDEKAT
            // =========================
            GestureDetector(
              onTap: () {
                // Deadline sekarang menjadi bagian
                // dari halaman Tugas
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TugasScreen(),
                  ),
                );
              },
              child: _summaryCard(
                icon: Icons.notifications_active_rounded,
                number: '2',
                title: 'Deadline Terdekat',
                color: const Color(0xFFFFF7E8),
                iconColor: const Color(0xFFE5A93D),
              ),
            ),

            const SizedBox(height: 28),

            // =========================
            // MENU UTAMA
            // =========================
            const Text(
              'Menu Utama',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 14),

            // =========================
            // JADWAL KULIAH
            // =========================
            _menuCard(
              icon: Icons.calendar_month_rounded,
              title: 'Jadwal Kuliah',
              subtitle: 'Lihat jadwal kuliahmu',
              color: const Color(0xFFEAF4FF),
              iconColor: const Color(0xFF6EA8FE),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const JadwalScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            // =========================
            // TUGAS
            // =========================
            _menuCard(
              icon: Icons.assignment_rounded,
              title: 'Tugas',
              subtitle: 'Kelola tugas dan deadline',
              color: const Color(0xFFFFF0F5),
              iconColor: const Color(0xFFE88DA8),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TugasScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            // =========================
            // MATA KULIAH
            // =========================
            _menuCard(
              icon: Icons.menu_book_rounded,
              title: 'Mata Kuliah',
              subtitle: 'Lihat daftar mata kuliah',
              color: const Color(0xFFEAF7EF),
              iconColor: const Color(0xFF6EB58A),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MataKuliahScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // =====================================================
  // WIDGET KARTU RINGKASAN
  // =====================================================

  Widget _summaryCard({
    required IconData icon,
    required String number,
    required String title,
    required Color color,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: iconColor,
            size: 30,
          ),

          const SizedBox(height: 12),

          Text(
            number,
            style: const TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // WIDGET MENU CARD
  // =====================================================

  Widget _menuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 27,
              ),
            ),

            const SizedBox(width: 15),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.chevron_right_rounded,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}