import 'package:flutter/material.dart';

import 'tambah_jadwal_screen.dart';

class JadwalScreen extends StatefulWidget {
  const JadwalScreen({super.key});

  @override
  State<JadwalScreen> createState() => _JadwalScreenState();
}

class _JadwalScreenState extends State<JadwalScreen> {
  final List<Map<String, String>> jadwal = [
    {
      'hari': 'Senin',
      'mataKuliah': 'Pemrograman Mobile',
      'jam': '08.00 - 10.30',
      'ruang': 'Lab Komputer 1',
    },
    {
      'hari': 'Selasa',
      'mataKuliah': 'Statistika',
      'jam': '10.00 - 12.00',
      'ruang': 'Ruang 204',
    },
    {
      'hari': 'Rabu',
      'mataKuliah': 'Metodologi Penelitian',
      'jam': '08.00 - 10.30',
      'ruang': 'Ruang 301',
    },
    {
      'hari': 'Kamis',
      'mataKuliah': 'Internet of Things',
      'jam': '13.00 - 15.30',
      'ruang': 'Lab IoT',
    },
    {
      'hari': 'Jumat',
      'mataKuliah': 'Perencanaan Pembelajaran',
      'jam': '08.00 - 10.00',
      'ruang': 'Ruang 105',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Jadwal Kuliah',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: jadwal.length,
        itemBuilder: (context, index) {
          final item = jadwal[index];

          return _jadwalCard(
            context,
            index: index,
            hari: item['hari']!,
            mataKuliah: item['mataKuliah']!,
            jam: item['jam']!,
            ruang: item['ruang']!,
          );
        },
      ),

      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab-jadwal',
        onPressed: () async {
          final hasil = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TambahJadwalScreen(),
            ),
          );

          if (hasil != null) {
            setState(() {
              jadwal.add({
                'hari': hasil['hari'] ?? '',
                'mataKuliah': hasil['mataKuliah'] ?? '',
                'jam': hasil['jam'] ?? '',
                'ruang': hasil['ruang'] ?? '',
              });
            });
          }
        },
        backgroundColor: const Color(0xFF6EA8FE),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Jadwal'),
      ),
    );
  }

  Widget _jadwalCard(
    BuildContext context, {
    required int index,
    required String hari,
    required String mataKuliah,
    required String jam,
    required String ruang,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
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
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          _detailJadwal(
            context,
            index,
            hari,
            mataKuliah,
            jam,
            ruang,
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF4FF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.calendar_month_rounded,
                  color: Color(0xFF6EA8FE),
                  size: 30,
                ),
              ),

              const SizedBox(width: 15),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hari,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6EA8FE),
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      mataKuliah,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 7),

                    Row(
                      children: [
                        const Icon(
                          Icons.access_time_rounded,
                          size: 15,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          jam,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 15,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            ruang,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
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
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _detailJadwal(
    BuildContext context,
    int index,
    String hari,
    String mataKuliah,
    String jam,
    String ruang,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Detail Jadwal',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              _detailRow(
                Icons.calendar_today_rounded,
                'Hari',
                hari,
              ),

              _detailRow(
                Icons.menu_book_rounded,
                'Mata Kuliah',
                mataKuliah,
              ),

              _detailRow(
                Icons.access_time_rounded,
                'Jam',
                jam,
              ),

              _detailRow(
                Icons.location_on_outlined,
                'Ruang',
                ruang,
              ),

              const SizedBox(height: 15),

              // TOMBOL HAPUS
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _konfirmasiHapus(index);
                  },
                  icon: const Icon(
                    Icons.delete_outline,
                  ),
                  label: const Text(
                    'Hapus Jadwal',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // TOMBOL TUTUP
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF6EA8FE),
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Tutup',
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _konfirmasiHapus(int index) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Hapus Jadwal?',
          ),
          content: const Text(
            'Apakah kamu yakin ingin menghapus jadwal ini?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text(
                'Batal',
              ),
            ),

            ElevatedButton(
              onPressed: () {
                setState(() {
                  jadwal.removeAt(index);
                });

                Navigator.pop(dialogContext);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Jadwal berhasil dihapus.',
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'Hapus',
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _detailRow(
    IconData icon,
    String title,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFF6EA8FE),
            size: 22,
          ),

          const SizedBox(width: 12),

          Text(
            '$title: ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),

          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }
}