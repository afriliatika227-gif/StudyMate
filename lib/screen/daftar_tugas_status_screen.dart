
import 'package:flutter/material.dart';
import '../database/database_helper.dart';

const Color _plum = Color(0xFF66527F);
const Color _darkPlum = Color(0xFF423650);
const Color _background = Color(0xFFFAF8FC);
const Color _line = Color(0xFFEAE5EF);
const Color _muted = Color(0xFF8B8494);
const Color _green = Color(0xFF36A875);
const Color _orange = Color(0xFFE6A34D);
const Color _pink = Color(0xFFD7799E);

class DaftarTugasStatusScreen extends StatefulWidget {
  final String status;

  const DaftarTugasStatusScreen({
    super.key,
    required this.status,
  });

  @override
  State<DaftarTugasStatusScreen> createState() =>
      _DaftarTugasStatusScreenState();
}

class _DaftarTugasStatusScreenState
    extends State<DaftarTugasStatusScreen> {
  final DatabaseHelper _db = DatabaseHelper.instance;

  List<Map<String, dynamic>> _daftarTugas = [];
  bool _sedangMemuat = true;

  Color _warnaStatus() {
    switch (widget.status) {
      case 'Selesai':
        return _green;
      case 'Sedang Dikerjakan':
        return _plum;
      default:
        return _orange;
    }
  }

  Color _warnaLatarStatus() {
    switch (widget.status) {
      case 'Selesai':
        return const Color(0xFFE8F5EF);
      case 'Sedang Dikerjakan':
        return const Color(0xFFF0EBF7);
      default:
        return const Color(0xFFFFF1E5);
    }
  }

  IconData _ikonStatus() {
    switch (widget.status) {
      case 'Selesai':
        return Icons.check_circle_rounded;
      case 'Sedang Dikerjakan':
        return Icons.autorenew_rounded;
      default:
        return Icons.pending_actions_rounded;
    }
  }

  String _judulStatus() {
    switch (widget.status) {
      case 'Selesai':
        return 'Tugas Selesai';
      case 'Sedang Dikerjakan':
        return 'Sedang Dikerjakan';
      default:
        return 'Belum Dikerjakan';
    }
  }

  @override
  void initState() {
    super.initState();
    _muatTugas();
  }

  Future<void> _muatTugas() async {
    try {
      final semuaTugas = await _db.getTasks();

      final tugasSesuaiStatus = semuaTugas.where((item) {
        return '${item['status']}' == widget.status;
      }).toList();

      if (!mounted) return;

      setState(() {
        _daftarTugas = tugasSesuaiStatus;
        _sedangMemuat = false;
      });
    } catch (e) {
      debugPrint('Gagal memuat tugas: $e');

      if (!mounted) return;

      setState(() {
        _sedangMemuat = false;
      });
    }
  }

  Widget _buildHeader() {
    final warna = _warnaStatus();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _warnaLatarStatus(),
            Colors.white,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: warna.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: warna.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              _ikonStatus(),
              color: warna,
              size: 28,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _judulStatus(),
                  style: TextStyle(
                    color: warna,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Pantau perkembangan tugas kuliahmu',
                  style: TextStyle(
                    color: _muted,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJumlahTugas() {
    return Row(
      children: [
        const Text(
          'Daftar Tugas',
          style: TextStyle(
            color: _darkPlum,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 7,
          ),
          decoration: BoxDecoration(
            color: _warnaLatarStatus(),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${_daftarTugas.length} Tugas',
            style: TextStyle(
              color: _warnaStatus(),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildKartuTugas(Map<String, dynamic> item) {
    final warna = _warnaStatus();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: _line),
        boxShadow: [
          BoxShadow(
            color: _darkPlum.withValues(alpha: 0.035),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: _warnaLatarStatus(),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              widget.status == 'Selesai'
                  ? Icons.task_alt_rounded
                  : Icons.assignment_outlined,
              color: warna,
              size: 23,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${item['title'] ?? 'Tanpa Judul'}',
                  style: const TextStyle(
                    color: _darkPlum,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 7),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.menu_book_outlined,
                      color: _muted,
                      size: 15,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${item['course_name'] ?? 'Mata kuliah'}',
                        style: const TextStyle(
                          color: _muted,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 11),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _warnaLatarStatus(),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    widget.status,
                    style: TextStyle(
                      color: warna,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (widget.status == 'Selesai') ...[
            const SizedBox(width: 8),
            Container(
              width: 29,
              height: 29,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5EF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.check_rounded,
                color: _green,
                size: 20,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildKosong() {
    final warna = _warnaStatus();

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: _warnaLatarStatus(),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Icon(
                _ikonStatus(),
                color: warna,
                size: 45,
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              'Belum Ada Tugas',
              style: TextStyle(
                color: _darkPlum,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 9),
            Text(
              'Belum ada tugas ${widget.status.toLowerCase()}.\n'
              'Yuk, tetap semangat mengatur aktivitas kuliahmu!',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _muted,
                fontSize: 13,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        title: const Text(
          'Daftar Tugas',
          style: TextStyle(
            color: _darkPlum,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        iconTheme: const IconThemeData(
          color: _darkPlum,
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
      body: _sedangMemuat
          ? const Center(
              child: CircularProgressIndicator(
                color: _plum,
              ),
            )
          : RefreshIndicator(
              color: _plum,
              onRefresh: _muatTugas,
              child: _daftarTugas.isEmpty
                  ? ListView(
                      physics:
                          const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(
                          height:
                              MediaQuery.of(context).size.height * 0.55,
                          child: _buildKosong(),
                        ),
                      ],
                    )
                  : ListView(
                      physics:
                          const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(
                        18, 18, 18, 25,
                      ),
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 25),
                        _buildJumlahTugas(),
                        const SizedBox(height: 15),
                        ..._daftarTugas.map(_buildKartuTugas),
                      ],
                    ),
            ),
    );
  }
}
