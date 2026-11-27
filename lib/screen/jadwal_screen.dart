
import 'package:flutter/material.dart';
import 'tambah_jadwal_screen.dart';

const Color _plum = Color(0xFF66527F);
const Color _darkPlum = Color(0xFF423650);
const Color _lavender = Color(0xFFEDE6F6);
const Color _softLavender = Color(0xFFF6F2FA);
const Color _pink = Color(0xFFD98EAD);
const Color _softPink = Color(0xFFFAEDF2);
const Color _softMint = Color(0xFFE8F5EF);
const Color _mint = Color(0xFF55A88A);
const Color _background = Color(0xFFFAF8FC);
const Color _line = Color(0xFFECE6F0);
const Color _muted = Color(0xFF92899B);

class JadwalScreen extends StatefulWidget {
  const JadwalScreen({super.key});

  @override
  State<JadwalScreen> createState() => _JadwalScreenState();
}

class _JadwalScreenState extends State<JadwalScreen> {
  final List<Map<String, String>> daftarJadwal = [
    {
      'hari': 'Senin',
      'mataKuliah': 'Pemrograman Mobile',
      'jam': '08.00 - 10.30',
      'ruang': 'Lab Komputer 1',
    },
    {
      'hari': 'Selasa',
      'mataKuliah': 'Statistika Pendidikan',
      'jam': '10.00 - 12.00',
      'ruang': 'Ruang 204',
    },
    {
      'hari': 'Rabu',
      'mataKuliah': 'Internet of Things',
      'jam': '13.00 - 15.00',
      'ruang': 'Lab IoT',
    },
    {
      'hari': 'Kamis',
      'mataKuliah': 'Metodologi Penelitian',
      'jam': '08.00 - 10.00',
      'ruang': 'Ruang 202',
    },
    {
      'hari': 'Jumat',
      'mataKuliah': 'Perencanaan Pembelajaran',
      'jam': '09.00 - 11.00',
      'ruang': 'Ruang 105',
    },
  ];

  final List<Color> _warnaAksen = [
    _plum,
    _pink,
    const Color(0xFF8A78C5),
    _mint,
  ];

  final List<Color> _warnaLatar = [
    _softLavender,
    _softPink,
    const Color(0xFFF0ECFA),
    _softMint,
  ];

  Future<void> _tambahJadwal() async {
    final hasil = await Navigator.push<Map<String, String>>(
      context,
      MaterialPageRoute(
        builder: (_) => const TambahJadwalScreen(),
      ),
    );

    if (!mounted || hasil == null) return;

    setState(() {
      daftarJadwal.add(hasil);
    });

    _tampilkanPesan('Jadwal berhasil ditambahkan');
  }

