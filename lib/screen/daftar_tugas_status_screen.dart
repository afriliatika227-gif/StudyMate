
import 'package:flutter/material.dart';
import '../database/database_helper.dart';

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

  static const Color _biru = Color(0xFF3478C8);
  static const Color _biruTua = Color(0xFF344054);
  static const Color _background = Color(0xFFF5F7FA);
  static const Color _line = Color(0xFFE4E8EF);
  static const Color _abu = Color(0xFF7C8798);

  static const Color _hijau = Color(0xFF36A875);
  static const Color _oranye = Color(0xFFE39A42);
  static const Color _pink = Color(0xFFD7799E);

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

  Color _warnaStatus() {
    switch (widget.status) {
      case 'Selesai':
        return _hijau;
      case 'Sedang Dikerjakan':
        return _biru;
      default:
        return _oranye;
    }
  }

  Color _warnaLatarStatus() {
    switch (widget.status) {
      case 'Selesai':
        return const Color(0xFFE7F6EF);
      case 'Sedang Dikerjakan':
        return const Color(0xFFEAF2FC);
      default:
        return const Color(0xFFFFF3E5);
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

  Widget _buildHeader() {
    final warna = _warnaStatus();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _warnaLatarStatus(),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: warna.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              _ikonStatus(),
              color: warna,
              size: 27,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _judulStatus(),
                  style: TextStyle(
                    color: warna,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Pantau perkembangan tugas kuliahmu',
                  style: TextStyle(
                    color: _abu,
                    fontSize: 12,
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
            color: _biruTua,
            fontSize: 16,
            fontWeight: FontWeight.w600,
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
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '${_daftarTugas.length} Tugas',
            style: TextStyle(
              color: _warnaStatus(),
              fontSize: 12,
              fontWeight: FontWeight.w600,
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
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _line),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: _warnaLatarStatus(),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(
              Icons.assignment_outlined,
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
                    color: _biruTua,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 7),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.menu_book_outlined,
                      color: _abu,
                      size: 15,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${item['course_name'] ?? 'Mata kuliah'}',
                        style: const TextStyle(
                          color: _abu,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: _warnaLatarStatus(),
                    borderRadius: BorderRadius.circular(6),
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
            const Icon(
              Icons.check_circle_rounded,
              color: _hijau,
              size: 23,
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
              width: 95,
              height: 95,
              decoration: BoxDecoration(
                color: _warnaLatarStatus(),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                _ikonStatus(),
                color: warna,
                size: 43,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Belum Ada Tugas',
              style: TextStyle(
                color: _biruTua,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Belum ada tugas ${widget.status.toLowerCase()}.\n'
              'Yuk, tetap semangat mengatur aktivitas kuliahmu!',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _abu,
                fontSize: 13,
                height: 1.5,
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
            color: _biruTua,
            fontWeight: FontWeight.w600,
            fontSize: 19,
          ),
        ),
        iconTheme: const IconThemeData(
          color: _biruTua,
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
                color: _biru,
              ),
            )
          : RefreshIndicator(
              color: _biru,
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
                        const SizedBox(height: 24),
                        _buildJumlahTugas(),
                        const SizedBox(height: 14),
                        ..._daftarTugas.map(_buildKartuTugas),
                      ],
                    ),
            ),
    );
  }
}
