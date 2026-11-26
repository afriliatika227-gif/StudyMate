
import 'package:flutter/material.dart';

const Color _blue = Color(0xFF3478C8);
const Color _darkBlue = Color(0xFF344054);
const Color _background = Color(0xFFF5F7FA);
const Color _line = Color(0xFFE4E8EF);
const Color _muted = Color(0xFF7C8798);
const Color _softBlue = Color(0xFFEAF2FC);
const Color _softPink = Color(0xFFFCECF2);
const Color _pink = Color(0xFFD7799E);

class TambahJadwalScreen extends StatefulWidget {
  final Map<String, String>? jadwalAwal;

  const TambahJadwalScreen({
    super.key,
    this.jadwalAwal,
  });

  @override
  State<TambahJadwalScreen> createState() =>
      _TambahJadwalScreenState();
}

class _TambahJadwalScreenState extends State<TambahJadwalScreen> {
  String? mataKuliah;
  String hari = 'Senin';

  TimeOfDay? waktuMulai;
  TimeOfDay? waktuSelesai;

  final ruanganController = TextEditingController();

  final daftarMataKuliah = [
    'Pemrograman Mobile',
    'Internet of Things',
    'Metodologi Penelitian',
    'Statistika Pendidikan',
    'Perencanaan Pembelajaran',
    'Jaringan Komputer',
  ];

