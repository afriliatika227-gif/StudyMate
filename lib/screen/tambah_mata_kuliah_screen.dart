import 'package:flutter/material.dart';

class TambahMataKuliahScreen extends StatefulWidget {
  final Map<String, String>? dataEdit;

  const TambahMataKuliahScreen({
    super.key,
    this.dataEdit,
  });

  @override
  State<TambahMataKuliahScreen> createState() =>
      _TambahMataKuliahScreenState();
}

class _TambahMataKuliahScreenState
    extends State<TambahMataKuliahScreen> {
  final TextEditingController namaController =
      TextEditingController();

  final TextEditingController kodeController =
      TextEditingController();

  final TextEditingController dosenController =
      TextEditingController();

  String semester = 'Semester 5';

  bool get sedangEdit => widget.dataEdit != null;

  @override
  void initState() {
    super.initState();

    if (widget.dataEdit != null) {
      namaController.text = widget.dataEdit!['nama'] ?? '';
      kodeController.text = widget.dataEdit!['kode'] ?? '';
      dosenController.text = widget.dataEdit!['dosen'] ?? '';
      semester = widget.dataEdit!['semester'] ?? 'Semester 5';
    }
  }

  @override
  void dispose() {
    namaController.dispose();
    kodeController.dispose();
    dosenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      appBar: AppBar(
        title: Text(
          sedangEdit
              ? 'Edit Mata Kuliah'
              : 'Tambah Mata Kuliah',
          style: const TextStyle(
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
            _label('Nama Mata Kuliah'),
            const SizedBox(height: 8),
            TextField(
              controller: namaController,
              decoration: _inputDecoration(
                'Masukkan nama mata kuliah',
                Icons.menu_book_outlined,
              ),
            ),

            const SizedBox(height: 20),

            _label('Kode Mata Kuliah'),
            const SizedBox(height: 8),
            TextField(
              controller: kodeController,
              decoration: _inputDecoration(
                'Contoh: PTI501',
                Icons.confirmation_number_outlined,
              ),
            ),

            const SizedBox(height: 20),

            _label('Dosen Pengampu'),
            const SizedBox(height: 8),
            TextField(
              controller: dosenController,
              decoration: _inputDecoration(
                'Masukkan nama dosen',
                Icons.person_outline,
              ),
            ),

            const SizedBox(height: 20),

            _label('Semester'),
            const SizedBox(height: 8),

            DropdownButtonFormField<String>(
              value: semester,
              decoration: _inputDecoration(
                'Pilih semester',
                Icons.school_outlined,
              ),
              items: List.generate(
                8,
                (index) {
                  final semesterKe = index + 1;

                  return DropdownMenuItem<String>(
                    value: 'Semester $semesterKe',
                    child: Text(
                      'Semester $semesterKe',
                    ),
                  );
                },
              ),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    semester = value;
                  });
                }
              },
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _simpanMataKuliah,
                icon: const Icon(
                  Icons.save_outlined,
                ),
                label: Text(
                  sedangEdit
                      ? 'Simpan Perubahan'
                      : 'Simpan Mata Kuliah',
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

  void _simpanMataKuliah() {
    if (namaController.text.trim().isEmpty ||
        kodeController.text.trim().isEmpty ||
        dosenController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Mohon lengkapi semua data mata kuliah.',
          ),
        ),
      );
      return;
    }

    Navigator.pop(
      context,
      {
        'nama': namaController.text.trim(),
        'kode': kodeController.text.trim(),
        'dosen': dosenController.text.trim(),
        'semester': semester,
      },
    );
  }
}