
import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../services/notification_service.dart';
import 'tambah_tugas_screen.dart';
import 'daftar_tugas_status_screen.dart';

const Color _blue = Color(0xFF3478C8);
const Color _darkBlue = Color(0xFF344054);
const Color _background = Color(0xFFF5F7FA);
const Color _line = Color(0xFFE4E8EF);
const Color _muted = Color(0xFF7C8798);

const Color _softBlue = Color(0xFFEAF2FC);
const Color _softPink = Color(0xFFFCECF2);
const Color _softMint = Color(0xFFE8F5EF);
const Color _softPeach = Color(0xFFFFF1E5);

const Color _pink = Color(0xFFD7799E);
const Color _green = Color(0xFF36A875);
const Color _orange = Color(0xFFE6A34D);
const Color _red = Color(0xFFD65353);

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

  String _filterStatus = 'Semua';
  String _kataKunci = '';

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

      _pesan('Gagal memuat tugas dari database.');
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
      final daftarMataKuliah = await _db.getCourses();
      final namaMataKuliah = dataBaru['mataKuliah']!.trim();

      final mataKuliahAda = daftarMataKuliah.any(
        (item) => '${item['course_name']}'.trim() == namaMataKuliah,
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
        (item) => '${item['course_name']}'.trim() == namaMataKuliah,
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
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(17),
        ),
        title: const Text(
          'Ubah Status Tugas',
          style: TextStyle(
            color: _darkBlue,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
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
    final warna = _warnaStatus(statusBaru);

    return ListTile(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      leading: Icon(
        Icons.circle,
        color: warna,
        size: 12,
      ),
      title: Text(
        statusBaru,
        style: const TextStyle(
          fontSize: 13,
          color: _darkBlue,
        ),
      ),
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
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(17),
        ),
        title: const Text(
          'Hapus Tugas?',
          style: TextStyle(
            color: _darkBlue,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Tugas "${item['judul']}" akan dihapus.',
          style: const TextStyle(
            color: _muted,
            fontSize: 13,
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
              backgroundColor: _red,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
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
        SnackBar(
          content: Text(pesan),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
  }

  Color _warnaStatus(String status) {
    switch (status) {
      case 'Selesai':
        return _green;
      case 'Sedang Dikerjakan':
        return _orange;
      default:
        return _pink;
    }
  }

  Color _latarStatus(String status) {
    switch (status) {
      case 'Selesai':
        return _softMint;
      case 'Sedang Dikerjakan':
        return _softPeach;
      default:
        return _softPink;
    }
  }

  List<Map<String, String>> get _tugasTerfilter {
    return tugas.where((item) {
      final statusSesuai =
          _filterStatus == 'Semua' || item['status'] == _filterStatus;

      final query = _kataKunci.trim().toLowerCase();
      final judul = (item['judul'] ?? '').toLowerCase();
      final matkul = (item['mataKuliah'] ?? '').toLowerCase();

      final kataSesuai =
          query.isEmpty || judul.contains(query) || matkul.contains(query);

      return statusSesuai && kataSesuai;
    }).toList();
  }

  int get _jumlahSelesai =>
      tugas.where((item) => item['status'] == 'Selesai').length;

  int get _jumlahProses =>
      tugas.where((item) => item['status'] == 'Sedang Dikerjakan').length;

  int get _jumlahBelum =>
      tugas.where((item) => item['status'] != 'Selesai').length;

  Future<void> _bukaDaftarStatus(String status) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DaftarTugasStatusScreen(status: status),
      ),
    );
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
        title: const Text(
          'Daftar Tugas',
          style: TextStyle(
            color: _darkBlue,
            fontWeight: FontWeight.w600,
            fontSize: 19,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 18),
            width: 39,
            height: 39,
            decoration: BoxDecoration(
              color: _softBlue,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.assignment_outlined,
              color: _blue,
              size: 21,
            ),
          ),
        ],
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
              child: CircularProgressIndicator(color: _blue),
            )
          : RefreshIndicator(
              color: _blue,
              onRefresh: _muatTugas,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 100),
                children: [
                  _headerTugas(),
                  const SizedBox(height: 22),
                  _ringkasanTugas(),
                  const SizedBox(height: 26),
                  const Text(
                    'Tugas Kuliah',
                    style: TextStyle(
                      color: _darkBlue,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 13),
                  _kolomPencarian(),
                  const SizedBox(height: 13),
                  _filterTugas(),
                  const SizedBox(height: 17),
                  if (_tugasTerfilter.isEmpty)
                    _tampilanKosong()
                  else
                    ..._tugasTerfilter.map((item) {
                      final index = tugas.indexOf(item);

                      return _tugasCard(
                        index: index,
                        judul: item['judul'] ?? '',
                        mataKuliah: item['mataKuliah'] ?? '',
                        deadline: item['deadline'] ?? '',
                        waktuDeadline: item['waktuDeadline'] ?? '',
                        status: item['status'] ?? 'Belum Dikerjakan',
                      );
                    }),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab-tugas',
        onPressed: _sedangMenyimpan ? null : _tambahTugas,
        backgroundColor: _blue,
        foregroundColor: Colors.white,
        elevation: 2,
        icon: _sedangMenyimpan
            ? const SizedBox(
                width: 19,
                height: 19,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.add_rounded),
        label: Text(
          _sedangMenyimpan ? 'Menyimpan...' : 'Tambah Tugas',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _headerTugas() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: _blue,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Kelola Tugas Kuliah',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  tugas.isEmpty
                      ? 'Mulai catat tugas dan deadline kuliahmu.'
                      : 'Atur tugasmu dan selesaikan satu per satu.',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 15),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.17),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${tugas.length} tugas tercatat',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.assignment_outlined,
              color: Colors.white,
              size: 29,
            ),
          ),
        ],
      ),
    );
  }

  Widget _ringkasanTugas() {
    return Row(
      children: [
        Expanded(
          child: _kartuRingkasan(
            label: 'Belum selesai',
            jumlah: _jumlahBelum,
            icon: Icons.pending_actions_outlined,
            warna: _orange,
            latar: _softPeach,
            onTap: () => _bukaDaftarStatus('Belum Dikerjakan'),
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: _kartuRingkasan(
            label: 'Dikerjakan',
            jumlah: _jumlahProses,
            icon: Icons.autorenew_rounded,
            warna: _blue,
            latar: _softBlue,
            onTap: () => _bukaDaftarStatus('Sedang Dikerjakan'),
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: _kartuRingkasan(
            label: 'Selesai',
            jumlah: _jumlahSelesai,
            icon: Icons.check_circle_outline_rounded,
            warna: _green,
            latar: _softMint,
            onTap: () => _bukaDaftarStatus('Selesai'),
          ),
        ),
      ],
    );
  }

  Widget _kartuRingkasan({
    required String label,
    required int jumlah,
    required IconData icon,
    required Color warna,
    required Color latar,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(13),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 13,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: _line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 33,
                height: 33,
                decoration: BoxDecoration(
                  color: latar,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(
                  icon,
                  color: warna,
                  size: 19,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '$jumlah',
                style: const TextStyle(
                  color: _darkBlue,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                label,
                maxLines: 2,
                style: const TextStyle(
                  color: _muted,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _kolomPencarian() {
    return TextField(
      onChanged: (value) {
        setState(() {
          _kataKunci = value;
        });
      },
      decoration: InputDecoration(
        hintText: 'Cari judul atau mata kuliah...',
        hintStyle: const TextStyle(
          color: _muted,
          fontSize: 12,
        ),
        prefixIcon: const Icon(
          Icons.search_rounded,
          color: _blue,
          size: 21,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(color: _line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(color: _line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(
            color: _blue,
            width: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _filterTugas() {
    const pilihan = [
      'Semua',
      'Belum Dikerjakan',
      'Sedang Dikerjakan',
      'Selesai',
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: pilihan.map((pilihanStatus) {
          final terpilih = _filterStatus == pilihanStatus;

          return Padding(
            padding: const EdgeInsets.only(right: 7),
            child: ChoiceChip(
              label: Text(pilihanStatus),
              selected: terpilih,
              showCheckmark: false,
              labelStyle: TextStyle(
                color: terpilih ? Colors.white : _muted,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
              backgroundColor: Colors.white,
              selectedColor: _blue,
              side: BorderSide(
                color: terpilih ? _blue : _line,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              onSelected: (_) {
                setState(() {
                  _filterStatus = pilihanStatus;
                });
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _tampilanKosong() {
    final adaFilter =
        _kataKunci.isNotEmpty || _filterStatus != 'Semua';

    return Container(
      margin: const EdgeInsets.only(top: 5),
      padding: const EdgeInsets.symmetric(
        horizontal: 22,
        vertical: 30,
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
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.assignment_outlined,
              color: _blue,
              size: 34,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            adaFilter ? 'Tugas tidak ditemukan' : 'Belum ada tugas',
            style: const TextStyle(
              color: _darkBlue,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            adaFilter
                ? 'Coba kata kunci atau status lainnya.'
                : 'Tambahkan tugas kuliahmu agar deadline tidak terlewat.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _muted,
              fontSize: 12,
              height: 1.5,
            ),
          ),
          if (!adaFilter) ...[
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _tambahTugas,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Tambah Tugas'),
              style: OutlinedButton.styleFrom(
                foregroundColor: _blue,
                side: const BorderSide(color: _blue),
              ),
            ),
          ],
        ],
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
    final warna = _warnaStatus(status);
    final latarStatus = _latarStatus(status);

    final deadlineDate = _tanggalDanWaktu(tugas[index]);

    final terlambat = status != 'Selesai' &&
        deadlineDate != null &&
        deadlineDate.isBefore(DateTime.now());

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: terlambat
              ? const Color(0xFFF0CCCC)
              : _line,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _detailTugas(index),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 43,
                      height: 43,
                      decoration: BoxDecoration(
                        color: _softBlue,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.assignment_outlined,
                        color: _blue,
                        size: 23,
                      ),
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            judul,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: _darkBlue,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              height: 1.35,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            mataKuliah,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: _muted,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: _muted,
                      size: 21,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                    color: terlambat
                        ? const Color(0xFFFFF0F0)
                        : _background,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        terlambat
                            ? Icons.warning_amber_rounded
                            : Icons.calendar_today_outlined,
                        size: 17,
                        color: terlambat ? _red : _blue,
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              terlambat ? 'Deadline terlewat' : 'Deadline',
                              style: TextStyle(
                                color: terlambat ? _red : _muted,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '$deadline'
                              '${waktuDeadline.isNotEmpty ? ' • $waktuDeadline' : ''}',
                              style: TextStyle(
                                color: terlambat ? _red : _darkBlue,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: latarStatus,
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: warna,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            status,
                            style: TextStyle(
                              color: warna,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    const Text(
                      'Lihat detail',
                      style: TextStyle(
                        color: _blue,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _detailTugas(int index) {
    if (index < 0 || index >= tugas.length) return;

    final item = Map<String, String>.from(tugas[index]);
    final warna = _warnaStatus(item['status'] ?? '');
    final latarStatus = _latarStatus(item['status'] ?? '');

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(17),
        ),
        title: const Row(
          children: [
            Icon(
              Icons.assignment_outlined,
              color: _blue,
              size: 22,
            ),
            SizedBox(width: 9),
            Expanded(
              child: Text(
                'Detail Tugas',
                style: TextStyle(
                  color: _darkBlue,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                item['judul'] ?? '',
                style: const TextStyle(
                  color: _darkBlue,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 13),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: latarStatus,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Text(
                  item['status'] ?? '',
                  style: TextStyle(
                    color: warna,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
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
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              'Tutup',
              style: TextStyle(color: _muted),
            ),
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
            child: const Text('Status'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: _blue,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
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
      padding: const EdgeInsets.only(bottom: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 82,
            child: Text(
              title,
              style: const TextStyle(
                color: _muted,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Text(
            ': ',
            style: TextStyle(
              color: _muted,
              fontSize: 11,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: _darkBlue,
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}