  final daftarHari = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
  ];

  bool get sedangEdit => widget.jadwalAwal != null;

  @override
  void initState() {
    super.initState();

    final data = widget.jadwalAwal;

    if (data != null) {
      final nama = data['mataKuliah'];

      if (daftarMataKuliah.contains(nama)) {
        mataKuliah = nama;
      }

      final hariAwal = data['hari'];

      if (daftarHari.contains(hariAwal)) {
        hari = hariAwal!;
      }

      ruanganController.text = data['ruang'] ?? '';

      final jam = data['jam'] ?? '';
      final bagian = jam.split(' - ');

      if (bagian.length == 2) {
        waktuMulai = _parseWaktu(bagian[0]);
        waktuSelesai = _parseWaktu(bagian[1]);
      }
    }
  }

  TimeOfDay? _parseWaktu(String teks) {
    final pola = RegExp(
      r'^(\d{1,2})[.:](\d{2})(?:\s*(AM|PM))?$',
      caseSensitive: false,
    );

    final cocok = pola.firstMatch(teks.trim());
    if (cocok == null) return null;

    int jam = int.parse(cocok.group(1)!);
    final menit = int.parse(cocok.group(2)!);
    final periode = cocok.group(3)?.toUpperCase();

    if (menit > 59 || jam > 23) return null;

    if (periode != null) {
      if (jam < 1 || jam > 12) return null;

      if (periode == 'AM') {
        jam = jam == 12 ? 0 : jam;
      } else {
        jam = jam == 12 ? 12 : jam + 12;
      }
    }

    return TimeOfDay(hour: jam, minute: menit);
  }

  @override
  void dispose() {
    ruanganController.dispose();
    super.dispose();
  }

  InputDecoration _dekorasi(
    String petunjuk,
    IconData ikon, {
    bool pink = false,
  }) {
    return InputDecoration(
      hintText: petunjuk,
      hintStyle: const TextStyle(
        color: _muted,
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
      prefixIcon: Icon(
        ikon,
        color: pink ? _pink : _blue,
        size: 20,
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 15,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: _blue,
          width: 1.5,
        ),
      ),
    );
  }

  Widget _label(String teks) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Text(
        teks,
        style: const TextStyle(
          color: _darkBlue,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Future<void> _pilihWaktu(bool mulai) async {
    final awal = mulai
        ? (waktuMulai ?? TimeOfDay.now())
        : (waktuSelesai ?? waktuMulai ?? TimeOfDay.now());

    final hasil = await showTimePicker(
      context: context,
      initialTime: awal,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: _blue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: _darkBlue,
            ),
          ),
          child: child!,
        );
      },
    );

    if (!mounted || hasil == null) return;

    setState(() {
      if (mulai) {
        waktuMulai = hasil;
      } else {
        waktuSelesai = hasil;
      }
    });
  }

  Widget _tombolWaktu(
    String label,
    TimeOfDay? waktu,
    bool mulai,
  ) {
    final terisi = waktu != null;
    final warna = mulai ? _blue : _pink;
    final latar = mulai ? _softBlue : _softPink;

    return InkWell(
      onTap: () => _pilihWaktu(mulai),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 11,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: terisi ? warna.withValues(alpha: 0.6) : _line,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: latar,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.access_time_rounded,
                color: warna,
                size: 18,
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: _muted,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    terisi ? waktu.format(context) : 'Pilih jam',
                    style: TextStyle(
                      color: terisi ? _darkBlue : _muted,
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
    );
  }

  void _simpan() {
    if (mataKuliah == null ||
        waktuMulai == null ||
        waktuSelesai == null ||
        ruanganController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mohon lengkapi semua data jadwal.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final menitMulai =
        waktuMulai!.hour * 60 + waktuMulai!.minute;

    final menitSelesai =
        waktuSelesai!.hour * 60 + waktuSelesai!.minute;

    if (menitSelesai <= menitMulai) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Jam selesai harus setelah jam mulai.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    Navigator.pop(
      context,
      <String, String>{
        'hari': hari,
        'mataKuliah': mataKuliah!,
        'jam':
            '${waktuMulai!.format(context)} - ${waktuSelesai!.format(context)}',
        'ruang': ruanganController.text.trim(),
      },
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
        foregroundColor: _darkBlue,
        title: Text(
          sedangEdit ? 'Edit Jadwal' : 'Tambah Jadwal',
          style: const TextStyle(
            color: _darkBlue,
            fontSize: 19,
            fontWeight: FontWeight.w600,
          ),
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(),
              const SizedBox(height: 24),
              const Text(
                'Informasi Jadwal',
                style: TextStyle(
                  color: _darkBlue,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Lengkapi informasi perkuliahan berikut.',
                style: TextStyle(
                  color: _muted,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _line),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('Mata Kuliah'),
                    DropdownButtonFormField<String>(
                      initialValue: mataKuliah,
                      isExpanded: true,
                      decoration: _dekorasi(
                        'Pilih mata kuliah',
                        Icons.menu_book_outlined,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      items: daftarMataKuliah.map((nama) {
                        return DropdownMenuItem<String>(
                          value: nama,
                          child: Text(
                            nama,
                            style: const TextStyle(
                              color: _darkBlue,
                              fontSize: 13,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (nilai) {
                        setState(() => mataKuliah = nilai);
                      },
                    ),
                    const SizedBox(height: 20),
                    _label('Hari Perkuliahan'),
                    DropdownButtonFormField<String>(
                      initialValue: hari,
                      isExpanded: true,
                      decoration: _dekorasi(
                        'Pilih hari',
                        Icons.calendar_today_outlined,
                        pink: true,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      items: daftarHari.map((nama) {
                        return DropdownMenuItem<String>(
                          value: nama,
                          child: Text(
                            nama,
                            style: const TextStyle(
                              color: _darkBlue,
                              fontSize: 13,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (nilai) {
                        if (nilai != null) {
                          setState(() => hari = nilai);
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    _label('Waktu Perkuliahan'),
                    Row(
                      children: [
                        Expanded(
                          child: _tombolWaktu(
                            'Jam Mulai',
                            waktuMulai,
                            true,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _tombolWaktu(
                            'Jam Selesai',
                            waktuSelesai,
                            false,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _label('Ruangan'),
                    TextField(
                      controller: ruanganController,
                      textCapitalization: TextCapitalization.words,
                      decoration: _dekorasi(
                        'Contoh: Gedung H, Ruang 301',
                        Icons.location_on_outlined,
                        pink: true,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _simpan,
                  icon: Icon(
                    sedangEdit
                        ? Icons.check_rounded
                        : Icons.save_outlined,
                    size: 20,
                  ),
                  label: Text(
                    sedangEdit ? 'Simpan Perubahan' : 'Simpan Jadwal',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _blue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  'StudyMate • Academic Management',
                  style: TextStyle(
                    color: Colors.blueGrey.shade400,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() {
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
                Text(
                  sedangEdit ? 'Perbarui Jadwal' : 'Jadwal Baru',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  sedangEdit
                      ? 'Perbarui informasi jadwal perkuliahanmu.'
                      : 'Atur waktu kuliah agar aktivitas akademik lebih teratur.',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(
              sedangEdit
                  ? Icons.edit_calendar_outlined
                  : Icons.calendar_month_outlined,
              color: Colors.white,
              size: 27,
            ),
          ),
        ],
      ),
    );
  }
}
