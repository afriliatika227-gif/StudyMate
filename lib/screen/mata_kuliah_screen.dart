
import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import 'tambah_mata_kuliah_screen.dart';

const Color _blue = Color(0xFF6EA8FE);
const Color _darkBlue = Color(0xFF315780);
const Color _paleBlue = Color(0xFFEAF4FF);
const Color _background = Color(0xFFF5F9FF);
const Color _muted = Color(0xFF7D91AA);

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
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        foregroundColor: _darkBlue,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Mata Kuliah',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 21,
            color: _darkBlue,
          ),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: _blue),
            )
          : RefreshIndicator(
              color: _blue,
              onRefresh: _loadMataKuliah,
              child: mataKuliah.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(24),
                      children: [
                        const SizedBox(height: 100),
                        Icon(
                          Icons.menu_book_rounded,
                          size: 72,
                          color: _blue.withValues(alpha: 0.65),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Belum ada mata kuliah',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: _darkBlue,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Yuk, tambahkan mata kuliah pertamamu!',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: _muted),
                        ),
                      ],
                    )
                  : ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                      children: [
                        _header(),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Daftar Mata Kuliah',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: _darkBlue,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                color: _paleBlue,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${mataKuliah.length} mata kuliah',
                                style: const TextStyle(
                                  color: _darkBlue,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        ...List.generate(
                          mataKuliah.length,
                          (index) => _mataKuliahCard(
                            index: index,
                            mk: mataKuliah[index],
                          ),
                        ),
                      ],
                    ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab-mata-kuliah',
        onPressed: _tambahMataKuliah,
        backgroundColor: _blue,
        foregroundColor: Colors.white,
        elevation: 3,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Tambah Mata Kuliah',
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
          colors: [Color(0xFFDCEBFF), Color(0xFFF0F6FF)],
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
                  'Belajar lebih teratur ✨',
                  style: TextStyle(
                    fontSize: 19,
                    height: 1.3,
                    fontWeight: FontWeight.bold,
                    color: _darkBlue,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Kelola mata kuliah dan informasi dosenmu di sini.',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: _darkBlue.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(19),
            ),
            child: const Icon(
              Icons.menu_book_rounded,
              color: _blue,
              size: 34,
            ),
          ),
        ],
      ),
    );
  }

  Widget _mataKuliahCard({
    required int index,
    required Map<String, dynamic> mk,
  }) {
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
          onTap: () => _lihatDetail(index),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 54,
                  height: 58,
                  decoration: BoxDecoration(
                    color: _paleBlue,
                    borderRadius: BorderRadius.circular(17),
                  ),
                  child: const Icon(
                    Icons.menu_book_rounded,
                    color: _blue,
                    size: 29,
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
                          fontSize: 15,
                          height: 1.35,
                          fontWeight: FontWeight.bold,
                          color: _darkBlue,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        mk['course_code']?.toString() ?? '',
                        style: const TextStyle(
                          fontSize: 12,
                          color: _muted,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Wrap(
                        spacing: 6,
                        runSpacing: 5,
                        children: [
                          _infoChip(
                            Icons.school_outlined,
                            'Semester ${mk['semester'] ?? ''}',
                          ),
                        ],
                      ),
                      const SizedBox(height: 7),
                      Row(
                        children: [
                          const Icon(
                            Icons.person_outline_rounded,
                            size: 15,
                            color: _muted,
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              mk['lecturer_name']?.toString() ?? '',
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
                const SizedBox(width: 4),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: _blue,
                  size: 25,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: _paleBlue,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: _darkBlue),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 11,
              color: _darkBlue,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _lihatDetail(int index) {
    final mk = mataKuliah[index];

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Row(
            children: [
              Icon(Icons.menu_book_rounded, color: _blue),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Detail Mata Kuliah',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _darkBlue,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
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
              icon: const Icon(Icons.edit_outlined, color: _blue),
              label: const Text(
                'Edit',
                style: TextStyle(color: _darkBlue),
              ),
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
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                'Tutup',
                style: TextStyle(color: _darkBlue),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _detailItem(String label, String value) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _background,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: _muted,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _darkBlue,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _tambahMataKuliah() async {
    final hasil = await Navigator.push<Map<String, String>>(
      context,
      MaterialPageRoute(
        builder: (context) => const TambahMataKuliahScreen(),
      ),
    );

    if (hasil == null) return;

    final semesterText = hasil['semester'] ?? 'Semester 1';
    final semester = int.tryParse(
          semesterText.replaceAll(RegExp(r'[^0-9]'), ''),
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
        content: Text('Mata kuliah berhasil ditambahkan.'),
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

    final hasil = await Navigator.push<Map<String, String>>(
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
          semesterText.replaceAll(RegExp(r'[^0-9]'), ''),
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
        content: Text('Mata kuliah berhasil diperbarui.'),
      ),
    );
  }

  void _konfirmasiHapus(int index) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            'Hapus Mata Kuliah?',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: _darkBlue,
            ),
          ),
          content: const Text(
            'Apakah kamu yakin ingin menghapus mata kuliah ini?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                'Batal',
                style: TextStyle(color: _darkBlue),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final courseId = mataKuliah[index]['course_id'] as int;

                await _db.deleteCourse(courseId);

                if (!mounted) return;

                Navigator.pop(dialogContext);
                await _loadMataKuliah();

                if (!mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Mata kuliah berhasil dihapus.'),
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
