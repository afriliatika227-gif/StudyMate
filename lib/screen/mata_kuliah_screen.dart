
import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import 'tambah_mata_kuliah_screen.dart';

const Color _blue = Color(0xFF3478C8);
const Color _darkBlue = Color(0xFF344054);
const Color _background = Color(0xFFF5F7FA);
const Color _line = Color(0xFFE4E8EF);
const Color _muted = Color(0xFF7C8798);

const Color _softBlue = Color(0xFFEAF2FC);
const Color _softPink = Color(0xFFFCECF2);
const Color _softLavender = Color(0xFFF0EDFA);

const Color _pinkDark = Color(0xFFD7799E);
const Color _purpleDark = Color(0xFF8174BC);

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
    try {
      final data = await _db.getCourses();

      if (!mounted) return;

      setState(() {
        mataKuliah = data;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => isLoading = false);
      _showSnackBar('Gagal memuat mata kuliah.');
    }
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
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: _darkBlue,
          ),
        ),
        title: const Text(
          'Mata Kuliah',
          style: TextStyle(
            color: _darkBlue,
            fontSize: 19,
            fontWeight: FontWeight.w600,
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
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: _blue),
            )
          : RefreshIndicator(
              color: _blue,
              onRefresh: _loadMataKuliah,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
                children: [
                  _header(),

                  const SizedBox(height: 27),

                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Daftar Mata Kuliah',
                          style: TextStyle(
                            color: _darkBlue,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
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
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${mataKuliah.length} mata kuliah',
                          style: const TextStyle(
                            color: _blue,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 5),

                  const Text(
                    'Daftar mata kuliah yang sedang kamu pelajari.',
                    style: TextStyle(
                      color: _muted,
                      fontSize: 12,
                    ),
                  ),

                  const SizedBox(height: 16),

                  if (mataKuliah.isEmpty)
                    _emptyState()
                  else
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
        elevation: 2,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Tambah Mata Kuliah',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  // HEADER
  Widget _header() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _blue,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mata Kuliahku',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Kelola daftar mata kuliah dan informasi '
                  'perkuliahanmu di sini.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 57,
            height: 57,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.menu_book_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
        ],
      ),
    );
  }

  // TAMPILAN KOSONG
  Widget _emptyState() {
    return Container(
      margin: const EdgeInsets.only(top: 5),
      padding: const EdgeInsets.symmetric(
        horizontal: 22,
        vertical: 32,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _line),
      ),
      child: Column(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: _softBlue,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.menu_book_outlined,
              color: _blue,
              size: 34,
            ),
          ),
          const SizedBox(height: 17),
          const Text(
            'Belum Ada Mata Kuliah',
            style: TextStyle(
              color: _darkBlue,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tambahkan mata kuliah pertamamu untuk '
            'mulai mengatur aktivitas perkuliahan.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _muted,
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // KARTU MATA KULIAH
  Widget _mataKuliahCard({
    required int index,
    required Map<String, dynamic> mk,
  }) {
    final accent = index % 3 == 0
        ? _blue
        : index % 3 == 1
            ? _pinkDark
            : _purpleDark;

    final tileColor = index % 3 == 0
        ? _softBlue
        : index % 3 == 1
            ? _softPink
            : _softLavender;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _line),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: () => _lihatDetail(index),
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 47,
                  height: 47,
                  decoration: BoxDecoration(
                    color: tileColor,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(
                    Icons.menu_book_rounded,
                    color: accent,
                    size: 24,
                  ),
                ),

                const SizedBox(width: 13),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (mk['course_name'] ?? 'Tanpa nama').toString(),
                        style: const TextStyle(
                          color: _darkBlue,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        (mk['course_code'] ?? '-').toString(),
                        style: const TextStyle(
                          color: _muted,
                          fontSize: 11,
                        ),
                      ),

                      const SizedBox(height: 10),

                      _infoChip(
                        Icons.calendar_month_outlined,
                        'Semester ${mk['semester'] ?? '-'}',
                        color: accent,
                        background: tileColor,
                      ),

                      const SizedBox(height: 10),

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
                              (mk['lecturer_name'] ?? '-').toString(),
                              style: const TextStyle(
                                color: _muted,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 3),

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

  // LABEL SEMESTER
  Widget _infoChip(
    IconData icon,
    String text, {
    required Color color,
    required Color background,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // DETAIL MATA KULIAH
  void _lihatDetail(int index) {
    final mk = mataKuliah[index];

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Detail Mata Kuliah',
          style: TextStyle(
            color: _darkBlue,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _detailItem(
                'Nama Mata Kuliah',
                (mk['course_name'] ?? '-').toString(),
              ),
              _detailItem(
                'Kode Mata Kuliah',
                (mk['course_code'] ?? '-').toString(),
              ),
              _detailItem(
                'Nama Dosen',
                (mk['lecturer_name'] ?? '-').toString(),
              ),
              _detailItem(
                'Semester',
                (mk['semester'] ?? '-').toString(),
              ),
            ],
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.pop(dialogContext);
              _editMataKuliah(index);
            },
            icon: const Icon(Icons.edit_outlined, size: 17),
            label: const Text('Edit'),
            style: TextButton.styleFrom(
              foregroundColor: _blue,
            ),
          ),
          TextButton.icon(
            onPressed: () {
              Navigator.pop(dialogContext);
              _konfirmasiHapus(index);
            },
            icon: const Icon(Icons.delete_outline_rounded, size: 17),
            label: const Text('Hapus'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red.shade600,
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              'Tutup',
              style: TextStyle(color: _muted),
            ),
          ),
        ],
      ),
    );
  }

  // ITEM DETAIL
  Widget _detailItem(String label, String value) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _line),
      ),
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
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              color: _darkBlue,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // TAMBAH MATA KULIAH
  Future<void> _tambahMataKuliah() async {
    final result = await Navigator.push<Map<String, String>>(
      context,
      MaterialPageRoute(
        builder: (_) => const TambahMataKuliahScreen(),
      ),
    );

    if (result == null || !mounted) return;

    try {
      await _db.insertCourse({
        'course_name': result['course_name'] ?? '',
        'course_code': result['course_code'] ?? '',
        'lecturer_name': result['lecturer_name'] ?? '',
        'semester': int.tryParse(result['semester'] ?? '') ?? 1,
      });

      await _loadMataKuliah();

      if (!mounted) return;
      _showSnackBar('Mata kuliah berhasil ditambahkan.');
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Gagal menambahkan mata kuliah.');
    }
  }

  // EDIT MATA KULIAH
  Future<void> _editMataKuliah(int index) async {
    final mk = mataKuliah[index];

    final dataLama = <String, String>{
      'course_name': (mk['course_name'] ?? '').toString(),
      'course_code': (mk['course_code'] ?? '').toString(),
      'lecturer_name': (mk['lecturer_name'] ?? '').toString(),
      'semester': (mk['semester'] ?? '').toString(),
    };

    final result = await Navigator.push<Map<String, String>>(
      context,
      MaterialPageRoute(
        builder: (_) => TambahMataKuliahScreen(
          dataEdit: dataLama,
        ),
      ),
    );

    if (result == null || !mounted) return;

    try {
      await _db.updateCourse(
        mk['course_id'] as int,
        {
          'course_name': result['course_name'] ?? '',
          'course_code': result['course_code'] ?? '',
          'lecturer_name': result['lecturer_name'] ?? '',
          'semester': int.tryParse(result['semester'] ?? '') ?? 1,
        },
      );

      await _loadMataKuliah();

      if (!mounted) return;
      _showSnackBar('Mata kuliah berhasil diperbarui.');
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Gagal memperbarui mata kuliah.');
    }
  }

  // KONFIRMASI HAPUS
  Future<void> _konfirmasiHapus(int index) async {
    final mk = mataKuliah[index];

    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Hapus Mata Kuliah?',
          style: TextStyle(
            color: _darkBlue,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Mata kuliah "${mk['course_name']}" akan dihapus. '
          'Apakah kamu yakin?',
          style: const TextStyle(
            color: _muted,
            fontSize: 13,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text(
              'Batal',
              style: TextStyle(color: _muted),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFD95C65),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9),
              ),
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Ya, Hapus'),
          ),
        ],
      ),
    );

    if (konfirmasi != true || !mounted) return;

    try {
      await _db.deleteCourse(mk['course_id'] as int);
      await _loadMataKuliah();

      if (!mounted) return;
      _showSnackBar('Mata kuliah berhasil dihapus.');
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Gagal menghapus mata kuliah.');
    }
  }

  // NOTIFIKASI
  void _showSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: _darkBlue,
        ),
      );
  }
}
