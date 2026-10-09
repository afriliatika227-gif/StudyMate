import 'package:flutter/material.dart';

class DeadlineScreen extends StatefulWidget {
  const DeadlineScreen({super.key});

  @override
  State<DeadlineScreen> createState() => _DeadlineScreenState();
}

class _DeadlineScreenState extends State<DeadlineScreen> {
  final List<Map<String, String>> deadlines = [
    {
      'judul': 'Membuat Aplikasi Flutter',
      'mataKuliah': 'Pemrograman Mobile',
      'tanggal': '10 Oktober 2026',
      'waktu': '23:59',
    },
    {
      'judul': 'Laporan Praktikum IoT',
      'mataKuliah': 'Internet of Things',
      'tanggal': '12 Oktober 2026',
      'waktu': '23:59',
    },
    {
      'judul': 'Proposal Penelitian',
      'mataKuliah': 'Metodologi Penelitian',
      'tanggal': '15 Oktober 2026',
      'waktu': '23:59',
    },
  ];

  void _tambahDeadline() async {
    final hasil = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TambahDeadlineScreen(),
      ),
    );

    if (hasil != null) {
      setState(() {
        deadlines.add({
          'judul': hasil['judul'] ?? '',
          'mataKuliah': hasil['mataKuliah'] ?? '',
          'tanggal': hasil['tanggal'] ?? '',
          'waktu': hasil['waktu'] ?? '',
        });
      });
    }
  }

  void _lihatDetail(int index) {
    final deadline = deadlines[index];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Detail Deadline',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Judul Tugas',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  deadline['judul']!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 16),

                const Text(
                  'Mata Kuliah',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  deadline['mataKuliah']!,
                  style: const TextStyle(
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 16),

                const Text(
                  'Tanggal',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  deadline['tanggal']!,
                  style: const TextStyle(
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 16),

                const Text(
                  'Waktu',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  deadline['waktu']!,
                  style: const TextStyle(
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Tutup'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _konfirmasiHapus(index);
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  void _konfirmasiHapus(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Hapus Deadline?',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'Deadline yang dihapus tidak dapat ditampilkan kembali.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  deadlines.removeAt(index);
                });

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Deadline berhasil dihapus.'),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  Widget _deadlineCard(
    BuildContext context,
    Map<String, String> deadline,
    int index,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          _lihatDetail(index);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF1F1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.alarm_rounded,
                      color: Colors.redAccent,
                    ),
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          deadline['judul']!,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          deadline['mataKuliah']!,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
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

              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 18,
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        deadline['tanggal']!,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.access_time_outlined,
                      size: 18,
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      deadline['waktu']!,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),

      appBar: AppBar(
        title: const Text(
          'Deadline Terdekat',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),

      body: deadlines.isEmpty
          ? const Center(
              child: Text(
                'Belum ada deadline.',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 15,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: deadlines.length,
              itemBuilder: (context, index) {
                return _deadlineCard(
                  context,
                  deadlines[index],
                  index,
                );
              },
            ),

      floatingActionButton: FloatingActionButton(
        onPressed: _tambahDeadline,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class TambahDeadlineScreen extends StatefulWidget {
  const TambahDeadlineScreen({super.key});

  @override
  State<TambahDeadlineScreen> createState() =>
      _TambahDeadlineScreenState();
}

class _TambahDeadlineScreenState
    extends State<TambahDeadlineScreen> {
  final judulController = TextEditingController();
  final mataKuliahController = TextEditingController();

  DateTime? tanggal;
  TimeOfDay? waktu;

  String _formatTanggal(DateTime date) {
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

    return '${date.day} ${bulan[date.month - 1]} ${date.year}';
  }

  Future<void> _pilihTanggal() async {
    final hasil = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2035),
    );

    if (hasil != null) {
      setState(() {
        tanggal = hasil;
      });
    }
  }

  Future<void> _pilihWaktu() async {
    final hasil = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (hasil != null) {
      setState(() {
        waktu = hasil;
      });
    }
  }

  void _simpan() {
    if (judulController.text.trim().isEmpty ||
        mataKuliahController.text.trim().isEmpty ||
        tanggal == null ||
        waktu == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Mohon lengkapi semua data deadline.',
          ),
        ),
      );
      return;
    }

    Navigator.pop(
      context,
      {
        'judul': judulController.text.trim(),
        'mataKuliah': mataKuliahController.text.trim(),
        'tanggal': _formatTanggal(tanggal!),
        'waktu': waktu!.format(context),
      },
    );
  }

  @override
  void dispose() {
    judulController.dispose();
    mataKuliahController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tambah Deadline',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: judulController,
              decoration: InputDecoration(
                labelText: 'Judul Tugas',
                hintText: 'Contoh: Membuat laporan',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: mataKuliahController,
              decoration: InputDecoration(
                labelText: 'Mata Kuliah',
                hintText: 'Contoh: Pemrograman Mobile',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Tanggal Deadline',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _pilihTanggal,
                icon: const Icon(
                  Icons.calendar_today_outlined,
                ),
                label: Text(
                  tanggal == null
                      ? 'Pilih Tanggal'
                      : _formatTanggal(tanggal!),
                ),
              ),
            ),

            const SizedBox(height: 16),

            const Text(
              'Waktu Deadline',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _pilihWaktu,
                icon: const Icon(
                  Icons.access_time_outlined,
                ),
                label: Text(
                  waktu == null
                      ? 'Pilih Waktu'
                      : waktu!.format(context),
                ),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _simpan,
                child: const Text(
                  'Simpan Deadline',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}