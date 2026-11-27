
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
  static const Color plum = Color(0xFF7552A6);
  static const Color darkPlum = Color(0xFF35264F);
  static const Color lavender = Color(0xFFF0EAFE);
  static const Color pink = Color(0xFFFCEBF2);
  static const Color peach = Color(0xFFFFF1E2);
  static const Color background = Color(0xFFFCFAFF);
  static const Color muted = Color(0xFF898397);
  static const Color border = Color(0xFFEDE8F2);

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

  String _tanggalHariIni() {
    const hari = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];

    const bulan = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];

    final now = DateTime.now();

    return '${hari[now.weekday - 1]}, ${now.day} ${bulan[now.month - 1]} ${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: RefreshIndicator(
          color: plum,
          onRefresh: _muatRingkasan,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 35),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // HEADER
                Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: lavender,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Icon(
                        Icons.school_rounded,
                        color: plum,
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
                              fontSize: 21,
                              fontWeight: FontWeight.w800,
                              color: darkPlum,
                              letterSpacing: -0.6,
                            ),
                          ),
                          Text(
                            'Your Academic Companion',
                            style: TextStyle(
                              fontSize: 11,
                              color: muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _headerButton(
                      Icons.notifications_none_rounded,
                      () => _bukaHalaman(const TugasScreen()),
                    ),
                  ],
                ),

                const SizedBox(height: 27),

                // SAPAAN
                const Text(
                  'Halo, Tika Afrilia!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: darkPlum,
                    letterSpacing: -0.7,
                  ),
                ),
                const SizedBox(height: 7),
                const Text(
                  'Semangat terus untuk hari ini!',
                  style: TextStyle(
                    fontSize: 14,
                    color: muted,
                  ),
                ),

                const SizedBox(height: 20),

                // BANNER MOTIVASI DENGAN FOTO BUKU ASLI
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(19),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFE7DDFB),
                        Color(0xFFF6EAF5),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Belajar hari ini,',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: darkPlum,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'untuk masa depan yang lebih baik.',
                              style: TextStyle(
                                fontSize: 12,
                                color: darkPlum,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: SizedBox(
                          width: 105,
                          height: 105,
                          child: Image.network(
                            'https://images.unsplash.com/photo-1497633762265-9d179a990aa6?w=600',
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;

                              return Container(
                                color: Colors.white.withValues(alpha: 0.65),
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    color: plum,
                                    strokeWidth: 2,
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.white.withValues(alpha: 0.65),
                                child: const Icon(
                                  Icons.menu_book_rounded,
                                  color: plum,
                                  size: 35,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 27),

                // RINGKASAN
                _sectionTitle('Ringkasan Akademik'),
                const SizedBox(height: 5),
                const Text(
                  'Pantau aktivitas perkuliahanmu.',
                  style: TextStyle(
                    fontSize: 12,
                    color: muted,
                  ),
                ),

                const SizedBox(height: 15),

                Row(
                  children: [
                    Expanded(
                      child: _summaryCard(
                        number: sedangMemuat
                            ? '...'
                            : '$jumlahMataKuliah',
                        title: 'Mata Kuliah',
                        icon: Icons.menu_book_rounded,
                        color: lavender,
                        iconColor: plum,
                        onTap: () => _bukaHalaman(
                          const MataKuliahScreen(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _summaryCard(
                        number: sedangMemuat
                            ? '...'
                            : '$jumlahTugasAktif',
                        title: 'Tugas Aktif',
                        icon: Icons.assignment_rounded,
                        color: pink,
                        iconColor: const Color(0xFFC65D8A),
                        onTap: () => _bukaHalaman(
                          const TugasScreen(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _summaryCard(
                        number: sedangMemuat
                            ? '...'
                            : '$jumlahDeadline',
                        title: 'Deadline',
                        icon: Icons.calendar_month_rounded,
                        color: peach,
                        iconColor: const Color(0xFFD18A37),
                        onTap: () => _bukaHalaman(
                          const TugasScreen(),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // AKSES CEPAT
                Row(
                  children: [
                    Expanded(child: _sectionTitle('Akses Cepat')),
                    TextButton(
                      onPressed: () => _bukaHalaman(
                        const JadwalScreen(),
                      ),
                      child: const Text(
                        'Lihat Jadwal',
                        style: TextStyle(
                          color: plum,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // FOTO MATA KULIAH
                _photoCard(
                  imageUrl:
                      'https://images.unsplash.com/photo-1497633762265-9d179a990aa6?w=1000',
                  title: 'Mata Kuliah',
                  subtitle: 'Kelola daftar perkuliahanmu',
                  label: 'AKADEMIK',
                  onTap: () => _bukaHalaman(
                    const MataKuliahScreen(),
                  ),
                ),

                const SizedBox(height: 15),

                // FOTO TUGAS
                _photoCard(
                  imageUrl:
                      'https://images.unsplash.com/photo-1455390582262-044cdead277a?w=1000',
                  title: 'Tugas Kuliah',
                  subtitle: 'Pantau tugas dan tenggat waktumu',
                  label: 'PRODUKTIVITAS',
                  onTap: () => _bukaHalaman(
                    const TugasScreen(),
                  ),
                ),

                const SizedBox(height: 27),

                // AGENDA
                _sectionTitle('Agenda Akademik'),
                const SizedBox(height: 6),
                Text(
                  _tanggalHariIni(),
                  style: const TextStyle(
                    fontSize: 12,
                    color: muted,
                  ),
                ),

                const SizedBox(height: 13),

                Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(17),
                  child: InkWell(
                    onTap: () => _bukaHalaman(
                      const JadwalScreen(),
                    ),
                    borderRadius: BorderRadius.circular(17),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(17),
                        border: Border.all(color: border),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 43,
                            height: 43,
                            decoration: BoxDecoration(
                              color: lavender,
                              borderRadius: BorderRadius.circular(13),
                            ),
                            child: const Icon(
                              Icons.calendar_today_rounded,
                              color: plum,
                              size: 21,
                            ),
                          ),
                          const SizedBox(width: 13),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Periksa jadwal kuliah',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: darkPlum,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  'Pastikan agenda akademikmu tetap teratur.',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: muted,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: muted,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                Center(
                  child: Text(
                    'StudyMate  •  Kelola aktivitas akademikmu',
                    style: TextStyle(
                      color: Colors.blueGrey.shade300,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // JUDUL BAGIAN
  static Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: darkPlum,
        letterSpacing: -0.4,
      ),
    );
  }

  // TOMBOL HEADER
  Widget _headerButton(IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: border),
          ),
          child: Icon(
            icon,
            color: darkPlum,
            size: 23,
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
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(17),
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 9,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(17),
            border: Border.all(color: border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 37,
                height: 37,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 21,
                ),
              ),
              const SizedBox(height: 13),
              Text(
                number,
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                  color: darkPlum,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: muted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // KARTU FOTO
  Widget _photoCard({
    required String imageUrl,
    required String title,
    required String subtitle,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 165,
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;

                        return Container(
                          color: lavender,
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: plum,
                              strokeWidth: 2,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: lavender,
                          child: const Center(
                            child: Icon(
                              Icons.image_not_supported_outlined,
                              color: plum,
                              size: 35,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Positioned(
                    top: 13,
                    left: 13,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.93),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        label,
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: plum,
                          letterSpacing: 0.7,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 15,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: darkPlum,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            subtitle,
                            style: const TextStyle(
                              fontSize: 11,
                              color: muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 37,
                      height: 37,
                      decoration: BoxDecoration(
                        color: lavender,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.arrow_forward_rounded,
                        color: plum,
                        size: 19,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
