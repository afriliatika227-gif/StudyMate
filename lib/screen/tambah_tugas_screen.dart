
import 'package:flutter/material.dart';
import '../database/database_helper.dart';

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

        // Pastikan mata kuliah yang dipilih masih ada di database.
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
      backgroundColor: const Color(0xFFF8FAFD),
      appBar: AppBar(
        title: Text(
          sedangEdit ? 'Edit Tugas' : 'Tambah Tugas',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                    color: Colors.grey,
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

              const SizedBox(height: 20),
              _label('Deadline'),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: _dateButton()),
                  const SizedBox(width: 12),
                  Expanded(child: _timeButton()),
                ],
              ),

              const SizedBox(height: 20),
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
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6EA8FE),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
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

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  InputDecoration _inputDecoration(
    String hint,
    IconData icon,
  ) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(
        icon,
        color: const Color(0xFF6EA8FE),
      ),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: Colors.grey.shade200,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xFF6EA8FE),
        ),
      ),
    );
  }

  Widget _dateButton() {
    return InkWell(
      onTap: _pilihTanggal,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 16,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.grey.shade200,
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              color: Color(0xFF6EA8FE),
              size: 20,
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
                      ? Colors.grey
                      : Colors.black87,
                  fontSize: 13,
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
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 16,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.grey.shade200,
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.access_time_outlined,
              color: Color(0xFF6EA8FE),
              size: 20,
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
                      ? Colors.grey
                      : Colors.black87,
                  fontSize: 13,
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

    // Pastikan nama mata kuliah masih ada di database.
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
      SnackBar(content: Text(pesan)),
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
