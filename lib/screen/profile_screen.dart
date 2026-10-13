
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

  static const Color biru = Color(0xFF6EA8FE);
  static const Color latar = Color(0xFFF5F8FF);
  static const Color teks = Color(0xFF23395D);

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  // Memuat nama dan foto profil dari penyimpanan lokal.
  Future<void> _loadProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final namaTersimpan = prefs.getString('profile_nama');
      final fotoBase64 = prefs.getString('profile_foto');

      Uint8List? foto;

      if (fotoBase64 != null && fotoBase64.isNotEmpty) {
        try {
          foto = base64Decode(fotoBase64);
        } catch (_) {
          foto = null;
        }
      }

      if (!mounted) return;

      setState(() {
        nama = namaTersimpan ?? 'Tika Afrilia';
        fotoProfil = foto;
        isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal memuat data profil.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: latar,
        body: Center(
          child: CircularProgressIndicator(color: biru),
        ),
      );
    }

    return Scaffold(
      backgroundColor: latar,
      appBar: AppBar(
        backgroundColor: latar,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Profile Saya',
          style: TextStyle(
            color: teks,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          _buildProfileHeader(),

          const SizedBox(height: 25),

          const Text(
            'Akun Saya',
            style: TextStyle(
              color: teks,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 13),

          _profileMenu(
            icon: Icons.person_outline_rounded,
            title: 'Data Diri',
            subtitle: 'Lihat dan ubah informasi diri',
            color: const Color(0xFFE4EEFF),
            iconColor: const Color(0xFF4E83D9),
            onTap: _openDataDiri,
          ),

          const SizedBox(height: 12),

          _profileMenu(
            icon: Icons.settings_outlined,
            title: 'Pengaturan',
            subtitle: 'Atur preferensi aplikasi',
            color: const Color(0xFFECE7FF),
            iconColor: const Color(0xFF8870CE),
            onTap: _openSettings,
          ),

          const SizedBox(height: 12),

          _profileMenu(
            icon: Icons.auto_awesome_outlined,
            title: 'Tentang StudyMate',
            subtitle: 'Kenali aplikasi StudyMate',
            color: const Color(0xFFDFF5E8),
            iconColor: const Color(0xFF45996B),
            onTap: () {
              _showInfo(
                'Tentang StudyMate',
                'StudyMate adalah aplikasi untuk membantu '
                    'mahasiswa mengelola aktivitas akademik, '
                    'jadwal, tugas, dan deadline.',
              );
            },
          ),

          const SizedBox(height: 24),

          _buildMotivationCard(),
        ],
      ),
    );
  }

  // Header profil dengan gradasi pastel.
  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 27, 20, 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFDCEBFF),
            Color(0xFFB9D8FF),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: biru.withOpacity(0.25),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 48,
                  backgroundColor: const Color(0xFFEAF2FF),
                  backgroundImage: fotoProfil != null
                      ? MemoryImage(fotoProfil!)
                      : null,
                  child: fotoProfil == null
                      ? const Icon(
                          Icons.person_rounded,
                          size: 54,
                          color: biru,
                        )
                      : null,
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 33,
                  height: 33,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFDCEBFF),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    size: 17,
                    color: biru,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 17),

          Text(
            nama,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: teks,
              fontSize: 23,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 8),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.75),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Text(
              'Mahasiswa',
              style: TextStyle(
                color: teks,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(height: 15),

          const Text(
            '✨ Terus bertumbuh, satu langkah setiap hari.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: teks,
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // Menu profil dengan ikon pastel.
  Widget _profileMenu({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(21),
      child: InkWell(
        borderRadius: BorderRadius.circular(21),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 15,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(21),
            border: Border.all(
              color: const Color(0xFFE8EEF8),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 49,
                height: 49,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 25,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: teks,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF8190A8),
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 15,
                color: Color(0xFF9BAAC0),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Kartu motivasi.
  Widget _buildMotivationCard() {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFE7EEFA),
        ),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.favorite_rounded,
            color: Color(0xFFEF9CA8),
            size: 25,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Pelan-pelan tidak apa-apa, yang penting tetap melangkah.',
              style: TextStyle(
                color: teks,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openDataDiri() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const DataDiriScreen(),
      ),
    );

    if (!mounted) return;
    await _loadProfile();
  }

  Future<void> _openSettings() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const SettingsScreen(),
      ),
    );
  }

  void _showInfo(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }
}

// =====================================================
// HALAMAN PENGATURAN
// =====================================================

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notificationEnabled = true;
  bool reminderEnabled = true;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (!mounted) return;

      setState(() {
        notificationEnabled =
            prefs.getBool('notification_enabled') ?? true;
        reminderEnabled =
            prefs.getBool('reminder_enabled') ?? true;
        isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  Future<void> _saveSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F8FF),
        elevation: 0,
        title: const Text(
          'Pengaturan',
          style: TextStyle(
            color: Color(0xFF23395D),
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF6EA8FE),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: const Color(0xFFE7EEFA),
                    ),
                  ),
                  child: Column(
                    children: [
                      SwitchListTile(
                        activeThumbColor: const Color(0xFF6EA8FE),
                        secondary: const Icon(
                          Icons.notifications_active_outlined,
                          color: Color(0xFF6EA8FE),
                        ),
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
                        onChanged: (value) async {
                          setState(() {
                            notificationEnabled = value;
                          });
                          await _saveSetting(
                            'notification_enabled',
                            value,
                          );
                        },
                      ),

                      const Divider(
                        height: 1,
                        indent: 16,
                        endIndent: 16,
                      ),

                      SwitchListTile(
                        activeThumbColor: const Color(0xFF6EA8FE),
                        secondary: const Icon(
                          Icons.alarm_on_outlined,
                          color: Color(0xFF8870CE),
                        ),
                        title: const Text(
                          'Pengingat Deadline',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: const Text(
                          'Mengingatkan tugas mendekati deadline',
                        ),
                        value: reminderEnabled,
                        onChanged: (value) async {
                          setState(() {
                            reminderEnabled = value;
                          });
                          await _saveSetting(
                            'reminder_enabled',
                            value,
                          );
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
