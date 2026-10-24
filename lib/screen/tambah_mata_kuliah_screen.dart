
import 'package:flutter/material.dart';

const Color _blue = Color(0xFF8DBBFA);
const Color _darkBlue = Color(0xFF40516F);
const Color _background = Color(0xFFF4F8FF);
const Color _softBlue = Color(0xFFEAF4FF);
const Color _softPink = Color(0xFFFFEAF2);
const Color _softPinkDark = Color(0xFFE99BB9);
const Color _softBlueDark = Color(0xFF719FD9);
const Color _softLavender = Color(0xFFE8E3FF);
const Color _muted = Color(0xFF8796B0);

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
        backgroundColor: _background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
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
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _header(),
                const SizedBox(height: 26),

                const Text(
                  'Informasi Mata Kuliah',
                  style: TextStyle(
                    color: _darkBlue,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Lengkapi informasi akademikmu di bawah ini.',
                  style: TextStyle(
                    color: _muted,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 22),

                _label('Nama Mata Kuliah', Icons.menu_book_rounded),
                const SizedBox(height: 9),
                TextFormField(
                  controller: namaController,
                  textCapitalization: TextCapitalization.words,
                  decoration: _inputDecoration(
                    'Contoh: Pemrograman Berbasis Objek',
                    Icons.menu_book_outlined,
                    pink: false,
                  ),
                  validator: (value) =>
                      value == null || value.trim().isEmpty
                          ? 'Nama mata kuliah wajib diisi'
                          : null,
                ),
                const SizedBox(height: 20),

                _label(
                  'Kode Mata Kuliah',
                  Icons.confirmation_number_rounded,
                ),
                const SizedBox(height: 9),
                TextFormField(
                  controller: kodeController,
                  textCapitalization: TextCapitalization.characters,
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

                _label('Dosen Pengampu', Icons.person_rounded),
                const SizedBox(height: 9),
                TextFormField(
                  controller: dosenController,
                  textCapitalization: TextCapitalization.words,
                  decoration: _inputDecoration(
                    'Masukkan nama dosen pengampu',
                    Icons.person_outline_rounded,
                    pink: false,
                  ),
                  validator: (value) =>
                      value == null || value.trim().isEmpty
                          ? 'Nama dosen wajib diisi'
                          : null,
                ),
                const SizedBox(height: 20),

                _label('Semester', Icons.school_rounded),
                const SizedBox(height: 9),
                DropdownButtonFormField<String>(
                  value: semester,
                  isExpanded: true,
                  decoration: _inputDecoration(
                    'Pilih semester',
                    Icons.calendar_month_rounded,
                    pink: true,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  items: List.generate(
                    8,
                    (index) {
                      final semesterKe = index + 1;
                      return DropdownMenuItem<String>(
                        value: 'Semester $semesterKe',
                        child: Text('Semester $semesterKe'),
                      );
                    },
                  ),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => semester = value);
                    }
                  },
                ),
                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    onPressed: _simpanMataKuliah,
                    icon: Icon(
                      sedangEdit
                          ? Icons.check_circle_outline_rounded
                          : Icons.save_rounded,
                    ),
                    label: Text(
                      sedangEdit
                          ? 'Simpan Perubahan'
                          : 'Simpan Mata Kuliah',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _blue,
                      foregroundColor: Colors.white,
                      elevation: 3,
                      shadowColor: _blue.withValues(alpha: 0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    'StudyMate • Atur kuliah, raih impian ✨',
                    style: TextStyle(
                      color: _muted.withValues(alpha: 0.9),
                      fontSize: 11,
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

  Widget _header() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFDCEBFF),
            Color(0xFFE8E3FF),
            Color(0xFFFFEAF2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: _blue.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sedangEdit
                      ? 'Perbarui Data ✨'
                      : 'Tambah Data Baru ✨',
                  style: const TextStyle(
                    color: _darkBlue,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  sedangEdit
                      ? 'Perbarui informasi agar data kuliahmu tetap akurat.'
                      : 'Catat mata kuliahmu agar aktivitas akademik lebih teratur.',
                  style: TextStyle(
                    color: _darkBlue.withValues(alpha: 0.8),
                    fontSize: 12,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 62,
            height: 68,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.75),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              sedangEdit
                  ? Icons.edit_note_rounded
                  : Icons.auto_stories_rounded,
              color: _softBlueDark,
              size: 35,
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 17, color: _darkBlue),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            color: _darkBlue,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Text(
          ' *',
          style: TextStyle(
            color: _softPinkDark,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(
    String hint,
    IconData icon, {
    required bool pink,
  }) {
    final accent = pink ? _softPinkDark : _softBlueDark;
    final borderColor = pink ? _softPink : _softBlue;

    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: _muted,
        fontSize: 12,
      ),
      prefixIcon: Icon(icon, color: accent, size: 21),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 17,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(17),
        borderSide: BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(17),
        borderSide: BorderSide(color: borderColor, width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(17),
        borderSide: BorderSide(color: accent, width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(17),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(17),
        borderSide: const BorderSide(
          color: Colors.redAccent,
          width: 1.5,
        ),
      ),
    );
  }

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
