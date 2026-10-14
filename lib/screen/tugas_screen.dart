
import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../services/notification_service.dart';
import 'tambah_tugas_screen.dart';

const Color _biru = Color(0xFF6EA8FE);
const Color _biruTua = Color(0xFF3978D4);
const Color _biruMuda = Color(0xFFEAF3FF);
const Color _latar = Color(0xFFF6F9FF);
const Color _teks = Color(0xFF263750);
const Color _abu = Color(0xFF8794A8);

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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: const Text(
          'Ubah Status',
          style: TextStyle(
            color: _teks,
            fontWeight: FontWeight.bold,
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
        borderRadius: BorderRadius.circular(14),
      ),
      leading: Icon(Icons.circle, color: warna, size: 12),
      title: Text(
        statusBaru,
        style: const TextStyle(fontSize: 14),
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: const Text(
          'Hapus Tugas?',
          style: TextStyle(
            color: _teks,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text('Tugas "${item['judul']}" akan dihapus.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
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
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
  }

  Color _warnaStatus(String status) {
    switch (status) {
      case 'Selesai':
        return const Color(0xFF36A875);
      case 'Sedang Dikerjakan':
        return const Color(0xFFEF9D42);
      default:
        return const Color(0xFFE46F83);
    }
  }

  List<Map<String, String>> get _tugasTerfilter {
    return tugas.where((item) {
      final statusSesuai =
          _filterStatus == 'Semua' ||
          item['status'] == _filterStatus;

      final query = _kataKunci.trim().toLowerCase();
      final judul = (item['judul'] ?? '').toLowerCase();
      final matkul = (item['mataKuliah'] ?? '').toLowerCase();

      final kataSesuai =
          query.isEmpty ||
          judul.contains(query) ||
          matkul.contains(query);

      return statusSesuai && kataSesuai;
    }).toList();
  }

  int get _jumlahSelesai =>
      tugas.where((item) => item['status'] == 'Selesai').length;

  int get _jumlahProses =>
      tugas.where((item) => item['status'] == 'Sedang Dikerjakan').length;

  int get _jumlahBelum =>
      tugas.where((item) => item['status'] != 'Selesai').length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _latar,
      appBar: AppBar(
        backgroundColor: _latar,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Daftar Tugas',
          style: TextStyle(
            color: _teks,
            fontWeight: FontWeight.w800,
            fontSize: 23,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 18),
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.assignment_outlined,
              color: _biruTua,
            ),
          ),
        ],
      ),
      body: _sedangMemuat
          ? const Center(
              child: CircularProgressIndicator(color: _biru),
            )
          : RefreshIndicator(
              color: _biruTua,
              onRefresh: _muatTugas,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
                children: [
                  _headerTugas(),
                  const SizedBox(height: 20),
                  _ringkasanTugas(),
                  const SizedBox(height: 25),
                  const Text(
                    'Tugas Kuliah',
                    style: TextStyle(
                      color: _teks,
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _kolomPencarian(),
                  const SizedBox(height: 14),
                  _filterTugas(),
                  const SizedBox(height: 18),
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
        backgroundColor: _biruTua,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: _sedangMenyimpan
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.add_rounded),
        label: Text(
          _sedangMenyimpan ? 'Menyimpan...' : 'Tambah Tugas',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _headerTugas() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF83B7FF),
            Color(0xFF5B96F0),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: _biru.withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 8),
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
                  'Belajar Lebih Teratur ✨',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  tugas.isEmpty
                      ? 'Yuk, tambahkan tugas pertamamu!'
                      : 'Selesaikan satu per satu, kamu pasti bisa.',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${tugas.length} tugas tercatat',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 74,
            height: 82,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.19),
              borderRadius: BorderRadius.circular(23),
            ),
            child: const Icon(
              Icons.menu_book_rounded,
              color: Colors.white,
              size: 43,
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
            icon: Icons.pending_actions_rounded,
            warna: const Color(0xFFE6A34D),
            latar: const Color(0xFFFFF4E5),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _kartuRingkasan(
            label: 'Dikerjakan',
            jumlah: _jumlahProses,
            icon: Icons.autorenew_rounded,
            warna: _biruTua,
            latar: _biruMuda,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _kartuRingkasan(
            label: 'Selesai',
            jumlah: _jumlahSelesai,
            icon: Icons.check_circle_outline_rounded,
            warna: const Color(0xFF36A875),
            latar: const Color(0xFFE7F8EF),
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
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 15,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFECF1F8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              color: latar,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: warna, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            '$jumlah',
            style: const TextStyle(
              color: _teks,
              fontSize: 23,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            maxLines: 2,
            style: const TextStyle(
              color: _abu,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
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
          color: _abu,
          fontSize: 13,
        ),
        prefixIcon: const Icon(
          Icons.search_rounded,
          color: _biruTua,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: const BorderSide(color: Color(0xFFECF1F8)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: const BorderSide(color: Color(0xFFECF1F8)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: const BorderSide(color: _biru, width: 1.5),
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
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(pilihanStatus),
              selected: terpilih,
              showCheckmark: false,
              labelStyle: TextStyle(
                color: terpilih ? Colors.white : _abu,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
              backgroundColor: Colors.white,
              selectedColor: _biruTua,
              side: BorderSide(
                color: terpilih
                    ? _biruTua
                    : const Color(0xFFECF1F8),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
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
    final bool adaFilter =
        _kataKunci.isNotEmpty || _filterStatus != 'Semua';

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 35,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFECF1F8)),
      ),
      child: Column(
        children: [
          Container(
            width: 82,
            height: 82,
            decoration: const BoxDecoration(
              color: _biruMuda,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.assignment_turned_in_outlined,
              color: _biruTua,
              size: 40,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            adaFilter ? 'Tugas tidak ditemukan' : 'Belum ada tugas',
            style: const TextStyle(
              color: _teks,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            adaFilter
                ? 'Coba kata kunci atau status lainnya.'
                : 'Tambahkan tugas kuliahmu agar tidak ada deadline yang terlewat.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _abu,
              fontSize: 12,
              height: 1.6,
            ),
          ),
          if (!adaFilter) ...[
            const SizedBox(height: 18),
            OutlinedButton.icon(
              onPressed: _tambahTugas,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Tambah Tugas Pertama'),
              style: OutlinedButton.styleFrom(
                foregroundColor: _biruTua,
                side: const BorderSide(color: _biru),
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
    final deadlineDate = _tanggalDanWaktu(tugas[index]);
    final terlambat = status != 'Selesai' &&
        deadlineDate != null &&
        deadlineDate.isBefore(DateTime.now());

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: terlambat
              ? const Color(0xFFF3C7CD)
              : const Color(0xFFECF1F8),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF355078).withValues(alpha: 0.045),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () => _detailTugas(index),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 49,
                    height: 49,
                    decoration: BoxDecoration(
                      color: _biruMuda,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(
                      Icons.assignment_rounded,
                      color: _biruTua,
                      size: 25,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          judul,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _teks,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(
                              Icons.menu_book_rounded,
                              color: _abu,
                              size: 14,
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                mataKuliah,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: _abu,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 5),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: _abu,
                    size: 22,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 11,
                ),
                decoration: BoxDecoration(
                  color: terlambat
                      ? const Color(0xFFFFEEEE)
                      : const Color(0xFFF5F8FD),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Icon(
                      terlambat
                          ? Icons.warning_amber_rounded
                          : Icons.calendar_month_rounded,
                      size: 18,
                      color: terlambat
                          ? Colors.redAccent
                          : _biruTua,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            terlambat ? 'Deadline terlewat' : 'Deadline',
                            style: TextStyle(
                              color: terlambat
                                  ? Colors.redAccent
                                  : _abu,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '$deadline'
                            '${waktuDeadline.isNotEmpty ? ' • $waktuDeadline' : ''}',
                            style: TextStyle(
                              color: terlambat
                                  ? Colors.redAccent
                                  : _teks,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 13),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: warna,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      status,
                      style: TextStyle(
                        color: warna,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Text(
                    'Lihat detail',
                    style: TextStyle(
                      color: _biruTua.withValues(alpha: 0.9),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
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
    final warna = _warnaStatus(item['status'] ?? '');

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: const Row(
          children: [
            Icon(Icons.assignment_rounded, color: _biruTua),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Detail Tugas',
                style: TextStyle(
                  color: _teks,
                  fontWeight: FontWeight.w800,
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
                  color: _teks,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: warna.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  item['status'] ?? '',
                  style: TextStyle(
                    color: warna,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
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
            child: const Text('Status'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _biruTua,
              foregroundColor: Colors.white,
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
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 85,
            child: Text(
              title,
              style: const TextStyle(
                color: _abu,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Text(': '),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: _teks,
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
