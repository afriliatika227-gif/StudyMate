
import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../services/notification_service.dart';
import 'tambah_tugas_screen.dart';

class TugasScreen extends StatefulWidget {
  const TugasScreen({super.key});

  @override
  State<TugasScreen> createState() => _TugasScreenState();
}

class _TugasScreenState extends State<TugasScreen> {
  final DatabaseHelper _db = DatabaseHelper.instance;

  List<Map<String, String>> tugas = [];
  bool _sedangMemuat = true;
  bool _sedangMenyimpan = false;

  @override
  void initState() {
    super.initState();
    _inisialisasi();
  }

  Future<void> _inisialisasi() async {
    try {
      await NotificationService.initialize();
    } catch (e) {
      debugPrint('Gagal menginisialisasi notifikasi: $e');
    }

    await _muatTugas();
  }

  Future<void> _muatTugas() async {
    try {
      final dataDatabase = await _db.getTasks();

      final dataTugas = dataDatabase.map((item) {
        return <String, String>{
          'id': '${item['task_id']}',
          'judul': '${item['title'] ?? ''}',
          'mataKuliah': '${item['course_name'] ?? ''}',
          'deadline': '${item['deadline'] ?? ''}',
          'waktuDeadline': '${item['deadline_time'] ?? '23:59'}',
          'deskripsi': '${item['description'] ?? ''}',
          'status': '${item['status'] ?? 'Belum Dikerjakan'}',
        };
      }).toList();

      if (!mounted) return;

      setState(() {
        tugas = dataTugas;
        _sedangMemuat = false;
      });

      await _jadwalkanSemuaPengingat();
    } catch (e) {
      debugPrint('Gagal memuat daftar tugas: $e');

      if (!mounted) return;

      setState(() {
        _sedangMemuat = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal memuat tugas dari database.'),
        ),
      );
    }
  }

  Future<void> _jadwalkanSemuaPengingat() async {
    for (final item in tugas) {
      await _aturPengingat(item);
    }
  }

  DateTime? _tanggalDanWaktu(Map<String, String> item) {
    try {
      final bagian = (item['deadline'] ?? '').split(' ');
      if (bagian.length != 3) return null;

      final hari = int.parse(bagian[0]);
      final tahun = int.parse(bagian[2]);

      const bulanIndonesia = {
        'Januari': 1,
        'Februari': 2,
        'Maret': 3,
        'April': 4,
        'Mei': 5,
        'Juni': 6,
        'Juli': 7,
        'Agustus': 8,
        'September': 9,
        'Oktober': 10,
        'November': 11,
        'Desember': 12,
      };

      final bulan = bulanIndonesia[bagian[1]];
      if (bulan == null) return null;

      final waktu = (item['waktuDeadline'] ?? '23:59').split(':');
      if (waktu.length != 2) return null;

      final jam = int.parse(waktu[0]);
      final menit = int.parse(waktu[1]);

      if (jam < 0 || jam > 23 || menit < 0 || menit > 59) {
        return null;
      }

      final hasil = DateTime(tahun, bulan, hari, jam, menit);

      if (hasil.year != tahun ||
          hasil.month != bulan ||
          hasil.day != hari) {
        return null;
      }

      return hasil;
    } catch (_) {
      return null;
    }
  }

  Map<String, String> _gabungkanData(
    Map<String, String> dataLama,
    dynamic hasil,
  ) {
    final dataBaru = Map<String, String>.from(dataLama);

    if (hasil is Map) {
      for (final key in [
        'judul',
        'mataKuliah',
        'deadline',
        'waktuDeadline',
        'deskripsi',
        'status',
      ]) {
        if (hasil[key] != null) {
          dataBaru[key] = hasil[key].toString();
        }
      }
    }

    return dataBaru;
  }

  Future<void> _aturPengingat(Map<String, String> item) async {
    try {
      final id = int.tryParse(item['id'] ?? '');
      if (id == null) return;

      await NotificationService.cancelTaskReminders(id);

      if (item['status'] == 'Selesai') return;

      final deadline = _tanggalDanWaktu(item);

      if (deadline == null || !deadline.isAfter(DateTime.now())) {
        return;
      }

      await NotificationService.scheduleTaskReminders(
        taskId: id,
        title: item['judul'] ?? 'Tugas StudyMate',
        deadline: deadline,
      );
    } catch (e) {
      debugPrint('Gagal mengatur pengingat: $e');
    }
  }

