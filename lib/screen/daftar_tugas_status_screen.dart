
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
        return const Color(0xFF36A875);
      case 'Sedang Dikerjakan':
        return const Color(0xFF3978D4);
      default:
        return const Color(0xFFE6A34D);
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

  @override
  Widget build(BuildContext context) {
    final warna = _warnaStatus();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F9FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F9FF),
        elevation: 0,
        title: Text(
          'Daftar Tugas ${widget.status}',
          style: const TextStyle(
            color: Color(0xFF263750),
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Color(0xFF263750),
        ),
      ),
      body: _sedangMemuat
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _daftarTugas.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _ikonStatus(),
                        size: 65,
                        color: warna,
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Belum ada tugas ${widget.status.toLowerCase()}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF8794A8),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _muatTugas,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: _daftarTugas.length,
                    itemBuilder: (context, index) {
                      final item = _daftarTugas[index];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFFECF1F8),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _ikonStatus(),
                              color: warna,
                              size: 28,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${item['title'] ?? ''}',
                                    style: const TextStyle(
                                      color: Color(0xFF263750),
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    '${item['course_name'] ?? ''}',
                                    style: const TextStyle(
                                      color: Color(0xFF8794A8),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (widget.status == 'Selesai')
                              const Icon(
                                Icons.check_circle,
                                color: Color(0xFF36A875),
                                size: 24,
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
