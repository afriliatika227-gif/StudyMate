
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

  static const Color _biruUtama = Color(0xFF6B9BD2);
  static const Color _biruTua = Color(0xFF34577D);
  static const Color _biruMuda = Color(0xFFEAF3FF);
  static const Color _background = Color(0xFFF5F8FE);

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
        return const Color(0xFF55A98A);
      case 'Sedang Dikerjakan':
        return _biruUtama;
      default:
        return const Color(0xFFD69A50);
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFE7F1FF),
            Color(0xFFF3F7FF),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFDCEAFF),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              _ikonStatus(),
              color: warna,
              size: 30,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _judulStatus(),
                  style: const TextStyle(
                    color: _biruTua,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Pantau perkembangan tugas kuliahmu',
                  style: TextStyle(
                    color: Color(0xFF8295AD),
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
            fontWeight: FontWeight.w800,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: _biruMuda,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${_daftarTugas.length} Tugas',
            style: const TextStyle(
              color: _biruTua,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildKartuTugas(Map<String, dynamic> item) {
    final warna = _warnaStatus();

    return Container(
      margin: const EdgeInsets.only(bottom: 13),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE8EFF8),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7899C0).withValues(alpha: 0.07),
            blurRadius: 12,
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
              color: _biruMuda,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.assignment_rounded,
              color: warna,
              size: 24,
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
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.menu_book_rounded,
                      color: Color(0xFF9AAEC5),
                      size: 15,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        '${item['course_name'] ?? 'Mata kuliah'}',
                        style: const TextStyle(
                          color: Color(0xFF8999AD),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: _biruMuda,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    widget.status,
                    style: const TextStyle(
                      color: _biruTua,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (widget.status == 'Selesai')
            const Icon(
              Icons.check_circle_rounded,
              color: Color(0xFF55A98A),
              size: 23,
            ),
        ],
      ),
    );
  }

  Widget _buildKosong() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 105,
              height: 105,
              decoration: BoxDecoration(
                color: _biruMuda,
                borderRadius: BorderRadius.circular(32),
              ),
              child: Icon(
                _ikonStatus(),
                color: _biruUtama,
                size: 48,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Belum Ada Tugas',
              style: const TextStyle(
                color: _biruTua,
                fontSize: 19,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Belum ada tugas ${widget.status.toLowerCase()}.\n'
              'Yuk, tetap semangat mengatur aktivitas kuliahmu!',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF8999AD),
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
        backgroundColor: _background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        title: const Text(
          'Daftar Tugas',
          style: TextStyle(
            color: _biruTua,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        iconTheme: const IconThemeData(
          color: _biruTua,
        ),
      ),
      body: _sedangMemuat
          ? const Center(
              child: CircularProgressIndicator(
                color: _biruUtama,
              ),
            )
          : RefreshIndicator(
              color: _biruUtama,
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
                        20, 10, 20, 25,
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
