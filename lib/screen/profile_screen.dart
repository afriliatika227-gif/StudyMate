import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data_diri_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String nama = 'Tika Afrilia';

  Uint8List? fotoProfil;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  // =====================================================
  // MEMUAT DATA PROFIL DARI SHARED PREFERENCES
  // =====================================================

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();

    final namaTersimpan = prefs.getString('profile_nama');

    final fotoBase64 = prefs.getString('profile_foto');

    if (!mounted) return;

    setState(() {
      nama = namaTersimpan ?? 'Tika Afrilia';

      if (fotoBase64 != null && fotoBase64.isNotEmpty) {
        fotoProfil = base64Decode(fotoBase64);
      } else {
        fotoProfil = null;
      }

      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // =====================================================
    // LOADING
    // =====================================================

    if (isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8FAFD),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),

      // ===================================================
      // APP BAR
      // ===================================================

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Profile Saya',
          style: TextStyle(
            color: Color(0xFF222222),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // ===================================================
      // BODY
      // ===================================================

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            // =================================================
            // FOTO PROFIL
            // =================================================

            Container(
              width: 100,
              height: 100,

              decoration: BoxDecoration(
                color: const Color(0xFFEAF4FF),
                shape: BoxShape.circle,

                border: Border.all(
                  color: const Color(0xFF6EA8FE),
                  width: 2,
                ),

                image: fotoProfil != null
                    ? DecorationImage(
                        image: MemoryImage(fotoProfil!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),

              child: fotoProfil == null
                  ? const Icon(
                      Icons.person_rounded,
                      size: 55,
                      color: Color(0xFF6EA8FE),
                    )
                  : null,
            ),

            const SizedBox(height: 15),

            // =================================================
            // NAMA
            // =================================================

            Text(
              nama,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 5),

            const Text(
              'Mahasiswa',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 30),

            // =================================================
            // DATA DIRI
            // =================================================

            _profileMenu(
              icon: Icons.person_outline_rounded,
              title: 'Data Diri',
              subtitle: 'Lihat dan ubah informasi diri',

              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const DataDiriScreen(),
                  ),
                );

                // Setelah kembali dari Data Diri,
                // ambil kembali data terbaru.
                _loadProfile();
              },
            ),

            const SizedBox(height: 12),

            // =================================================
            // PENGATURAN
            // =================================================

            _profileMenu(
              icon: Icons.settings_outlined,
              title: 'Pengaturan',
              subtitle: 'Atur aplikasi StudyMate',

              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const SettingsScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            // =================================================
            // TENTANG STUDYMATE
            // =================================================

            _profileMenu(
              icon: Icons.info_outline_rounded,
              title: 'Tentang StudyMate',
              subtitle: 'Informasi tentang aplikasi',

              onTap: () {
                _showInfo(
                  context,
                  'Tentang StudyMate',
                  'StudyMate adalah aplikasi untuk membantu '
                      'mahasiswa mengelola aktivitas akademik, '
                      'jadwal, tugas, dan deadline.',
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // =====================================================
  // WIDGET MENU PROFILE
  // =====================================================

  Widget _profileMenu({
    required IconData icon,
    required String title,
    required String subtitle,
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
            // ===============================================
            // ICON MENU
            // ===============================================

            Container(
              width: 50,
              height: 50,

              decoration: BoxDecoration(
                color: const Color(0xFFEAF4FF),
                borderRadius: BorderRadius.circular(15),
              ),

              child: Icon(
                icon,
                color: const Color(0xFF6EA8FE),
                size: 26,
              ),
            ),

            const SizedBox(width: 15),

            // ===============================================
            // JUDUL + SUBTITLE
            // ===============================================

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

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

            // ===============================================
            // PANAH
            // ===============================================

            const Icon(
              Icons.chevron_right_rounded,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  // =====================================================
  // POP-UP TENTANG STUDYMATE
  // =====================================================

  void _showInfo(
    BuildContext context,
    String title,
    String message,
  ) {
    showDialog(
      context: context,

      builder: (context) {
        return AlertDialog(
          title: Text(title),

          content: Text(message),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },

              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }
}

// =====================================================
// HALAMAN PENGATURAN
// =====================================================

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() =>
      _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notificationEnabled = true;

  bool reminderEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),

      // ===================================================
      // APP BAR
      // ===================================================

      appBar: AppBar(
        title: const Text('Pengaturan'),

        backgroundColor: Colors.white,

        elevation: 0,
      ),

      // ===================================================
      // BODY
      // ===================================================

      body: ListView(
        padding: const EdgeInsets.all(20),

        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,

              borderRadius: BorderRadius.circular(18),
            ),

            child: Column(
              children: [
                // =========================================
                // NOTIFIKASI
                // =========================================

                SwitchListTile(
                  title: const Text(
                    'Notifikasi',

                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  subtitle: const Text(
                    'Aktifkan notifikasi StudyMate',
                  ),

                  value: notificationEnabled,

                  onChanged: (value) {
                    setState(() {
                      notificationEnabled = value;
                    });
                  },
                ),

                const Divider(height: 1),

                // =========================================
                // PENGINGAT DEADLINE
                // =========================================

                SwitchListTile(
                  title: const Text(
                    'Pengingat Deadline',

                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  subtitle: const Text(
                    'Mengingatkan tugas yang mendekati deadline',
                  ),

                  value: reminderEnabled,

                  onChanged: (value) {
                    setState(() {
                      reminderEnabled = value;
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}