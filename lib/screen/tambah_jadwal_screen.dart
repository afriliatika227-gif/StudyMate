
import 'package:flutter/material.dart';

const Color _plum = Color(0xFF66527F);
const Color _darkPlum = Color(0xFF423650);
const Color _lavender = Color(0xFF806C9C);
const Color _softLavender = Color(0xFFF0EBF6);
const Color _pink = Color(0xFFD995B2);
const Color _softPink = Color(0xFFFAEFF4);
const Color _background = Color(0xFFFAF8FC);
const Color _line = Color(0xFFEAE5EF);
const Color _muted = Color(0xFF91899B);
const Color _softGreen = Color(0xFFEDF5F0);

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
    final warna = pink ? _pink : _plum;

    return InputDecoration(
      hintText: petunjuk,
      hintStyle: const TextStyle(
        color: _muted,
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
      prefixIcon: Icon(
        ikon,
        color: warna,
        size: 20,
      ),
      filled: true,
      fillColor: const Color(0xFFFCFBFD),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: _line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: _line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(
          color: _plum,
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
          color: _darkPlum,
          fontSize: 13,
          fontWeight: FontWeight.w600,
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
    final warna = mulai ? _plum : _pink;
    final latar = mulai ? _softLavender : _softPink;

    return InkWell(
      onTap: () => _pilihWaktu(mulai),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: terisi ? warna.withValues(alpha: 0.55) : _line,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: latar,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(
                Icons.access_time_rounded,
                color: warna,
                size: 19,
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
                  const SizedBox(height: 5),
                  Text(
                    terisi ? waktu.format(context) : 'Pilih jam',
                    style: TextStyle(
                      color: terisi ? _darkPlum : _muted,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: warna,
              size: 19,
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
        foregroundColor: _darkPlum,
        title: Text(
          sedangEdit ? 'Edit Jadwal' : 'Tambah Jadwal',
          style: const TextStyle(
            color: _darkPlum,
            fontSize: 18,
            fontWeight: FontWeight.w700,
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
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(),

              const SizedBox(height: 26),

              const Text(
                'Informasi Jadwal',
                style: TextStyle(
                  color: _darkPlum,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 5),

              const Text(
                'Atur detail perkuliahanmu dengan mudah.',
                style: TextStyle(
                  color: _muted,
                  fontSize: 12,
                ),
              ),

              const SizedBox(height: 17),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(17),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(19),
                  border: Border.all(color: _line),
                  boxShadow: [
                    BoxShadow(
                      color: _plum.withValues(alpha: 0.045),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
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
                        Icons.menu_book_rounded,
                      ),
                      borderRadius: BorderRadius.circular(13),
                      items: daftarMataKuliah.map((nama) {
                        return DropdownMenuItem<String>(
                          value: nama,
                          child: Text(
                            nama,
                            style: const TextStyle(
                              color: _darkPlum,
                              fontSize: 13,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (nilai) {
                        setState(() => mataKuliah = nilai);
                      },
                    ),

                    const SizedBox(height: 21),

                    _label('Hari Perkuliahan'),

                    DropdownButtonFormField<String>(
                      initialValue: hari,
                      isExpanded: true,
                      decoration: _dekorasi(
                        'Pilih hari',
                        Icons.calendar_today_rounded,
                        pink: true,
                      ),
                      borderRadius: BorderRadius.circular(13),
                      items: daftarHari.map((nama) {
                        return DropdownMenuItem<String>(
                          value: nama,
                          child: Text(
                            nama,
                            style: const TextStyle(
                              color: _darkPlum,
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

                    const SizedBox(height: 21),

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

                    const SizedBox(height: 21),

                    _label('Ruangan'),

                    TextField(
                      controller: ruanganController,
                      textCapitalization: TextCapitalization.words,
                      decoration: _dekorasi(
                        'Contoh: Gedung H, Ruang 301',
                        Icons.location_on_rounded,
                        pink: true,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 17),

              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _softGreen,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.lightbulb_outline_rounded,
                      color: Color(0xFF648A72),
                      size: 19,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Pastikan waktu dan ruangan sudah sesuai agar jadwal kuliahmu tidak bertabrakan.',
                        style: TextStyle(
                          color: Color(0xFF587563),
                          fontSize: 11,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 23),

              SizedBox(
                width: double.infinity,
                height: 53,
                child: ElevatedButton.icon(
                  onPressed: _simpan,
                  icon: Icon(
                    sedangEdit
                        ? Icons.check_rounded
                        : Icons.save_rounded,
                    size: 19,
                  ),
                  label: Text(
                    sedangEdit ? 'Simpan Perubahan' : 'Simpan Jadwal',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _plum,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              Center(
                child: Text(
                  'StudyMate • Academic Management',
                  style: TextStyle(
                    color: Colors.blueGrey.shade300,
                    fontSize: 10,
                    letterSpacing: 0.3,
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
      height: 180,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [_lavender, _darkPlum],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: _plum.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            'https://images.unsplash.com/photo-1506784983877-45594efa4cbe?w=800',
            fit: BoxFit.cover,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;

              return Container(
                color: _lavender,
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: _lavender,
                child: const Icon(
                  Icons.calendar_month_rounded,
                  color: Colors.white54,
                  size: 55,
                ),
              );
            },
          ),

          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _darkPlum.withValues(alpha: 0.88),
                  _darkPlum.withValues(alpha: 0.42),
                  Colors.transparent,
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(21),
            child: Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: 215,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'STUDYMATE PLANNER',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),

                    const SizedBox(height: 13),

                    Text(
                      sedangEdit ? 'Perbarui Jadwal' : 'Jadwal Baru',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      sedangEdit
                          ? 'Perbarui informasi perkuliahanmu agar tetap teratur.'
                          : 'Susun jadwal kuliah dan buat aktivitas akademikmu lebih terencana.',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
