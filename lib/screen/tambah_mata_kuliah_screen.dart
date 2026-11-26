
import 'package:flutter/material.dart';

const Color _blue = Color(0xFF3478C8);
const Color _darkBlue = Color(0xFF344054);
const Color _background = Color(0xFFF5F7FA);
const Color _line = Color(0xFFE4E8EF);
const Color _muted = Color(0xFF7C8798);
const Color _softBlue = Color(0xFFEAF2FC);
const Color _softPink = Color(0xFFFCECF2);
const Color _pink = Color(0xFFD7799E);

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
  final TextEditingController namaController = TextEditingController();
  final TextEditingController kodeController = TextEditingController();
  final TextEditingController dosenController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  String semester = 'Semester 5';

  bool get sedangEdit => widget.dataEdit != null;

  @override
  void initState() {
    super.initState();

    final data = widget.dataEdit;

    if (data != null) {
      namaController.text =
          data['course_name'] ?? data['nama'] ?? '';
      kodeController.text =
          data['course_code'] ?? data['kode'] ?? '';
      dosenController.text =
          data['lecturer_name'] ?? data['dosen'] ?? '';

      final semesterLama = data['semester'] ?? '5';
      final angkaSemester =
          int.tryParse(semesterLama.replaceAll('Semester ', ''));

      semester = angkaSemester != null &&
              angkaSemester >= 1 &&
              angkaSemester <= 8
          ? 'Semester $angkaSemester'
          : 'Semester 5';
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
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: _darkBlue,
          ),
        ),
        title: Text(
          sedangEdit ? 'Edit Mata Kuliah' : 'Tambah Mata Kuliah',
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
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _header(),

                const SizedBox(height: 26),

                const Text(
                  'Informasi Mata Kuliah',
                  style: TextStyle(
                    color: _darkBlue,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 5),

                const Text(
                  'Lengkapi informasi akademik berikut.',
                  style: TextStyle(
                    color: _muted,
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 20),

                // FORM
                Container(
                  padding: const EdgeInsets.all(17),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _line),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('Nama Mata Kuliah'),
                      const SizedBox(height: 9),

                      TextFormField(
                        controller: namaController,
                        textCapitalization: TextCapitalization.words,
                        decoration: _inputDecoration(
                          'Contoh: Pemrograman Berbasis Objek',
                          Icons.menu_book_outlined,
                        ),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                                ? 'Nama mata kuliah wajib diisi'
                                : null,
                      ),

                      const SizedBox(height: 20),

                      _label('Kode Mata Kuliah'),
                      const SizedBox(height: 9),

                      TextFormField(
                        controller: kodeController,
                        textCapitalization:
                            TextCapitalization.characters,
                        decoration: _inputDecoration(
                          'Contoh: PTI501',
                          Icons.tag_rounded,
                          pink: true,
                        ),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                                ? 'Kode mata kuliah wajib diisi'
                                : null,
                      ),

                      const SizedBox(height: 20),

                      _label('Dosen Pengampu'),
                      const SizedBox(height: 9),

                      TextFormField(
                        controller: dosenController,
                        textCapitalization: TextCapitalization.words,
                        decoration: _inputDecoration(
                          'Masukkan nama dosen pengampu',
                          Icons.person_outline_rounded,
                        ),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                                ? 'Nama dosen wajib diisi'
                                : null,
                      ),

                      const SizedBox(height: 20),

                      _label('Semester'),
                      const SizedBox(height: 9),

                      DropdownButtonFormField<String>(
                        initialValue: semester,
                        isExpanded: true,
                        decoration: _inputDecoration(
                          'Pilih semester',
                          Icons.calendar_month_outlined,
                          pink: true,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        items: List.generate(
                          8,
                          (index) {
                            final semesterKe = index + 1;

                            return DropdownMenuItem<String>(
                              value: 'Semester $semesterKe',
                              child: Text(
                                'Semester $semesterKe',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: _darkBlue,
                                ),
                              ),
                            );
                          },
                        ),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => semester = value);
                          }
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // TOMBOL SIMPAN
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _simpanMataKuliah,
                    icon: Icon(
                      sedangEdit
                          ? Icons.check_rounded
                          : Icons.save_outlined,
                      size: 20,
                    ),
                    label: Text(
                      sedangEdit
                          ? 'Simpan Perubahan'
                          : 'Simpan Mata Kuliah',
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
      ),
    );
  }

  // HEADER
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
                  sedangEdit
                      ? 'Perbarui Data'
                      : 'Tambah Data Baru',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  sedangEdit
                      ? 'Perbarui informasi agar data kuliahmu tetap akurat.'
                      : 'Catat mata kuliahmu agar aktivitas akademik lebih teratur.',
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
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(
              sedangEdit
                  ? Icons.edit_note_rounded
                  : Icons.menu_book_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  // LABEL FORM
  Widget _label(String text) {
    return Row(
      children: [
        Text(
          text,
          style: const TextStyle(
            color: _darkBlue,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Text(
          ' *',
          style: TextStyle(
            color: Color(0xFFD95C65),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // INPUT FORM
  InputDecoration _inputDecoration(
    String hint,
    IconData icon, {
    bool pink = false,
  }) {
    final accent = pink ? _pink : _blue;

    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: _muted,
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
      prefixIcon: Icon(
        icon,
        color: accent,
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
        borderSide: const BorderSide(
          color: _line,
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: _blue,
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: Color(0xFFD95C65),
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: Color(0xFFD95C65),
          width: 1.5,
        ),
      ),
    );
  }

  // SIMPAN DATA
  void _simpanMataKuliah() {
    if (!_formKey.currentState!.validate()) return;

    final angkaSemester =
        int.tryParse(semester.replaceAll('Semester ', '')) ?? 5;

    Navigator.pop(
      context,
      <String, String>{
        'course_name': namaController.text.trim(),
        'course_code': kodeController.text.trim(),
        'lecturer_name': dosenController.text.trim(),
        'semester': angkaSemester.toString(),
      },
    );
  }
}
