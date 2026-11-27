
import 'package:flutter/material.dart';
import '../database/database_helper.dart';

const Color _plum = Color(0xFF66527F);
const Color _darkPlum = Color(0xFF423650);
const Color _lavender = Color(0xFFF3EFF8);
const Color _pink = Color(0xFFD7799E);
const Color _background = Color(0xFFFAF8FC);
const Color _line = Color(0xFFEAE5EF);
const Color _muted = Color(0xFF8B8494);

class TambahTugasScreen extends StatefulWidget {
  final Map<String, String>? dataEdit;

  const TambahTugasScreen({
    super.key,
    this.dataEdit,
  });

  @override
  State<TambahTugasScreen> createState() =>
      _TambahTugasScreenState();
}

class _TambahTugasScreenState extends State<TambahTugasScreen> {
  final DatabaseHelper _db = DatabaseHelper.instance;

  final TextEditingController judulController =
      TextEditingController();
  final TextEditingController deskripsiController =
      TextEditingController();

  List<Map<String, dynamic>> daftarMataKuliah = [];
  String? mataKuliah;
  DateTime? tanggalDeadline;
  TimeOfDay? waktuDeadline;
  String status = 'Belum Dikerjakan';

  bool sedangMemuatMataKuliah = true;
  bool sedangMenyimpan = false;
  String? pesanErrorMataKuliah;

  bool get sedangEdit => widget.dataEdit != null;

  @override
  void initState() {
    super.initState();

    final data = widget.dataEdit;
    if (data != null) {
      judulController.text = data['judul'] ?? '';
      deskripsiController.text = data['deskripsi'] ?? '';
      mataKuliah = data['mataKuliah'];
      status = data['status'] ?? 'Belum Dikerjakan';

      final deadline = data['deadline'];
      if (deadline != null && deadline.isNotEmpty) {
        tanggalDeadline = _parseTanggal(deadline);
      }

      final jam = data['waktuDeadline'] ?? data['jamDeadline'];
      if (jam != null) {
        waktuDeadline = _parseWaktu(jam);
      }
    }

    _muatMataKuliah();
  }

  Future<void> _muatMataKuliah() async {
    try {
      final hasil = await _db.getCourses();

      if (!mounted) return;

      setState(() {
        daftarMataKuliah = hasil;
        sedangMemuatMataKuliah = false;
        pesanErrorMataKuliah = null;

        final tersedia = daftarMataKuliah.any(
          (item) =>
              '${item['course_name']}'.trim() ==
              (mataKuliah ?? '').trim(),
        );

        if (!tersedia) {
          mataKuliah = null;
        }
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        sedangMemuatMataKuliah = false;
        pesanErrorMataKuliah =
            'Gagal memuat mata kuliah. Silakan coba lagi.';
      });
    }
  }

