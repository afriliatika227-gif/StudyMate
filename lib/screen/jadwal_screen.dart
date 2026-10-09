
import 'package:flutter/material.dart';
import 'tambah_jadwal_screen.dart';

class JadwalScreen extends StatefulWidget {
  const JadwalScreen({super.key});

  @override
  State<JadwalScreen> createState() => _JadwalScreenState();
}

class _JadwalScreenState extends State<JadwalScreen> {
  final Color warnaUtama = const Color(0xFF6EA8FE);

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
      const SnackBar(content: Text('Jadwal berhasil ditambahkan')),
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
              const Text(
                'Detail Jadwal',
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 22),
              _barisDetail(
                Icons.calendar_today_outlined,
                'Hari',
                jadwal['hari'] ?? '-',
              ),
              _barisDetail(
                Icons.menu_book_outlined,
                'Mata Kuliah',
                jadwal['mataKuliah'] ?? '-',
              ),
              _barisDetail(
                Icons.access_time,
                'Jam',
                jadwal['jam'] ?? '-',
              ),
              _barisDetail(
                Icons.location_on_outlined,
                'Ruang',
                jadwal['ruang'] ?? '-',
              ),
              const SizedBox(height: 20),
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
                    backgroundColor: warnaUtama,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
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
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Hapus Jadwal'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(ikon, color: warnaUtama, size: 24),
          const SizedBox(width: 14),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                ),
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(text: nilai),
                ],
              ),
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
      const SnackBar(content: Text('Jadwal berhasil diperbarui')),
    );
  }

  Future<void> _konfirmasiHapus(int index) async {
    if (index < 0 || index >= daftarJadwal.length) return;

    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Hapus Jadwal?'),
          content: Text(
            'Jadwal ${daftarJadwal[index]['mataKuliah']} '
            'akan dihapus dari daftar.',
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, false),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, true),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
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
      const SnackBar(content: Text('Jadwal berhasil dihapus')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      appBar: AppBar(
        title: const Text(
          'Jadwal Kuliah',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: daftarJadwal.isEmpty
          ? const Center(
              child: Text('Belum ada jadwal kuliah.'),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: daftarJadwal.length,
              itemBuilder: (context, index) {
                final jadwal = daftarJadwal[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 14),
                  color: Colors.white,
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => _detailJadwal(index),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: warnaUtama.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              Icons.calendar_month_outlined,
                              color: warnaUtama,
                              size: 28,
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
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 7),
                                Text(
                                  '${jadwal['hari']} • ${jadwal['jam']}',
                                  style: const TextStyle(
                                    color: Colors.black54,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  jadwal['ruang'] ?? '-',
                                  style: const TextStyle(
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _tambahJadwal,
        backgroundColor: warnaUtama,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Jadwal'),
      ),
    );
  }
}