
import 'package:flutter/material.dart';

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

class _TambahJadwalScreenState
    extends State<TambahJadwalScreen> {
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
    IconData ikon,
  ) {
    return InputDecoration(
      hintText: petunjuk,
      prefixIcon: Icon(ikon, color: const Color(0xFF6EA8FE)),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
    );
  }

  Widget _label(String teks) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          teks,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      );

  Future<void> _pilihWaktu(bool mulai) async {
    final awal = mulai
        ? (waktuMulai ?? TimeOfDay.now())
        : (waktuSelesai ?? waktuMulai ?? TimeOfDay.now());

    final hasil = await showTimePicker(
      context: context,
      initialTime: awal,
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

  Widget _tombolWaktu(String label, TimeOfDay? waktu, bool mulai) {
    return InkWell(
      onTap: () => _pilihWaktu(mulai),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.access_time,
              color: Color(0xFF6EA8FE),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                waktu == null ? label : waktu.format(context),
                style: const TextStyle(fontSize: 13),
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
      backgroundColor: const Color(0xFFF8FAFD),
      appBar: AppBar(
        title: Text(
          sedangEdit ? 'Edit Jadwal' : 'Tambah Jadwal',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
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
              items: daftarMataKuliah
                  .map(
                    (nama) => DropdownMenuItem(
                      value: nama,
                      child: Text(nama),
                    ),
                  )
                  .toList(),
              onChanged: (nilai) {
                setState(() => mataKuliah = nilai);
              },
            ),
            const SizedBox(height: 20),
            _label('Hari'),
            DropdownButtonFormField<String>(
              initialValue: hari,
              decoration: _dekorasi(
                'Pilih hari',
                Icons.calendar_today_outlined,
              ),
              items: daftarHari
                  .map(
                    (nama) => DropdownMenuItem(
                      value: nama,
                      child: Text(nama),
                    ),
                  )
                  .toList(),
              onChanged: (nilai) {
                if (nilai != null) setState(() => hari = nilai);
              },
            ),
            const SizedBox(height: 20),
            _label('Waktu Kuliah'),
            Row(
              children: [
                Expanded(
                  child: _tombolWaktu(
                    'Jam Mulai',
                    waktuMulai,
                    true,
                  ),
                ),
                const SizedBox(width: 12),
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
              decoration: _dekorasi(
                'Contoh: Gedung H, Ruang 301',
                Icons.location_on_outlined,
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _simpan,
                icon: const Icon(Icons.save_outlined),
                label: Text(
                  sedangEdit ? 'Simpan Perubahan' : 'Simpan Jadwal',
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
          ],
        ),
      ),
    );
  }
}