  @override
  void dispose() {
    judulController.dispose();
    deskripsiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pilihanMataKuliah = daftarMataKuliah
        .map((item) => '${item['course_name']}'.trim())
        .where((nama) => nama.isNotEmpty)
        .toSet()
        .toList();

    final mataKuliahTerpilih =
        pilihanMataKuliah.contains(mataKuliah)
            ? mataKuliah
            : null;

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        title: Text(
          sedangEdit ? 'Edit Tugas' : 'Tambah Tugas',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: _darkPlum,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: _darkPlum,
        elevation: 0,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(
            height: 1,
            color: _line,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _headerTugas(),

              const SizedBox(height: 24),

              _labelBagian('Informasi Tugas'),
              const SizedBox(height: 15),

              _label('Judul Tugas'),
              const SizedBox(height: 8),
              TextField(
                controller: judulController,
                textInputAction: TextInputAction.next,
                decoration: _inputDecoration(
                  'Masukkan judul tugas',
                  Icons.assignment_outlined,
                ),
              ),

              const SizedBox(height: 20),
              _label('Mata Kuliah'),
              const SizedBox(height: 8),

              DropdownButtonFormField<String>(
                isExpanded: true,
                initialValue: mataKuliahTerpilih,
                decoration: _inputDecoration(
                  'Pilih mata kuliah',
                  Icons.menu_book_outlined,
                ),
                items: pilihanMataKuliah.map((nama) {
                  return DropdownMenuItem<String>(
                    value: nama,
                    child: Text(
                      nama,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged:
                    sedangMemuatMataKuliah ||
                            pesanErrorMataKuliah != null
                        ? null
                        : (value) {
                            setState(() {
                              mataKuliah = value;
                            });
                          },
              ),

              if (sedangMemuatMataKuliah) ...[
                const SizedBox(height: 8),
                const Text(
                  'Memuat daftar mata kuliah...',
                  style: TextStyle(
                    color: _muted,
                    fontSize: 12,
                  ),
                ),
              ],

              if (pesanErrorMataKuliah != null) ...[
                const SizedBox(height: 8),
                Text(
                  pesanErrorMataKuliah!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      sedangMemuatMataKuliah = true;
                    });
                    _muatMataKuliah();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Coba lagi'),
                  style: TextButton.styleFrom(
                    foregroundColor: _plum,
                  ),
                ),
              ],

              if (!sedangMemuatMataKuliah &&
                  pesanErrorMataKuliah == null &&
                  pilihanMataKuliah.isEmpty) ...[
                const SizedBox(height: 8),
                const Text(
                  'Belum ada mata kuliah. Tambahkan mata kuliah '
                  'terlebih dahulu.',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                  ),
                ),
              ],

              const SizedBox(height: 20),
              _label('Deskripsi'),
              const SizedBox(height: 8),
              TextField(
                controller: deskripsiController,
                maxLines: 4,
                decoration: _inputDecoration(
                  'Masukkan deskripsi tugas',
                  Icons.description_outlined,
                ),
              ),

              const SizedBox(height: 25),
              _labelBagian('Waktu Pengumpulan'),
              const SizedBox(height: 15),

              _label('Deadline'),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: _dateButton()),
                  const SizedBox(width: 12),
                  Expanded(child: _timeButton()),
                ],
              ),

              const SizedBox(height: 25),
              _labelBagian('Status Pengerjaan'),
              const SizedBox(height: 15),

              _label('Status'),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                isExpanded: true,
                initialValue: const [
                  'Belum Dikerjakan',
                  'Sedang Dikerjakan',
                  'Selesai',
                ].contains(status)
                    ? status
                    : 'Belum Dikerjakan',
                decoration: _inputDecoration(
                  'Pilih status',
                  Icons.check_circle_outline,
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'Belum Dikerjakan',
                    child: Text('Belum Dikerjakan'),
                  ),
                  DropdownMenuItem(
                    value: 'Sedang Dikerjakan',
                    child: Text('Sedang Dikerjakan'),
                  ),
                  DropdownMenuItem(
                    value: 'Selesai',
                    child: Text('Selesai'),
                  ),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    status = value;
                  });
                },
              ),

              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: sedangMenyimpan
                      ? null
                      : _simpanTugas,
                  icon: sedangMenyimpan
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(
                    sedangMenyimpan
                        ? 'Menyimpan...'
                        : sedangEdit
                            ? 'Simpan Perubahan'
                            : 'Simpan Tugas',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _plum,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }

  Widget _headerTugas() {
    return Container(
      height: 165,
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [_plum, _darkPlum],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            'https://images.unsplash.com/photo-1455390582262-044cdead277a?w=900',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: _plum,
                alignment: Alignment.centerRight,
                child: const Icon(
                  Icons.menu_book_rounded,
                  color: Colors.white24,
                  size: 75,
                ),
              );
            },
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _darkPlum.withOpacity(0.94),
                  _darkPlum.withOpacity(0.65),
                  _darkPlum.withOpacity(0.2),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'STUDYMATE • ACADEMIC PLANNER',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 9,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 13),
                Text(
                  sedangEdit ? 'Edit Tugasmu' : 'Catat Tugasmu',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 7),
                const SizedBox(
                  width: 230,
                  child: Text(
                    'Kelola aktivitas akademikmu dan selesaikan setiap tugas tepat waktu.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _labelBagian(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: _darkPlum,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: _darkPlum,
      ),
    );
  }

  InputDecoration _inputDecoration(
    String hint,
    IconData icon,
  ) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: _muted,
        fontSize: 12,
      ),
      prefixIcon: Icon(
        icon,
        color: _plum,
        size: 19,
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 15,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: _plum,
          width: 1.3,
        ),
      ),
    );
  }

  Widget _dateButton() {
    return InkWell(
      onTap: _pilihTanggal,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 16,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _line),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              color: _plum,
              size: 19,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                tanggalDeadline == null
                    ? 'Tanggal'
                    : '${tanggalDeadline!.day}/'
                        '${tanggalDeadline!.month}/'
                        '${tanggalDeadline!.year}',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: tanggalDeadline == null
                      ? _muted
                      : _darkPlum,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _timeButton() {
    return InkWell(
      onTap: _pilihWaktu,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 16,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _line),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.access_time_outlined,
              color: _pink,
              size: 19,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                waktuDeadline == null
                    ? 'Waktu'
                    : waktuDeadline!.format(context),
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: waktuDeadline == null
                      ? _muted
                      : _darkPlum,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pilihTanggal() async {
    final sekarang = DateTime.now();
    final hariIni = DateTime(
      sekarang.year,
      sekarang.month,
      sekarang.day,
    );

    final tanggalAwal = tanggalDeadline ?? hariIni;
    final tanggalValid = tanggalAwal.isBefore(hariIni)
        ? hariIni
        : tanggalAwal;

    final tanggal = await showDatePicker(
      context: context,
      initialDate: tanggalValid,
      firstDate: hariIni,
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: _plum,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: _darkPlum,
            ),
          ),
          child: child!,
        );
      },
    );

    if (!mounted || tanggal == null) return;

    setState(() {
      tanggalDeadline = tanggal;
    });
  }

  Future<void> _pilihWaktu() async {
    final waktu = await showTimePicker(
      context: context,
      initialTime: waktuDeadline ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: _plum,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: _darkPlum,
            ),
          ),
          child: child!,
        );
      },
    );

    if (!mounted || waktu == null) return;

    setState(() {
      waktuDeadline = waktu;
    });
  }

  Future<void> _simpanTugas() async {
    if (sedangMemuatMataKuliah) {
      _pesan('Tunggu sampai daftar mata kuliah selesai dimuat.');
      return;
    }

    if (pesanErrorMataKuliah != null) {
      _pesan('Muat ulang daftar mata kuliah terlebih dahulu.');
      return;
    }

    if (judulController.text.trim().isEmpty ||
        mataKuliah == null ||
        tanggalDeadline == null ||
        waktuDeadline == null) {
      _pesan(
        'Mohon lengkapi judul, mata kuliah, tanggal, '
        'dan waktu deadline.',
      );
      return;
    }

    final tersedia = daftarMataKuliah.any(
      (item) =>
          '${item['course_name']}'.trim() == mataKuliah,
    );

    if (!tersedia) {
      _pesan(
        'Mata kuliah tidak ditemukan. Silakan pilih ulang.',
      );
      return;
    }

    setState(() {
      sedangMenyimpan = true;
    });

    final tanggal = '${tanggalDeadline!.day} '
        '${_namaBulan(tanggalDeadline!.month)} '
        '${tanggalDeadline!.year}';

    final jam =
        '${waktuDeadline!.hour.toString().padLeft(2, '0')}:'
        '${waktuDeadline!.minute.toString().padLeft(2, '0')}';

    if (!mounted) return;

    setState(() {
      sedangMenyimpan = false;
    });

    Navigator.pop(
      context,
      {
        'judul': judulController.text.trim(),
        'mataKuliah': mataKuliah!,
        'deadline': tanggal,
        'waktuDeadline': jam,
        'status': status,
        'deskripsi': deskripsiController.text.trim(),
      },
    );
  }

  void _pesan(String pesan) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(pesan),
        behavior: SnackBarBehavior.floating,
        backgroundColor: _darkPlum,
      ),
    );
  }

  DateTime? _parseTanggal(String tanggal) {
    try {
      final bagian = tanggal.split(' ');
      if (bagian.length != 3) return null;

      final hari = int.parse(bagian[0]);

      const namaBulan = [
        'Januari',
        'Februari',
        'Maret',
        'April',
        'Mei',
        'Juni',
        'Juli',
        'Agustus',
        'September',
        'Oktober',
        'November',
        'Desember',
      ];

      final bulan = namaBulan.indexOf(bagian[1]) + 1;
      final tahun = int.parse(bagian[2]);

      if (bulan < 1 || hari < 1 || hari > 31) {
        return null;
      }

      final hasil = DateTime(tahun, bulan, hari);

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

  TimeOfDay? _parseWaktu(String waktu) {
    try {
      final bagian = waktu.split(':');
      if (bagian.length != 2) return null;

      final jam = int.parse(bagian[0]);
      final menit = int.parse(bagian[1]);

      if (jam < 0 ||
          jam > 23 ||
          menit < 0 ||
          menit > 59) {
        return null;
      }

      return TimeOfDay(hour: jam, minute: menit);
    } catch (_) {
      return null;
    }
  }

  String _namaBulan(int bulan) {
    const namaBulan = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];

    return namaBulan[bulan - 1];
  }
}