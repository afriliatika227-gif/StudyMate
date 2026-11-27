
import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import 'tambah_mata_kuliah_screen.dart';

const Color _plum = Color(0xFF66527F);
const Color _darkPlum = Color(0xFF423650);
const Color _lavender = Color(0xFFEDE6F6);
const Color _softLavender = Color(0xFFF6F2FA);
const Color _pink = Color(0xFFD98EAD);
const Color _softPink = Color(0xFFFAEDF2);
const Color _peach = Color(0xFFE8AC91);
const Color _softPeach = Color(0xFFFFF1E9);
const Color _background = Color(0xFFFAF8FC);
const Color _line = Color(0xFFECE6F0);
const Color _muted = Color(0xFF92899B);
const Color _green = Color(0xFF79A995);

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
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: _darkPlum,
          ),
        ),
        title: const Text(
          'Mata Kuliah',
          style: TextStyle(
            color: _darkPlum,
            fontSize: 19,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: _plum),
            )
          : RefreshIndicator(
              color: _plum,
              onRefresh: _loadMataKuliah,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 110),
                children: [
                  _header(),
                  const SizedBox(height: 25),
                  _summary(),
                  const SizedBox(height: 28),

                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Daftar Perkuliahan',
                          style: TextStyle(
                            color: _darkPlum,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Text(
                        '${mataKuliah.length} mata kuliah',
                        style: const TextStyle(
                          color: _muted,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 5),

                  const Text(
                    'Semua mata kuliah yang sedang kamu pelajari.',
                    style: TextStyle(
                      color: _muted,
                      fontSize: 12,
                    ),
                  ),

                  const SizedBox(height: 17),

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
        backgroundColor: _plum,
        foregroundColor: Colors.white,
        elevation: 3,
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

  // HEADER FOTO BUKU FULL BACKGROUND
  Widget _header() {
    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(23),
        boxShadow: [
          BoxShadow(
            color: _plum.withValues(alpha: 0.17),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(23),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // FOTO MEMENUHI SELURUH BANNER
            Image.network(
              'https://images.unsplash.com/photo-1497633762265-9d179a990aa6?w=1000',
              fit: BoxFit.cover,
              alignment: Alignment.center,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;

                return Container(
                  color: _softLavender,
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: _plum,
                      strokeWidth: 2,
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: _lavender,
                  child: const Center(
                    child: Icon(
                      Icons.menu_book_rounded,
                      color: _plum,
                      size: 45,
                    ),
                  ),
                );
              },
            ),

            // GRADASI AGAR TULISAN TERBACA
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x12000000),
                    Color(0x35000000),
                    Color(0xCC241B30),
                  ],
                  stops: [0.0, 0.38, 1.0],
                ),
              ),
            ),

            // TULISAN DI ATAS FOTO
            const Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Ruang Belajarmu',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      shadows: [
                        Shadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 9),
                  Text(
                    'Atur mata kuliah, kenali setiap materi, '
                    'dan jalani perkuliahan dengan lebih terarah.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      height: 1.6,
                      shadows: [
                        Shadow(
                          color: Colors.black38,
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 13),
                  Row(
                    children: [
                      Icon(
                        Icons.auto_awesome_rounded,
                        color: Color(0xFFFFD9E8),
                        size: 15,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Belajar lebih terorganisir',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // RINGKASAN
  Widget _summary() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: _line),
      ),
      child: Row(
        children: [
          Container(
            width: 49,
            height: 49,
            decoration: BoxDecoration(
              color: _softLavender,
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.library_books_rounded,
              color: _plum,
              size: 25,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total Mata Kuliah',
                  style: TextStyle(
                    color: _muted,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${mataKuliah.length} Mata Kuliah',
                  style: const TextStyle(
                    color: _darkPlum,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 11,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: _softPink,
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.bookmark_rounded,
                  size: 13,
                  color: _pink,
                ),
                SizedBox(width: 5),
                Text(
                  'Akademik',
                  style: TextStyle(
                    color: _pink,
                    fontSize: 10,
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

  // TAMPILAN KOSONG
  Widget _emptyState() {
    return Container(
      margin: const EdgeInsets.only(top: 5),
      padding: const EdgeInsets.symmetric(
        horizontal: 22,
        vertical: 35,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _line),
      ),
      child: Column(
        children: [
          Container(
            width: 75,
            height: 75,
            decoration: BoxDecoration(
              color: _softLavender,
              borderRadius: BorderRadius.circular(23),
            ),
            child: const Icon(
              Icons.menu_book_rounded,
              color: _plum,
              size: 37,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Belum Ada Mata Kuliah',
            style: TextStyle(
              color: _darkPlum,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Yuk, tambahkan mata kuliahmu agar semua '
            'aktivitas perkuliahan lebih mudah diatur.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _muted,
              fontSize: 12,
              height: 1.6,
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
    final colors = [
      _plum,
      _pink,
      _peach,
      _green,
    ];

    final backgrounds = [
      _softLavender,
      _softPink,
      _softPeach,
      const Color(0xFFEDF6F1),
    ];

    final accent = colors[index % colors.length];
    final tileColor = backgrounds[index % backgrounds.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _line),
        boxShadow: [
          BoxShadow(
            color: _darkPlum.withValues(alpha: 0.035),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: () => _lihatDetail(index),
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 51,
                  height: 56,
                  decoration: BoxDecoration(
                    color: tileColor,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(
                    Icons.menu_book_rounded,
                    color: accent,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (mk['course_name'] ?? 'Tanpa nama').toString(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _darkPlum,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          height: 1.35,
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
                      Row(
                        children: [
                          Icon(
                            Icons.person_outline_rounded,
                            size: 14,
                            color: accent,
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              (mk['lecturer_name'] ?? '-').toString(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: _muted,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 9),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: tileColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Semester ${mk['semester'] ?? '-'}',
                          style: TextStyle(
                            color: accent,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
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

  // DETAIL MATA KULIAH
  void _lihatDetail(int index) {
    final mk = mataKuliah[index];

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Row(
          children: [
            Icon(
              Icons.menu_book_rounded,
              color: _plum,
              size: 23,
            ),
            SizedBox(width: 9),
            Text(
              'Detail Mata Kuliah',
              style: TextStyle(
                color: _darkPlum,
                fontSize: 17,
                fontWeight: FontWeight.w700,
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
        actionsPadding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.pop(dialogContext);
              _editMataKuliah(index);
            },
            icon: const Icon(Icons.edit_outlined, size: 16),
            label: const Text('Edit'),
            style: TextButton.styleFrom(
              foregroundColor: _plum,
            ),
          ),
          TextButton.icon(
            onPressed: () {
              Navigator.pop(dialogContext);
              _konfirmasiHapus(index);
            },
            icon: const Icon(
              Icons.delete_outline_rounded,
              size: 16,
            ),
            label: const Text('Hapus'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
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
        color: _softLavender,
        borderRadius: BorderRadius.circular(11),
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
              color: _darkPlum,
              fontSize: 13,
              fontWeight: FontWeight.w600,
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
          borderRadius: BorderRadius.circular(19),
        ),
        title: const Text(
          'Hapus Mata Kuliah?',
          style: TextStyle(
            color: _darkPlum,
            fontSize: 17,
            fontWeight: FontWeight.w700,
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
              backgroundColor: const Color(0xFFD56F8F),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
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
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: _darkPlum,
        ),
      );
  }
}
