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
  // Palet warna soft blue dan soft pink
  static const Color biru = Color(0xFF8DBBFA);
  static const Color latar = Color(0xFFF4F8FF);
  static const Color teks = Color(0xFF40516F);
  static const Color softBlue = Color(0xFFEAF4FF);
  static const Color softPink = Color(0xFFFFEAF2);
  static const Color softBlueDark = Color(0xFF719FD9);
  static const Color softPinkDark = Color(0xFFE99BB9);
  static const Color softLavender = Color(0xFFE8E3FF);

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
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFB9DCFF),
                          Color(0xFF8DBBFA),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: softBlueDark.withValues(alpha: 0.18),
                          blurRadius: 12,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.menu_book_rounded,
                      color: Colors.white,
                      size: 27,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'StudyMate',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: teks,
                          ),
                        ),
                        Text(
                          'Teman belajar setiap hari',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF8796B0),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: biru.withValues(alpha: 0.12),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: () => _bukaHalaman(
                        const TugasScreen(),
                      ),
                      icon: const Icon(
                        Icons.notifications_none_rounded,
                        color: softBlueDark,
                      ),
                      tooltip: 'Lihat tugas dan deadline',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // SAPAAN
              const Text(
                'Halo, Tika Afrilia 👋',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                  color: teks,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 7),
              const Text(
                'Siap menjalani hari yang produktif?',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF8291AA),
                ),
              ),

              const SizedBox(height: 24),

              // BANNER MOTIVASI
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(21),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFAED4FF),
                      Color(0xFF9FC8FA),
                      Color(0xFFDCD6FF),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: softBlueDark.withValues(alpha: 0.20),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Langkah kecil,\nhasil luar biasa ✨',
                            style: TextStyle(
                              fontSize: 20,
                              height: 1.3,
                              fontWeight: FontWeight.w800,
                              color: teks,
                            ),
                          ),
                          SizedBox(height: 9),
                          Text(
                            'Atur waktumu dan raih targetmu.',
                            style: TextStyle(
                              fontSize: 12,
                              color: teks,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.40),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: const Icon(
                        Icons.auto_awesome_rounded,
                        color: Colors.white,
                        size: 38,
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
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: teks,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Pantau aktivitas kuliahmu di sini.',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF8796B0),
                ),
              ),
              const SizedBox(height: 17),

              Row(
                children: [
                  Expanded(
                    child: _summaryCard(
                      number: sedangMemuat
                          ? '…'
                          : '$jumlahMataKuliah',
                      title: 'Mata Kuliah',
                      icon: Icons.menu_book_rounded,
                      gradient: const [
                        Color(0xFFB9DCFF),
                        Color(0xFF8DBBFA),
                      ],
                      iconColor: softBlueDark,
                      onTap: () => _bukaHalaman(
                        const MataKuliahScreen(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _summaryCard(
                      number: sedangMemuat
                          ? '…'
                          : '$jumlahTugasAktif',
                      title: 'Tugas Aktif',
                      icon: Icons.assignment_rounded,
                      gradient: const [
                        Color(0xFFFFDCE9),
                        Color(0xFFF4B6CD),
                      ],
                      iconColor: softPinkDark,
                      onTap: () => _bukaHalaman(
                        const TugasScreen(),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 13),

              // KARTU DEADLINE
              InkWell(
                onTap: () => _bukaHalaman(
                  const TugasScreen(),
                ),
                borderRadius: BorderRadius.circular(22),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: softBlue,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: const Color(0xFFD5E7FF),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 49,
                        height: 49,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.notifications_active_rounded,
                          color: softBlueDark,
                          size: 27,
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Deadline Terdekat',
                              style: TextStyle(
                                color: teks,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Tugas yang tenggatnya belum lewat',
                              style: TextStyle(
                                color: Color(0xFF8291AA),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        sedangMemuat ? '…' : '$jumlahDeadline',
                        style: const TextStyle(
                          color: softBlueDark,
                          fontWeight: FontWeight.w800,
                          fontSize: 27,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 29),

              // MENU UTAMA
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Menu Utama',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        color: teks,
                      ),
                    ),
                  ),
                  Text(
                    'Pilih menu',
                    style: TextStyle(
                      fontSize: 12,
                      color: softBlueDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _menuTile(
                      icon: Icons.calendar_month_rounded,
                      title: 'Jadwal',
                      color: softBlue,
                      iconColor: softBlueDark,
                      onTap: () => _bukaHalaman(
                        const JadwalScreen(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: _menuTile(
                      icon: Icons.assignment_rounded,
                      title: 'Tugas',
                      color: softPink,
                      iconColor: softPinkDark,
                      onTap: () => _bukaHalaman(
                        const TugasScreen(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: _menuTile(
                      icon: Icons.menu_book_rounded,
                      title: 'Mata Kuliah',
                      color: softLavender,
                      iconColor: const Color(0xFF9388D6),
                      onTap: () => _bukaHalaman(
                        const MataKuliahScreen(),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 29),

              // AKTIVITAS HARI INI
              const Text(
                'Aktivitas Hari Ini',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: teks,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Tetap semangat menjalani kegiatanmu.',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF8796B0),
                ),
              ),
              const SizedBox(height: 16),

              _activityCard(
                icon: Icons.school_rounded,
                title: 'Kegiatan Perkuliahan',
                subtitle: 'Periksa jadwal kuliahmu',
                color: softBlue,
                iconColor: softBlueDark,
                onTap: () => _bukaHalaman(
                  const JadwalScreen(),
                ),
              ),
              const SizedBox(height: 12),
              _activityCard(
                icon: Icons.edit_note_rounded,
                title: 'Penyelesaian Tugas',
                subtitle: 'Periksa tugas yang masih aktif',
                color: softPink,
                iconColor: softPinkDark,
                onTap: () => _bukaHalaman(
                  const TugasScreen(),
                ),
              ),

              const SizedBox(height: 25),

              Center(
                child: Text(
                  'StudyMate • Teman belajar setiap hari 💙',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.blueGrey.shade300,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
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
    required List<Color> gradient,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: gradient.last.withValues(alpha: 0.25),
                blurRadius: 13,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 43,
                height: 43,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 25,
                ),
              ),
              const SizedBox(height: 17),
              Text(
                number,
                style: const TextStyle(
                  fontSize: 32,
                  height: 1,
                  color: teks,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 9),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  color: teks,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 7),
              Row(
                children: [
                  const Text(
                    'Lihat detail',
                    style: TextStyle(
                      color: teks,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 13,
                    color: teks.withValues(alpha: 0.8),
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
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 17,
            horizontal: 5,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFE5EDF8),
            ),
            boxShadow: [
              BoxShadow(
                color: softBlueDark.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 26,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: teks,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
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
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFE8EEF8),
            ),
            boxShadow: [
              BoxShadow(
                color: softBlueDark.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 25,
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
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFF8796B0),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF9AAAC0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}