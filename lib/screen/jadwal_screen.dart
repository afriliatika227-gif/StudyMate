
import 'package:flutter/material.dart';
import 'tambah_jadwal_screen.dart';

const Color _biru = Color(0xFF6EA8FE);
const Color _biruTua = Color(0xFF315780);
const Color _biruMuda = Color(0xFFEAF4FF);
const Color _latar = Color(0xFFF5F9FF);
const Color _abu = Color(0xFF7D91AA);

class JadwalScreen extends StatefulWidget {
  const JadwalScreen({super.key});

  @override
  State<JadwalScreen> createState() => _JadwalScreenState();
}

class _JadwalScreenState extends State<JadwalScreen> {
  final Color warnaUtama = _biru;

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

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Jadwal berhasil ditambahkan'),
      ),
    );
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
          top: Radius.circular(28),
        ),
      ),
      builder: (sheetContext) {
        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            24,
            12,
            24,
            24 + MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: _biruMuda,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.calendar_month_rounded,
                  color: _biru,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Detail Jadwal',
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                  color: _biruTua,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                jadwal['mataKuliah'] ?? '-',
                style: const TextStyle(
                  color: _abu,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              _barisDetail(
                Icons.calendar_today_rounded,
                'Hari',
                jadwal['hari'] ?? '-',
              ),
              _barisDetail(
                Icons.access_time_rounded,
                'Jam',
                jadwal['jam'] ?? '-',
              ),
              _barisDetail(
                Icons.location_on_outlined,
                'Ruang',
                jadwal['ruang'] ?? '-',
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    _editJadwal(index);
                  },
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Edit Jadwal'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _biru,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    _konfirmasiHapus(index);
                  },
                  icon: const Icon(Icons.delete_outline_rounded),
                  label: const Text('Hapus Jadwal'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Color(0xFFFFD6D6)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
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
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _latar,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(ikon, color: _biru, size: 23),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: _abu,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  nilai,
                  style: const TextStyle(
                    color: _biruTua,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
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

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Jadwal berhasil diperbarui'),
      ),
    );
  }

  Future<void> _konfirmasiHapus(int index) async {
    if (index < 0 || index >= daftarJadwal.length) return;

    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            'Hapus Jadwal?',
            style: TextStyle(
              color: _biruTua,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Jadwal ${daftarJadwal[index]['mataKuliah']} '
            'akan dihapus dari daftar.',
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, false),
              child: const Text(
                'Batal',
                style: TextStyle(color: _biruTua),
              ),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, true),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
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

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Jadwal berhasil dihapus'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _latar,
      appBar: AppBar(
        backgroundColor: _latar,
        foregroundColor: _biruTua,
        elevation: 0,
        title: const Text(
          'Jadwal Kuliah',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 21,
            color: _biruTua,
          ),
        ),
      ),
      body: daftarJadwal.isEmpty
          ? ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const SizedBox(height: 100),
                const Icon(
                  Icons.event_note_rounded,
                  size: 72,
                  color: _biru,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Belum ada jadwal kuliah',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _biruTua,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tambahkan jadwal agar aktivitas kuliahmu lebih teratur.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: _abu),
                ),
              ],
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
              children: [
                _header(),
                const SizedBox(height: 22),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Jadwal Mingguan',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _biruTua,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: _biruMuda,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${daftarJadwal.length} jadwal',
                        style: const TextStyle(
                          color: _biruTua,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
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
        backgroundColor: _biru,
        foregroundColor: Colors.white,
        elevation: 3,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Tambah Jadwal',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _header() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFDCEBFF),
            Color(0xFFF0F6FF),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFD8E8FF)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Atur waktumu ✨',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _biruTua,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Semua jadwal kuliahmu, lebih rapi dalam satu tempat.',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: _biruTua.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(19),
            ),
            child: const Icon(
              Icons.calendar_month_rounded,
              color: _biru,
              size: 34,
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
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE6EFFB)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7DA8D8).withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () => _detailJadwal(index),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              children: [
                Container(
                  width: 57,
                  height: 62,
                  decoration: BoxDecoration(
                    color: _biruMuda,
                    borderRadius: BorderRadius.circular(17),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.calendar_today_rounded,
                        color: _biru,
                        size: 21,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        (jadwal['hari'] ?? '-').length >= 3
                            ? jadwal['hari']!.substring(0, 3)
                            : jadwal['hari'] ?? '-',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: _biruTua,
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
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: _biruTua,
                        ),
                      ),
                      const SizedBox(height: 9),
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time_rounded,
                            color: _biru,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              jadwal['jam'] ?? '-',
                              style: const TextStyle(
                                fontSize: 12,
                                color: _abu,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            color: _biru,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              jadwal['ruang'] ?? '-',
                              style: const TextStyle(
                                fontSize: 12,
                                color: _abu,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: _biru,
                  size: 25,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