  Future<void> _detailJadwal(int index) async {
    if (index < 0 || index >= daftarJadwal.length) return;

    final jadwal = Map<String, String>.from(daftarJadwal[index]);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      builder: (sheetContext) {
        final warna = _warnaAksen[index % _warnaAksen.length];
        final latar = _warnaLatar[index % _warnaLatar.length];

        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            22,
            12,
            22,
            24 + MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: latar,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.event_note_rounded,
                  color: warna,
                  size: 28,
                ),
              ),
              const SizedBox(height: 17),
              const Text(
                'Detail Jadwal',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: _darkPlum,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                jadwal['mataKuliah'] ?? '-',
                style: const TextStyle(
                  color: _muted,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 22),
              _barisDetail(
                Icons.calendar_today_outlined,
                'Hari',
                jadwal['hari'] ?? '-',
                warna,
                latar,
              ),
              _barisDetail(
                Icons.access_time_rounded,
                'Waktu',
                jadwal['jam'] ?? '-',
                warna,
                latar,
              ),
              _barisDetail(
                Icons.location_on_outlined,
                'Ruangan',
                jadwal['ruang'] ?? '-',
                warna,
                latar,
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 51,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    _editJadwal(index);
                  },
                  icon: const Icon(
                    Icons.edit_outlined,
                    size: 19,
                  ),
                  label: const Text(
                    'Edit Jadwal',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _plum,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    _konfirmasiHapus(index);
                  },
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    size: 19,
                  ),
                  label: const Text('Hapus Jadwal'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFD65353),
                    side: const BorderSide(
                      color: Color(0xFFF0CCCC),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _barisDetail(
    IconData ikon,
    String label,
    String nilai,
    Color warna,
    Color latar,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _line),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: latar,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              ikon,
              color: warna,
              size: 19,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  nilai,
                  style: const TextStyle(
                    color: _darkPlum,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _editJadwal(int index) async {
    if (index < 0 || index >= daftarJadwal.length) return;

    final jadwalLama =
        Map<String, String>.from(daftarJadwal[index]);

    final hasil = await Navigator.push<Map<String, String>>(
      context,
      MaterialPageRoute(
        builder: (_) => TambahJadwalScreen(
          jadwalAwal: jadwalLama,
        ),
      ),
    );

    if (!mounted || hasil == null) return;
    if (index >= daftarJadwal.length) return;

    setState(() {
      daftarJadwal[index] = hasil;
    });

    _tampilkanPesan('Jadwal berhasil diperbarui');
  }

  Future<void> _konfirmasiHapus(int index) async {
    if (index < 0 || index >= daftarJadwal.length) return;

    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Hapus Jadwal?',
            style: TextStyle(
              color: _darkPlum,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            'Jadwal ${daftarJadwal[index]['mataKuliah']} '
            'akan dihapus dari daftar.',
            style: const TextStyle(
              color: _muted,
              fontSize: 13,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, false),
              child: const Text(
                'Batal',
                style: TextStyle(color: _muted),
              ),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, true),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFD65353),
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (!mounted || konfirmasi != true) return;
    if (index >= daftarJadwal.length) return;

    setState(() {
      daftarJadwal.removeAt(index);
    });

    _tampilkanPesan('Jadwal berhasil dihapus');
  }

  void _tampilkanPesan(String pesan) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(pesan),
        behavior: SnackBarBehavior.floating,
        backgroundColor: _darkPlum,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: _darkPlum,
        title: const Text(
          'Jadwal Kuliah',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w700,
            color: _darkPlum,
          ),
        ),
      ),
      body: daftarJadwal.isEmpty
          ? _emptyState()
          : ListView(
              padding: const EdgeInsets.fromLTRB(
                20,
                10,
                20,
                110,
              ),
              children: [
                _header(),
                const SizedBox(height: 27),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Jadwal Mingguan',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: _darkPlum,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: _lavender,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${daftarJadwal.length} Jadwal',
                        style: const TextStyle(
                          color: _plum,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                const Text(
                  'Agenda perkuliahan yang perlu kamu perhatikan.',
                  style: TextStyle(
                    color: _muted,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 17),
                ...List.generate(
                  daftarJadwal.length,
                  (index) => _jadwalCard(
                    index,
                    daftarJadwal[index],
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab-jadwal',
        onPressed: _tambahJadwal,
        backgroundColor: _plum,
        foregroundColor: Colors.white,
        elevation: 3,
        icon: const Icon(Icons.add_rounded, size: 21),
        label: const Text(
          'Tambah Jadwal',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  // HEADER FOTO KALENDER FULL BACKGROUND
  Widget _header() {
    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(23),
        boxShadow: [
          BoxShadow(
            color: _plum.withValues(alpha: 0.17),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(23),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // FOTO KALENDER MEMENUHI SELURUH BANNER
            Image.network(
              'https://images.unsplash.com/photo-1506784983877-45594efa4cbe?w=1000',
              fit: BoxFit.cover,
              alignment: Alignment.center,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;

                return Container(
                  color: _softLavender,
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: _plum,
                      strokeWidth: 2,
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: _lavender,
                  child: const Center(
                    child: Icon(
                      Icons.calendar_month_rounded,
                      color: _plum,
                      size: 45,
                    ),
                  ),
                );
              },
            ),

            // LAPISAN GRADASI TRANSPARAN
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x12000000),
                    Color(0x35000000),
                    Color(0xCC241B30),
                  ],
                  stops: [0.0, 0.38, 1.0],
                ),
              ),
            ),

            // TULISAN DI ATAS FOTO
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Atur Waktu Kuliahmu',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      shadows: [
                        Shadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 9),
                  const Text(
                    'Rencanakan kegiatan akademikmu '
                    'dan pastikan tidak ada jadwal yang terlewat.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      height: 1.6,
                      shadows: [
                        Shadow(
                          color: Colors.black38,
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 13),
                  Row(
                    children: [
                      const Icon(
                        Icons.auto_awesome_rounded,
                        color: Color(0xFFFFD9E8),
                        size: 15,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${daftarJadwal.length} agenda perkuliahan',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // KARTU JADWAL
  Widget _jadwalCard(
    int index,
    Map<String, String> jadwal,
  ) {
    final warna = _warnaAksen[index % _warnaAksen.length];
    final latar = _warnaLatar[index % _warnaLatar.length];
    final hari = jadwal['hari'] ?? '-';

    return Container(
      margin: const EdgeInsets.only(bottom: 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _line),
        boxShadow: [
          BoxShadow(
            color: _darkPlum.withValues(alpha: 0.025),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => _detailJadwal(index),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              children: [
                Container(
                  width: 57,
                  height: 66,
                  decoration: BoxDecoration(
                    color: latar,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        color: warna,
                        size: 19,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        hari.length >= 3
                            ? hari.substring(0, 3)
                            : hari,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: warna,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        jadwal['mataKuliah'] ?? '-',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: _darkPlum,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            color: warna,
                            size: 15,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              jadwal['jam'] ?? '-',
                              style: const TextStyle(
                                fontSize: 11,
                                color: _muted,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 7),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            color: warna,
                            size: 15,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              jadwal['ruang'] ?? '-',
                              style: const TextStyle(
                                fontSize: 11,
                                color: _muted,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 5),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: _muted,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // TAMPILAN KOSONG
  Widget _emptyState() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 80),
        Center(
          child: Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: _lavender,
              borderRadius: BorderRadius.circular(25),
            ),
            child: const Icon(
              Icons.event_note_rounded,
              size: 42,
              color: _plum,
            ),
          ),
        ),
        const SizedBox(height: 22),
        const Text(
          'Belum Ada Jadwal Kuliah',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _darkPlum,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 9),
        const Text(
          'Tambahkan jadwal perkuliahanmu agar '
          'semua aktivitas akademik lebih teratur.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _muted,
            fontSize: 12,
            height: 1.6,
          ),
        ),
      ],
    );
  }
}