  Future<void> _tambahTugas() async {
    if (_sedangMenyimpan) return;

    final hasil = await Navigator.push<dynamic>(
      context,
      MaterialPageRoute(
        builder: (_) => const TambahTugasScreen(),
      ),
    );

    if (!mounted || hasil == null) return;

    final dataBaru = _gabungkanData(
      {
        'id': '',
        'judul': '',
        'mataKuliah': '',
        'deadline': '',
        'waktuDeadline': '23:59',
        'deskripsi': '',
        'status': 'Belum Dikerjakan',
      },
      hasil,
    );

    if (dataBaru['judul']!.trim().isEmpty ||
        dataBaru['mataKuliah']!.trim().isEmpty ||
        dataBaru['deadline']!.trim().isEmpty) {
      _pesan('Lengkapi judul, mata kuliah, dan deadline.');
      return;
    }

    setState(() {
      _sedangMenyimpan = true;
    });

    try {
      // Pastikan mata kuliah tersedia di database.
      final daftarMataKuliah = await _db.getCourses();
      final namaMataKuliah = dataBaru['mataKuliah']!.trim();

      final mataKuliahAda = daftarMataKuliah.any(
        (item) =>
            '${item['course_name']}'.trim() == namaMataKuliah,
      );

      if (!mataKuliahAda) {
        _pesan(
          'Mata kuliah "$namaMataKuliah" tidak ditemukan. '
          'Periksa daftar mata kuliah di database.',
        );
        return;
      }

      final id = await _db.insertTask(
        courseName: namaMataKuliah,
        title: dataBaru['judul']!.trim(),
        description: dataBaru['deskripsi'] ?? '',
        deadline: dataBaru['deadline']!,
        deadlineTime: dataBaru['waktuDeadline'] ?? '23:59',
        status: dataBaru['status']!,
      );

      dataBaru['id'] = id.toString();

      await _muatTugas();

      if (!mounted) return;

      await _aturPengingat(dataBaru);

      if (!mounted) return;

      _pesan('Tugas berhasil disimpan.');
    } catch (e) {
      debugPrint('Gagal menambahkan tugas: $e');

      if (mounted) {
        _pesan('Gagal menyimpan tugas: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _sedangMenyimpan = false;
        });
      }
    }
  }

  Future<void> _editTugas(int index) async {
    if (index < 0 || index >= tugas.length) return;

    final dataLama = Map<String, String>.from(tugas[index]);

    final hasil = await Navigator.push<dynamic>(
      context,
      MaterialPageRoute(
        builder: (_) => TambahTugasScreen(dataEdit: dataLama),
      ),
    );

    if (!mounted || hasil == null) return;

    final dataBaru = _gabungkanData(dataLama, hasil);
    final id = int.tryParse(dataLama['id'] ?? '');

    if (id == null) return;

    try {
      final daftarMataKuliah = await _db.getCourses();
      final namaMataKuliah = dataBaru['mataKuliah']!.trim();

      final mataKuliahAda = daftarMataKuliah.any(
        (item) =>
            '${item['course_name']}'.trim() == namaMataKuliah,
      );

      if (!mataKuliahAda) {
        _pesan('Mata kuliah tidak ditemukan di database.');
        return;
      }

      await _db.updateTask(
        taskId: id,
        courseName: namaMataKuliah,
        title: dataBaru['judul']!.trim(),
        description: dataBaru['deskripsi'] ?? '',
        deadline: dataBaru['deadline']!,
        deadlineTime: dataBaru['waktuDeadline'] ?? '23:59',
        status: dataBaru['status']!,
      );

      await _muatTugas();

      if (!mounted) return;

      await _aturPengingat(dataBaru);

      if (!mounted) return;

      _pesan('Tugas berhasil diperbarui.');
    } catch (e) {
      debugPrint('Gagal memperbarui tugas: $e');

      if (mounted) {
        _pesan('Gagal memperbarui tugas: $e');
      }
    }
  }

  Future<void> _ubahStatus(int index) async {
    if (index < 0 || index >= tugas.length) return;

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Ubah Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _statusOption(dialogContext, index, 'Belum Dikerjakan'),
            _statusOption(dialogContext, index, 'Sedang Dikerjakan'),
            _statusOption(dialogContext, index, 'Selesai'),
          ],
        ),
      ),
    );
  }

  Widget _statusOption(
    BuildContext dialogContext,
    int index,
    String statusBaru,
  ) {
    return ListTile(
      title: Text(statusBaru),
      onTap: () async {
        final item = Map<String, String>.from(tugas[index]);
        final id = int.tryParse(item['id'] ?? '');

        Navigator.pop(dialogContext);

        if (id == null) return;

        try {
          await _db.updateTaskStatus(id, statusBaru);
          await _muatTugas();

          if (!mounted) return;

          await _aturPengingat({
            ...item,
            'status': statusBaru,
          });

          if (!mounted) return;

          _pesan('Status diubah menjadi $statusBaru.');
        } catch (e) {
          debugPrint('Gagal mengubah status tugas: $e');

          if (mounted) {
            _pesan('Gagal mengubah status tugas: $e');
          }
        }
      },
    );
  }

  Future<void> _hapusTugas(int index) async {
    if (index < 0 || index >= tugas.length) return;

    final item = Map<String, String>.from(tugas[index]);

    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus Tugas?'),
        content: Text('Tugas "${item['judul']}" akan dihapus.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (konfirmasi != true || !mounted) return;

    final id = int.tryParse(item['id'] ?? '');
    if (id == null) return;

    try {
      await _db.deleteTask(id);
      await NotificationService.cancelTaskReminders(id);
      await _muatTugas();

      if (!mounted) return;

      _pesan('Tugas berhasil dihapus.');
    } catch (e) {
      debugPrint('Gagal menghapus tugas: $e');

      if (mounted) {
        _pesan('Gagal menghapus tugas: $e');
      }
    }
  }

  void _pesan(String pesan) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(pesan)),
      );
  }

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
      body: _sedangMemuat
          ? const Center(child: CircularProgressIndicator())
          : tugas.isEmpty
              ? const Center(child: Text('Belum ada tugas.'))
              : RefreshIndicator(
                  onRefresh: _muatTugas,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: tugas.length,
                    itemBuilder: (context, index) {
                      final item = tugas[index];

                      return _tugasCard(
                        index: index,
                        judul: item['judul'] ?? '',
                        mataKuliah: item['mataKuliah'] ?? '',
                        deadline: item['deadline'] ?? '',
                        waktuDeadline: item['waktuDeadline'] ?? '',
                        status: item['status'] ?? 'Belum Dikerjakan',
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab-tugas',
        onPressed: _sedangMenyimpan ? null : _tambahTugas,
        backgroundColor: const Color(0xFF6EA8FE),
        foregroundColor: Colors.white,
        icon: _sedangMenyimpan
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.add),
        label: Text(
          _sedangMenyimpan ? 'Menyimpan...' : 'Tambah Tugas',
        ),
      ),
    );
  }

  Widget _tugasCard({
    required int index,
    required String judul,
    required String mataKuliah,
    required String deadline,
    required String waktuDeadline,
    required String status,
  }) {
    final Color statusColor = status == 'Selesai'
        ? Colors.green
        : status == 'Sedang Dikerjakan'
            ? Colors.orange
            : Colors.redAccent;

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
        onTap: () => _detailTugas(index),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Deadline: $deadline'
                  '${waktuDeadline.isNotEmpty ? ' • $waktuDeadline' : ''}',
                  style: const TextStyle(fontSize: 12),
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
    if (index < 0 || index >= tugas.length) return;

    final item = Map<String, String>.from(tugas[index]);

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(
          'Detail Tugas',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                item['judul'] ?? '',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 18),
              _infoRow('Mata Kuliah', item['mataKuliah'] ?? ''),
              _infoRow('Tanggal', item['deadline'] ?? ''),
              _infoRow(
                'Waktu',
                (item['waktuDeadline'] ?? '').isNotEmpty
                    ? item['waktuDeadline']!
                    : 'Belum ditentukan',
              ),
              _infoRow(
                'Deskripsi',
                (item['deskripsi'] ?? '').isNotEmpty
                    ? item['deskripsi']!
                    : 'Tidak ada deskripsi',
              ),
              _infoRow('Status', item['status'] ?? ''),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Tutup'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _editTugas(index);
            },
            child: const Text('Edit'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _ubahStatus(index);
            },
            child: const Text('Ubah Status'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _hapusTugas(index);
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const Text(': '),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}