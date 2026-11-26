
import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import 'mata_kuliah_screen.dart';
import 'tugas_screen.dart';
import 'jadwal_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  static const Color biru = Color(0xFF3478C8);
  static const Color latar = Color(0xFFF5F7FA);
  static const Color teks = Color(0xFF344054);
  static const Color muted = Color(0xFF7C8798);
  static const Color garis = Color(0xFFE4E8EF);

  static const Color softBlue = Color(0xFFEAF2FC);
  static const Color softPink = Color(0xFFFCECF2);
  static const Color softMint = Color(0xFFEAF4EF);
  static const Color softPeach = Color(0xFFFBF1E3);
  static const Color softLavender = Color(0xFFF0EDFA);

  final DatabaseHelper _db = DatabaseHelper.instance;

  int jumlahMataKuliah = 0;
  int jumlahTugasAktif = 0;
  int jumlahDeadline = 0;
  bool sedangMemuat = true;

  @override
  void initState() {
    super.initState();
    _muatRingkasan();
  }

  Future<void> _muatRingkasan() async {
    try {
      final hasilMataKuliah = await _db.getCourses();
      final hasilTugas = await _db.getTasks();
      final sekarang = DateTime.now();

      int tugasAktif = 0;
      int deadline = 0;

      for (final item in hasilTugas) {
        final status = '${item['status'] ?? ''}';

        if (status == 'Selesai') continue;

        tugasAktif++;

        final tanggal = _parseDeadline(
          '${item['deadline'] ?? ''}',
          '${item['deadline_time'] ?? '23:59'}',
        );

        if (tanggal != null && !tanggal.isBefore(sekarang)) {
          deadline++;
        }
      }

      if (!mounted) return;

      setState(() {
        jumlahMataKuliah = hasilMataKuliah.length;
        jumlahTugasAktif = tugasAktif;
        jumlahDeadline = deadline;
        sedangMemuat = false;
      });
    } catch (e) {
      debugPrint('Gagal memuat ringkasan dashboard: $e');

      if (!mounted) return;

      setState(() {
        sedangMemuat = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal memuat ringkasan akademik.'),
        ),
      );
    }
  }

  DateTime? _parseDeadline(String tanggal, String waktu) {
    try {
      final bagian = tanggal.split(' ');
      if (bagian.length != 3) return null;

      final hari = int.parse(bagian[0]);
      final tahun = int.parse(bagian[2]);

      const bulanIndonesia = {
        'Januari': 1,
        'Februari': 2,
        'Maret': 3,
        'April': 4,
        'Mei': 5,
        'Juni': 6,
        'Juli': 7,
        'Agustus': 8,
        'September': 9,
        'Oktober': 10,
        'November': 11,
        'Desember': 12,
      };

      final bulan = bulanIndonesia[bagian[1]];
      if (bulan == null) return null;

      final bagianWaktu = waktu.split(':');
      if (bagianWaktu.length != 2) return null;

      final jam = int.parse(bagianWaktu[0]);
      final menit = int.parse(bagianWaktu[1]);

      if (jam < 0 || jam > 23 || menit < 0 || menit > 59) {
        return null;
      }

      final hasil = DateTime(tahun, bulan, hari, jam, menit);

      if (hasil.year != tahun ||
          hasil.month != bulan ||
          hasil.day != hari) {
        return null;
      }

      return hasil;
    } catch (_) {
      return null;
    }
  }

  Future<void> _bukaHalaman(Widget halaman) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => halaman),
    );

    if (!mounted) return;
    await _muatRingkasan();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: latar,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: biru,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.menu_book_rounded,
                      color: Colors.white,
                      size: 25,
                    ),
                  ),
                  const SizedBox(width: 11),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'StudyMate',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: teks,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Academic Management',
                          style: TextStyle(
                            fontSize: 11,
                            color: muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _iconButton(
                    icon: Icons.notifications_none_rounded,
                    onTap: () => _bukaHalaman(
                      const TugasScreen(),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // SAPAAN
              const Text(
                'Selamat Datang,',
                style: TextStyle(
                  fontSize: 14,
                  color: muted,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Tika Afrilia',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w600,
                  color: teks,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 7),
              const Text(
                'Kelola kegiatan akademikmu dengan lebih teratur.',
                style: TextStyle(
                  fontSize: 12,
                  color: muted,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 23),

              // BANNER BIRU SOLID
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(19),
                decoration: BoxDecoration(
                  color: biru,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Rencanakan harimu',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 7),
                          Text(
                            'Atur jadwal dan selesaikan tugas '
                            'sesuai prioritas.',
                            style: TextStyle(
                              fontSize: 12,
                              height: 1.5,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 55,
                      height: 55,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: const Icon(
                        Icons.calendar_month_rounded,
                        color: Colors.white,
                        size: 29,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // RINGKASAN AKADEMIK
              const Text(
                'Ringkasan Akademik',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: teks,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Informasi aktivitas perkuliahanmu.',
                style: TextStyle(
                  fontSize: 12,
                  color: muted,
                ),
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _summaryCard(
                      number: sedangMemuat
                          ? '...'
                          : '$jumlahMataKuliah',
                      title: 'Mata Kuliah',
                      icon: Icons.menu_book_outlined,
                      color: softBlue,
                      iconColor: biru,
                      onTap: () => _bukaHalaman(
                        const MataKuliahScreen(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _summaryCard(
                      number: sedangMemuat
                          ? '...'
                          : '$jumlahTugasAktif',
                      title: 'Tugas Aktif',
                      icon: Icons.assignment_outlined,
                      color: softPink,
                      iconColor: const Color(0xFFD7799E),
                      onTap: () => _bukaHalaman(
                        const TugasScreen(),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // DEADLINE
              Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  onTap: () => _bukaHalaman(
                    const TugasScreen(),
                  ),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: garis),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 43,
                          height: 43,
                          decoration: BoxDecoration(
                            color: softPeach,
                            borderRadius: BorderRadius.circular(11),
                          ),
                          child: const Icon(
                            Icons.event_note_outlined,
                            color: Color(0xFFC28B43),
                            size: 23,
                          ),
                        ),
                        const SizedBox(width: 13),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Deadline Terdekat',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: teks,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Tenggat tugas yang belum lewat',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          sedangMemuat ? '...' : '$jumlahDeadline',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFC28B43),
                          ),
                        ),
                        const SizedBox(width: 5),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: muted,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // MENU UTAMA
              const Text(
                'Menu Utama',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: teks,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Akses fitur utama StudyMate.',
                style: TextStyle(
                  fontSize: 12,
                  color: muted,
                ),
              ),

              const SizedBox(height: 15),

              Row(
                children: [
                  Expanded(
                    child: _menuTile(
                      icon: Icons.calendar_month_outlined,
                      title: 'Jadwal',
                      color: softBlue,
                      iconColor: biru,
                      onTap: () => _bukaHalaman(
                        const JadwalScreen(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: _menuTile(
                      icon: Icons.assignment_outlined,
                      title: 'Tugas',
                      color: softPink,
                      iconColor: const Color(0xFFD7799E),
                      onTap: () => _bukaHalaman(
                        const TugasScreen(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: _menuTile(
                      icon: Icons.menu_book_outlined,
                      title: 'Mata Kuliah',
                      color: softLavender,
                      iconColor: const Color(0xFF8174BC),
                      onTap: () => _bukaHalaman(
                        const MataKuliahScreen(),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // AKTIVITAS HARI INI
              const Text(
                'Aktivitas Hari Ini',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: teks,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Pintasan untuk kegiatan akademik.',
                style: TextStyle(
                  fontSize: 12,
                  color: muted,
                ),
              ),

              const SizedBox(height: 15),

              _activityCard(
                icon: Icons.school_outlined,
                title: 'Kegiatan Perkuliahan',
                subtitle: 'Periksa jadwal kuliah',
                color: softMint,
                iconColor: const Color(0xFF4D9875),
                onTap: () => _bukaHalaman(
                  const JadwalScreen(),
                ),
              ),

              const SizedBox(height: 10),

              _activityCard(
                icon: Icons.edit_note_rounded,
                title: 'Penyelesaian Tugas',
                subtitle: 'Periksa tugas yang masih aktif',
                color: softPink,
                iconColor: const Color(0xFFD7799E),
                onTap: () => _bukaHalaman(
                  const TugasScreen(),
                ),
              ),

              const SizedBox(height: 26),

              Center(
                child: Text(
                  'StudyMate  •  Academic Management',
                  style: TextStyle(
                    color: Colors.blueGrey.shade400,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // TOMBOL IKON HEADER
  static Widget _iconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: garis),
          ),
          child: Icon(
            icon,
            color: teks,
            size: 22,
          ),
        ),
      ),
    );
  }

  // KARTU RINGKASAN
  static Widget _summaryCard({
    required String number,
    required String title,
    required IconData icon,
    required Color color,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: garis),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 39,
                height: 39,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 22,
                ),
              ),
              const SizedBox(height: 15),
              Text(
                number,
                style: const TextStyle(
                  fontSize: 29,
                  height: 1,
                  fontWeight: FontWeight.w600,
                  color: teks,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: teks,
                ),
              ),
              const SizedBox(height: 9),
              Row(
                children: [
                  Text(
                    'Lihat detail',
                    style: TextStyle(
                      fontSize: 11,
                      color: iconColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 13,
                    color: iconColor,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // MENU UTAMA
  static Widget _menuTile({
    required IconData icon,
    required String title,
    required Color color,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 17,
            horizontal: 4,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: garis),
          ),
          child: Column(
            children: [
              Container(
                width: 43,
                height: 43,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 23,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: teks,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // KARTU AKTIVITAS
  static Widget _activityCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: garis),
          ),
          child: Row(
            children: [
              Container(
                width: 43,
                height: 43,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(11),
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
                        color: teks,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: muted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: muted,
                size: 21,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
