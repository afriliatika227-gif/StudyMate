
import 'package:flutter/material.dart';
import 'tambah_jadwal_screen.dart';

const Color _blue = Color(0xFF3478C8);
const Color _darkBlue = Color(0xFF344054);
const Color _background = Color(0xFFF5F7FA);
const Color _line = Color(0xFFE4E8EF);
const Color _muted = Color(0xFF7C8798);
const Color _softBlue = Color(0xFFEAF2FC);
const Color _softPink = Color(0xFFFCECF2);
const Color _softPurple = Color(0xFFF0ECFA);
const Color _softMint = Color(0xFFE8F5EF);
const Color _pink = Color(0xFFD7799E);
const Color _purple = Color(0xFF8A78C5);
const Color _mint = Color(0xFF55A88A);

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
    _blue,
    _pink,
    _purple,
    _mint,
  ];

  final List<Color> _warnaLatar = [
    _softBlue,
    _softPink,
    _softPurple,
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
          top: Radius.circular(22),
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
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: latar,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  Icons.calendar_month_outlined,
                  color: warna,
                  size: 27,
                ),
              ),
              const SizedBox(height: 17),
              const Text(
                'Detail Jadwal',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: _darkBlue,
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
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    _editJadwal(index);
                  },
                  icon: const Icon(Icons.edit_outlined, size: 19),
                  label: const Text(
                    'Edit Jadwal',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _blue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 9),
              SizedBox(
                width: double.infinity,
                height: 46,
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
                      borderRadius: BorderRadius.circular(10),
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
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: _background,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: _line),
      ),
      child: Row(
        children: [
          Container(
            width: 37,
            height: 37,
            decoration: BoxDecoration(
              color: latar,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(ikon, color: warna, size: 19),
          ),
          const SizedBox(width: 12),
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
                    color: _darkBlue,
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
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Hapus Jadwal?',
            style: TextStyle(
              color: _darkBlue,
              fontSize: 18,
              fontWeight: FontWeight.w600,
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: _darkBlue,
        title: const Text(
          'Jadwal Kuliah',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w600,
            color: _darkBlue,
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
      body: daftarJadwal.isEmpty
          ? _emptyState()
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 100),
              children: [
                _header(),
                const SizedBox(height: 25),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Jadwal Mingguan',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: _darkBlue,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: _softBlue,
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Text(
                        '${daftarJadwal.length} Jadwal',
                        style: const TextStyle(
                          color: _blue,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 13),
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
        backgroundColor: _blue,
        foregroundColor: Colors.white,
        elevation: 2,
        icon: const Icon(Icons.add_rounded, size: 21),
        label: const Text(
          'Tambah Jadwal',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: _blue,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Atur Waktu Kuliahmu',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  'Lihat dan kelola seluruh jadwal perkuliahanmu di sini.',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.5,
                    color: Colors.white.withValues(alpha: 0.92),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(
              Icons.calendar_month_outlined,
              color: Colors.white,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  Widget _jadwalCard(
    int index,
    Map<String, String> jadwal,
  ) {
    final warna = _warnaAksen[index % _warnaAksen.length];
    final latar = _warnaLatar[index % _warnaLatar.length];
    final hari = jadwal['hari'] ?? '-';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: _line),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(13),
        child: InkWell(
          borderRadius: BorderRadius.circular(13),
          onTap: () => _detailJadwal(index),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 55,
                  height: 60,
                  decoration: BoxDecoration(
                    color: latar,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        color: warna,
                        size: 19,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        hari.length >= 3
                            ? hari.substring(0, 3)
                            : hari,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: warna,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        jadwal['mataKuliah'] ?? '-',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: _darkBlue,
                        ),
                      ),
                      const SizedBox(height: 9),
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
                                fontSize: 12,
                                color: _muted,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
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
                                fontSize: 12,
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

  Widget _emptyState() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 100),
        Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            color: _softBlue,
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Icon(
            Icons.event_note_outlined,
            size: 38,
            color: _blue,
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'Belum Ada Jadwal Kuliah',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _darkBlue,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Tambahkan jadwal agar aktivitas kuliahmu lebih teratur.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _muted,
            fontSize: 13,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
