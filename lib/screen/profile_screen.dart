
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data_diri_screen.dart';

const Color _plum = Color(0xFF66527F);
const Color _darkPlum = Color(0xFF423650);
const Color _background = Color(0xFFFAF8FC);
const Color _line = Color(0xFFEAE5EF);
const Color _muted = Color(0xFF8B8494);
const Color _pink = Color(0xFFD7799E);
const Color _softLavender = Color(0xFFF0EBF7);
const Color _softPink = Color(0xFFFFF0F5);
const Color _softMint = Color(0xFFE8F5EF);

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
        backgroundColor: _background,
        body: Center(
          child: CircularProgressIndicator(color: _plum),
        ),
      );
    }

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: const Text(
          'Profile Saya',
          style: TextStyle(
            color: _darkPlum,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(
            height: 1,
            thickness: 1,
            color: _line,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 20, 18, 28),
        children: [
          _buildProfileHeader(),

          const SizedBox(height: 27),

          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: _pink,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              const SizedBox(width: 9),
              const Text(
                'Akun Saya',
                style: TextStyle(
                  color: _darkPlum,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          _profileMenu(
            icon: Icons.person_outline_rounded,
            title: 'Data Diri',
            subtitle: 'Lihat dan ubah informasi diri',
            color: _softLavender,
            iconColor: _plum,
            onTap: _openDataDiri,
          ),

          const SizedBox(height: 11),

          _profileMenu(
            icon: Icons.settings_outlined,
            title: 'Pengaturan',
            subtitle: 'Atur preferensi aplikasi',
            color: _softPink,
            iconColor: _pink,
            onTap: _openSettings,
          ),

          const SizedBox(height: 11),

          _profileMenu(
            icon: Icons.auto_awesome_outlined,
            title: 'Tentang StudyMate',
            subtitle: 'Kenali aplikasi StudyMate',
            color: _softMint,
            iconColor: const Color(0xFF36A875),
            onTap: () {
              _showInfo(
                'Tentang StudyMate',
                'StudyMate adalah aplikasi untuk membantu '
                    'mahasiswa mengelola aktivitas akademik, '
                    'jadwal, tugas, dan deadline.',
              );
            },
          ),

          const SizedBox(height: 25),

          _buildMotivationCard(),
        ],
      ),
    );
  }

  // Header profil.
  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 26, 20, 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFF0EBF7),
            Color(0xFFFFF5F8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: const Color(0xFFE8DFEF),
        ),
      ),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _plum.withValues(alpha: 0.12),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 49,
                  backgroundColor: const Color(0xFFE8DFEF),
                  backgroundImage: fotoProfil != null
                      ? MemoryImage(fotoProfil!)
                      : null,
                  child: fotoProfil == null
                      ? const Icon(
                          Icons.person_rounded,
                          size: 53,
                          color: _plum,
                        )
                      : null,
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: _plum,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    size: 15,
                    color: Colors.white,
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
              color: _darkPlum,
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 9),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.school_rounded,
                  color: _plum,
                  size: 14,
                ),
                SizedBox(width: 6),
                Text(
                  'Mahasiswa',
                  style: TextStyle(
                    color: _plum,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 15),

          const Text(
            'Terus bertumbuh, satu langkah setiap hari.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _darkPlum,
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // Menu profil.
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
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 15,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: _line),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 23,
                ),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: _darkPlum,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: _muted,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.chevron_right_rounded,
                size: 23,
                color: _muted,
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: _line),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.favorite_rounded,
            color: _pink,
            size: 23,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Pelan-pelan tidak apa-apa, yang penting tetap melangkah.',
              style: TextStyle(
                color: _darkPlum,
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
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: _darkPlum,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          message,
          style: const TextStyle(
            color: _muted,
            height: 1.6,
            fontSize: 13,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Tutup',
              style: TextStyle(
                color: _plum,
                fontWeight: FontWeight.w600,
              ),
            ),
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
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Pengaturan',
          style: TextStyle(
            color: _darkPlum,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        iconTheme: const IconThemeData(
          color: _darkPlum,
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(
            height: 1,
            thickness: 1,
            color: _line,
          ),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: _plum,
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(18),
              children: [
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 20,
                      decoration: BoxDecoration(
                        color: _pink,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    const SizedBox(width: 9),
                    const Text(
                      'Preferensi Aplikasi',
                      style: TextStyle(
                        color: _darkPlum,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: _line),
                  ),
                  child: Column(
                    children: [
                      SwitchListTile(
                        activeThumbColor: _plum,
                        secondary: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: _softLavender,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.notifications_active_outlined,
                            color: _plum,
                            size: 21,
                          ),
                        ),
                        title: const Text(
                          'Notifikasi',
                          style: TextStyle(
                            color: _darkPlum,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: const Text(
                          'Aktifkan notifikasi StudyMate',
                          style: TextStyle(
                            color: _muted,
                            fontSize: 12,
                          ),
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
                        color: _line,
                      ),

                      SwitchListTile(
                        activeThumbColor: _plum,
                        secondary: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: _softPink,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.alarm_on_outlined,
                            color: _pink,
                            size: 21,
                          ),
                        ),
                        title: const Text(
                          'Pengingat Deadline',
                          style: TextStyle(
                            color: _darkPlum,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: const Text(
                          'Mengingatkan tugas mendekati deadline',
                          style: TextStyle(
                            color: _muted,
                            fontSize: 12,
                          ),
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
