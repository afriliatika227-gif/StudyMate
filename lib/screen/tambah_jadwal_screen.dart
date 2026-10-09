import 'package:flutter/material.dart';

class TambahJadwalScreen extends StatefulWidget {
  const TambahJadwalScreen({super.key});

  @override
  State<TambahJadwalScreen> createState() => _TambahJadwalScreenState();
}

class _TambahJadwalScreenState extends State<TambahJadwalScreen> {
  String? mataKuliah;
  String hari = 'Senin';

  TimeOfDay? waktuMulai;
  TimeOfDay? waktuSelesai;

  final TextEditingController ruanganController =
      TextEditingController();

  final List<String> daftarMataKuliah = [
    'Pemrograman Mobile',
    'Internet of Things',
    'Metodologi Penelitian',
    'Statistika Pendidikan',
    'Perencanaan Pembelajaran',
    'Jaringan Komputer',
  ];

  final List<String> daftarHari = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
  ];

  @override
  void dispose() {
    ruanganController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),

      appBar: AppBar(
        title: const Text(
          'Tambah Jadwal',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label('Mata Kuliah'),

            const SizedBox(height: 8),

            DropdownButtonFormField<String>(
              value: mataKuliah,
              decoration: _inputDecoration(
                'Pilih mata kuliah',
                Icons.menu_book_outlined,
              ),
              items: daftarMataKuliah.map((item) {
                return DropdownMenuItem(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  mataKuliah = value;
                });
              },
            ),

            const SizedBox(height: 20),

            _label('Hari'),

            const SizedBox(height: 8),

            DropdownButtonFormField<String>(
              value: hari,
              decoration: _inputDecoration(
                'Pilih hari',
                Icons.calendar_today_outlined,
              ),
              items: daftarHari.map((item) {
                return DropdownMenuItem(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    hari = value;
                  });
                }
              },
            ),

            const SizedBox(height: 20),

            _label('Waktu Kuliah'),

            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: _timeButton(
                    label: 'Jam Mulai',
                    time: waktuMulai,
                    onTap: _pilihWaktuMulai,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _timeButton(
                    label: 'Jam Selesai',
                    time: waktuSelesai,
                    onTap: _pilihWaktuSelesai,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            _label('Ruangan'),

            const SizedBox(height: 8),

            TextField(
              controller: ruanganController,
              decoration: _inputDecoration(
                'Contoh: Gedung H, Ruang 301',
                Icons.location_on_outlined,
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _simpanJadwal,
                icon: const Icon(Icons.save_outlined),
                label: const Text(
                  'Simpan Jadwal',
                  style: TextStyle(
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

  Widget _timeButton({
    required String label,
    required TimeOfDay? time,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
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

            const SizedBox(width: 10),

            Expanded(
              child: Text(
                time == null ? label : time.format(context),
                style: TextStyle(
                  fontSize: 13,
                  color: time == null
                      ? Colors.grey
                      : Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pilihWaktuMulai() async {
    final waktu = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (waktu != null) {
      setState(() {
        waktuMulai = waktu;
      });
    }
  }

  Future<void> _pilihWaktuSelesai() async {
    final waktu = await showTimePicker(
      context: context,
      initialTime: waktuMulai ?? TimeOfDay.now(),
    );

    if (waktu != null) {
      setState(() {
        waktuSelesai = waktu;
      });
    }
  }

  void _simpanJadwal() {
    if (mataKuliah == null ||
        waktuMulai == null ||
        waktuSelesai == null ||
        ruanganController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Mohon lengkapi semua data jadwal.',
          ),
        ),
      );

      return;
    }

    final jamMulai = waktuMulai!.format(context);
    final jamSelesai = waktuSelesai!.format(context);

    final jam = '$jamMulai - $jamSelesai';

    Navigator.pop(
      context,
      {
        'hari': hari,
        'mataKuliah': mataKuliah!,
        'jam': jam,
        'ruang': ruanganController.text.trim(),
      },
    );
  }
}