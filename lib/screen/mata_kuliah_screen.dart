
import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import 'tambah_mata_kuliah_screen.dart';

const Color _blue = Color(0xFF8DBBFA);
const Color _darkBlue = Color(0xFF40516F);
const Color _background = Color(0xFFF4F8FF);
const Color _softBlue = Color(0xFFEAF4FF);
const Color _softPink = Color(0xFFFFEAF2);
const Color _softPinkDark = Color(0xFFE99BB9);
const Color _softBlueDark = Color(0xFF719FD9);
const Color _softLavender = Color(0xFFE8E3FF);
const Color _muted = Color(0xFF8796B0);

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
        backgroundColor: _background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: _darkBlue),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Mata Kuliah',
          style: TextStyle(
            color: _darkBlue,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: _blue),
            )
          : RefreshIndicator(
              color: _softPinkDark,
              onRefresh: _loadMataKuliah,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
                children: [
                  _header(),
                  const SizedBox(height: 26),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Daftar Mata Kuliah',
                          style: TextStyle(
                            color: _darkBlue,
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: _softPink,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${mataKuliah.length} mata kuliah',
                          style: const TextStyle(
                            color: _darkBlue,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
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
        elevation: 4,
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
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFDCEBFF),
            Color(0xFFF3EFFF),
            Color(0xFFFFEAF2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: _blue.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mata Kuliahku 📚',
                  style: TextStyle(
                    color: _darkBlue,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  'Belajar lebih teratur, satu langkah setiap hari.',
                  style: TextStyle(
                    color: _darkBlue.withValues(alpha: 0.78),
                    fontSize: 12,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Semangat kuliahnya! ✨',
                    style: TextStyle(
                      color: _darkBlue,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 70,
            height: 78,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(
              Icons.auto_stories_rounded,
              size: 39,
              color: _softBlueDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 35,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _softBlue),
      ),
      child: Column(
        children: [
          Container(
            width: 86,
            height: 86,
            decoration: const BoxDecoration(
              color: _softPink,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.menu_book_rounded,
              color: _softPinkDark,
              size: 43,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Belum ada mata kuliah',
            style: TextStyle(
              color: _darkBlue,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Yuk, tambahkan mata kuliah pertamamu!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _muted,
              fontSize: 12,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Tekan tombol Tambah Mata Kuliah di bawah.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _softBlueDark,
              fontSize: 11,
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
    final isPink = index.isOdd;
    final accent = isPink ? _softPinkDark : _softBlueDark;
    final tileColor = isPink ? _softPink : _softBlue;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isPink
              ? _softPinkDark.withValues(alpha: 0.25)
              : _softBlueDark.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.09),
            blurRadius: 14,
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 53,
                  height: 53,
                  decoration: BoxDecoration(
                    color: tileColor,
                    borderRadius: BorderRadius.circular(17),
                  ),
                  child: Icon(
                    Icons.menu_book_rounded,
                    color: accent,
                    size: 28,
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
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        (mk['course_code'] ?? '-').toString(),
                        style: const TextStyle(
                          color: _muted,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 7,
                        runSpacing: 7,
                        children: [
                          _infoChip(
                            Icons.calendar_month_rounded,
                            'Semester ${mk['semester'] ?? '-'}',
                            pink: isPink,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(
                            Icons.person_outline_rounded,
                            size: 16,
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
                const SizedBox(width: 4),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: _muted,
                  size: 23,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoChip(
    IconData icon,
    String text, {
    bool pink = false,
  }) {
    final color = pink ? _softPinkDark : _softBlueDark;
    final background = pink ? _softPink : _softBlue;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              color: _darkBlue,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _lihatDetail(int index) {
    final mk = mataKuliah[index];

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: index.isEven ? _softBlue : _softPink,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.menu_book_rounded,
                color: index.isEven ? _softBlueDark : _softPinkDark,
              ),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Detail Mata Kuliah',
                style: TextStyle(
                  color: _darkBlue,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
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
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          Wrap(
            alignment: WrapAlignment.end,
            spacing: 6,
            runSpacing: 6,
            children: [
              TextButton.icon(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  _editMataKuliah(index);
                },
                icon: const Icon(Icons.edit_rounded, size: 17),
                label: const Text('Edit'),
                style: TextButton.styleFrom(
                  foregroundColor: _softBlueDark,
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
                  foregroundColor: Colors.redAccent,
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
          ),
        ],
      ),
    );
  }

  Widget _detailItem(String label, String value) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: _background,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: _softBlue),
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
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

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
      _showSnackBar('Mata kuliah berhasil ditambahkan 🩵');
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Gagal menambahkan mata kuliah.');
    }
  }

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
      _showSnackBar('Mata kuliah berhasil diperbarui 💗');
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Gagal memperbarui mata kuliah.');
    }
  }

  Future<void> _konfirmasiHapus(int index) async {
    final mk = mataKuliah[index];

    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: const Text(
          'Hapus Mata Kuliah?',
          style: TextStyle(
            color: _darkBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Mata kuliah "${mk['course_name']}" akan dihapus. Kamu yakin?',
          style: const TextStyle(
            color: _muted,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text(
              'Batal',
              style: TextStyle(color: _darkBlue),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: _softPinkDark,
              foregroundColor: Colors.white,
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

  void _showSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          backgroundColor: _darkBlue,
        ),
      );
  }
}
