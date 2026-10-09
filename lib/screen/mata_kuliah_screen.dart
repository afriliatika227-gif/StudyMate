import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import 'tambah_mata_kuliah_screen.dart';

class MataKuliahScreen extends StatefulWidget {
  const MataKuliahScreen({super.key});

  @override
  State<MataKuliahScreen> createState() => _MataKuliahScreenState();
}

class _MataKuliahScreenState extends State<MataKuliahScreen> {
  final DatabaseHelper _db = DatabaseHelper.instance;

  List<Map<String, dynamic>> mataKuliah = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMataKuliah();
  }

  Future<void> _loadMataKuliah() async {
    final data = await _db.getCourses();

    if (!mounted) return;

    setState(() {
      mataKuliah = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      appBar: AppBar(
        title: const Text(
          'Mata Kuliah',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF6EA8FE),
              ),
            )
          : mataKuliah.isEmpty
              ? const Center(
                  child: Text(
                    'Belum ada mata kuliah',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: mataKuliah.length,
                  itemBuilder: (context, index) {
                    return _mataKuliahCard(
                      index: index,
                      mk: mataKuliah[index],
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab-mata-kuliah',
        onPressed: _tambahMataKuliah,
        backgroundColor: const Color(0xFF6EA8FE),
        icon: const Icon(
          Icons.add,
          color: Colors.white,
        ),
        label: const Text(
          'Tambah Mata Kuliah',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _mataKuliahCard({
    required int index,
    required Map<String, dynamic> mk,
  }) {
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
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF4FF),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.menu_book_rounded,
                  color: Color(0xFF6EA8FE),
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mk['course_name']?.toString() ?? '',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${mk['course_code'] ?? ''} • Semester ${mk['semester'] ?? ''}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      mk['lecturer_name']?.toString() ?? '',
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
        ),
      ),
    );
  }

  void _lihatDetail(int index) {
    final mk = mataKuliah[index];

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Detail Mata Kuliah',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _detailItem(
                  'Nama Mata Kuliah',
                  mk['course_name']?.toString() ?? '',
                ),
                _detailItem(
                  'Kode Mata Kuliah',
                  mk['course_code']?.toString() ?? '',
                ),
                _detailItem(
                  'Dosen Pengampu',
                  mk['lecturer_name']?.toString() ?? '',
                ),
                _detailItem(
                  'Semester',
                  'Semester ${mk['semester'] ?? ''}',
                ),
              ],
            ),
          ),
          actions: [
            TextButton.icon(
              onPressed: () {
                Navigator.pop(dialogContext);
                _editMataKuliah(index);
              },
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Edit'),
            ),
            TextButton.icon(
              onPressed: () {
                Navigator.pop(dialogContext);
                _konfirmasiHapus(index);
              },
              icon: const Icon(
                Icons.delete_outline,
                color: Colors.red,
              ),
              label: const Text(
                'Hapus',
                style: TextStyle(color: Colors.red),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  Widget _detailItem(
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _tambahMataKuliah() async {
    final hasil =
        await Navigator.push<Map<String, String>>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const TambahMataKuliahScreen(),
      ),
    );

    if (hasil == null) return;

    final semesterText = hasil['semester'] ?? 'Semester 1';

    final semester = int.tryParse(
          semesterText.replaceAll(
            RegExp(r'[^0-9]'),
            '',
          ),
        ) ??
        1;

    await _db.insertCourse({
      'course_name': hasil['nama'] ?? '',
      'course_code': hasil['kode'] ?? '',
      'lecturer_name': hasil['dosen'] ?? '',
      'semester': semester,
    });

    await _loadMataKuliah();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Mata kuliah berhasil ditambahkan.',
        ),
      ),
    );
  }

  Future<void> _editMataKuliah(int index) async {
    final mk = mataKuliah[index];

    final dataLama = {
      'nama': mk['course_name']?.toString() ?? '',
      'kode': mk['course_code']?.toString() ?? '',
      'dosen': mk['lecturer_name']?.toString() ?? '',
      'semester': 'Semester ${mk['semester'] ?? 1}',
    };

    final hasil =
        await Navigator.push<Map<String, String>>(
      context,
      MaterialPageRoute(
        builder: (context) => TambahMataKuliahScreen(
          dataEdit: dataLama,
        ),
      ),
    );

    if (hasil == null) return;

    final semesterText = hasil['semester'] ?? 'Semester 1';

    final semester = int.tryParse(
          semesterText.replaceAll(
            RegExp(r'[^0-9]'),
            '',
          ),
        ) ??
        1;

    await _db.updateCourse(
      mk['course_id'] as int,
      {
        'course_name': hasil['nama'] ?? '',
        'course_code': hasil['kode'] ?? '',
        'lecturer_name': hasil['dosen'] ?? '',
        'semester': semester,
      },
    );

    await _loadMataKuliah();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Mata kuliah berhasil diperbarui.',
        ),
      ),
    );
  }

  void _konfirmasiHapus(int index) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Hapus Mata Kuliah?'),
          content: const Text(
            'Apakah kamu yakin ingin menghapus mata kuliah ini?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                final courseId =
                    mataKuliah[index]['course_id'] as int;

                await _db.deleteCourse(courseId);

                if (!mounted) return;

                Navigator.pop(dialogContext);

                await _loadMataKuliah();

                if (!mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Mata kuliah berhasil dihapus.',
                    ),
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
}