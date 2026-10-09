import 'package:flutter/material.dart';

import 'tambah_tugas_screen.dart';

class TugasScreen extends StatefulWidget {
  const TugasScreen({super.key});

  @override
  State<TugasScreen> createState() => _TugasScreenState();
}

class _TugasScreenState extends State<TugasScreen> {
  final List<Map<String, String>> tugas = [
    {
      'judul': 'Membuat Aplikasi Flutter',
      'mataKuliah': 'Pemrograman Mobile',
      'deadline': '10 Oktober 2026',
      'status': 'Sedang Dikerjakan',
    },
    {
      'judul': 'Laporan Praktikum IoT',
      'mataKuliah': 'Internet of Things',
      'deadline': '12 Oktober 2026',
      'status': 'Belum Dikerjakan',
    },
    {
      'judul': 'Proposal Penelitian',
      'mataKuliah': 'Metodologi Penelitian',
      'deadline': '15 Oktober 2026',
      'status': 'Selesai',
    },
    {
      'judul': 'Tugas Statistika',
      'mataKuliah': 'Statistika',
      'deadline': '18 Oktober 2026',
      'status': 'Belum Dikerjakan',
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
          'Tugas',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: tugas.isEmpty
          ? const Center(
              child: Text(
                'Belum ada tugas.',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 15,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: tugas.length,
              itemBuilder: (context, index) {
                final item = tugas[index];

                return _tugasCard(
                  context,
                  index: index,
                  judul: item['judul']!,
                  mataKuliah: item['mataKuliah']!,
                  deadline: item['deadline']!,
                  status: item['status']!,
                );
              },
            ),

      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab-tugas',
        onPressed: _tambahTugas,
        backgroundColor: const Color(0xFF6EA8FE),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Tugas'),
      ),
    );
  }

  Future<void> _tambahTugas() async {
    final hasil = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TambahTugasScreen(),
      ),
    );

    if (hasil != null) {
      setState(() {
        tugas.add({
          'judul': hasil['judul'] ?? '',
          'mataKuliah': hasil['mataKuliah'] ?? '',
          'deadline': hasil['deadline'] ?? '',
          'status': hasil['status'] ?? 'Belum Dikerjakan',
        });
      });
    }
  }

  Future<void> _editTugas(int index) async {
    final hasil = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TambahTugasScreen(
          dataEdit: tugas[index],
        ),
      ),
    );

    if (hasil != null) {
      setState(() {
        tugas[index] = {
          'judul': hasil['judul'] ?? '',
          'mataKuliah': hasil['mataKuliah'] ?? '',
          'deadline': hasil['deadline'] ?? '',
          'status': hasil['status'] ?? 'Belum Dikerjakan',
        };
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Tugas berhasil diperbarui.',
          ),
        ),
      );
    }
  }

  Widget _tugasCard(
    BuildContext context, {
    required int index,
    required String judul,
    required String mataKuliah,
    required String deadline,
    required String status,
  }) {
    Color statusColor;

    if (status == 'Selesai') {
      statusColor = Colors.green;
    } else if (status == 'Sedang Dikerjakan') {
      statusColor = Colors.orange;
    } else {
      statusColor = Colors.redAccent;
    }

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
          _detailTugas(index);
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
                      color: const Color(0xFFFFF0F5),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.assignment_rounded,
                      color: Color(0xFFE88DA8),
                    ),
                  ),

                  const SizedBox(width: 13),

                  Expanded(
                    child: Text(
                      judul,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.grey,
                  ),
                ],
              ),

              const SizedBox(height: 13),

              Text(
                mataKuliah,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 10),

              Container(
                width: double.infinity,
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
                      Icons.calendar_today_rounded,
                      size: 16,
                      color: Colors.orange,
                    ),

                    const SizedBox(width: 7),

                    const Text(
                      'Deadline:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(width: 5),

                    Expanded(
                      child: Text(
                        deadline,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _detailTugas(int index) {
    final item = tugas[index];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Detail Tugas',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),

          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item['judul']!,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 18),

                _infoRow(
                  Icons.menu_book_rounded,
                  'Mata Kuliah',
                  item['mataKuliah']!,
                ),

                _infoRow(
                  Icons.calendar_today_rounded,
                  'Deadline',
                  item['deadline']!,
                ),

                _infoRow(
                  Icons.flag_rounded,
                  'Status',
                  item['status']!,
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
                _editTugas(index);
              },
              child: const Text('Edit'),
            ),

            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _ubahStatus(index);
              },
              child: const Text('Ubah Status'),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _hapusTugas(index);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  Widget _infoRow(
    IconData icon,
    String title,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 21,
            color: const Color(0xFF6EA8FE),
          ),

          const SizedBox(width: 10),

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

  void _ubahStatus(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Ubah Status',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),

          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _statusOption(
                index,
                'Belum Dikerjakan',
              ),
              _statusOption(
                index,
                'Sedang Dikerjakan',
              ),
              _statusOption(
                index,
                'Selesai',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _statusOption(
    int index,
    String status,
  ) {
    return ListTile(
      leading: Icon(
        status == 'Selesai'
            ? Icons.check_circle_outline
            : status == 'Sedang Dikerjakan'
                ? Icons.pending_actions
                : Icons.radio_button_unchecked,
      ),
      title: Text(status),
      onTap: () {
        setState(() {
          tugas[index]['status'] = status;
        });

        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Status diubah menjadi $status.',
            ),
          ),
        );
      },
    );
  }

  void _hapusTugas(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Hapus Tugas?',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),

          content: Text(
            'Tugas "${tugas[index]['judul']}" akan dihapus dari daftar.',
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
                  tugas.removeAt(index);
                });

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Tugas berhasil dihapus.',
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }
}