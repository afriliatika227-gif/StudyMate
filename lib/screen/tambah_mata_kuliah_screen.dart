
import 'package:flutter/material.dart';

const Color _plum = Color(0xFF66527F);
const Color _darkPlum = Color(0xFF423650);
const Color _lavender = Color(0xFFEDE6F6);
const Color _softLavender = Color(0xFFF6F2FA);
const Color _pink = Color(0xFFD98EAD);
const Color _softPink = Color(0xFFFAEDF2);
const Color _background = Color(0xFFFAF8FC);
const Color _line = Color(0xFFECE6F0);
const Color _muted = Color(0xFF92899B);

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
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: _darkPlum,
          ),
        ),
        title: Text(
          sedangEdit ? 'Edit Mata Kuliah' : 'Tambah Mata Kuliah',
          style: const TextStyle(
            color: _darkPlum,
            fontSize: 19,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 35),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _header(),

                const SizedBox(height: 25),

                const Text(
                  'Informasi Mata Kuliah',
                  style: TextStyle(
                    color: _darkPlum,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  'Lengkapi informasi akademik untuk '
                  'mengatur perkuliahanmu.',
                  style: TextStyle(
                    color: _muted,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 19),

                _formCard(),

                const SizedBox(height: 23),

                _saveButton(),

                const SizedBox(height: 14),

                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.auto_awesome_rounded,
                        color: _pink,
                        size: 13,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'StudyMate  •  Academic Management',
                        style: TextStyle(
                          color: Colors.blueGrey.shade300,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // HEADER DENGAN FOTO BUKU NYATA
  Widget _header() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF806C9C),
            Color(0xFF65527F),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(23),
        boxShadow: [
          BoxShadow(
            color: _plum.withValues(alpha: 0.16),
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
                Text(
                  sedangEdit
                      ? 'Perbarui Data'
                      : 'Tambah Data Baru',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 9),

                Text(
                  sedangEdit
                      ? 'Perbarui informasi agar data kuliahmu tetap akurat.'
                      : 'Catat mata kuliahmu agar aktivitas akademik '
                          'lebih teratur dan mudah dikelola.',
                  style: const TextStyle(
                    color: Color(0xFFF2EDF7),
                    fontSize: 12,
                    height: 1.6,
                  ),
                ),

                const SizedBox(height: 14),

                Row(
                  children: [
                    const Icon(
                      Icons.auto_awesome_rounded,
                      color: Color(0xFFFFD9E8),
                      size: 15,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      sedangEdit
                          ? 'Perbarui informasi perkuliahan'
                          : 'Mulai perjalanan belajarmu',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 88,
              height: 112,
              color: Colors.white.withValues(alpha: 0.15),
              child: Image.network(
                'https://images.unsplash.com/photo-1497633762265-9d179a990aa6?w=400',
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;

                  return const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.image_not_supported_outlined,
                    color: Colors.white,
                    size: 30,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // KARTU FORM
  Widget _formCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _line),
        boxShadow: [
          BoxShadow(
            color: _darkPlum.withValues(alpha: 0.035),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                  color: _softLavender,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(
                  Icons.edit_note_rounded,
                  color: _plum,
                  size: 21,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Data Perkuliahan',
                  style: TextStyle(
                    color: _darkPlum,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: _softPink,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Wajib diisi',
                  style: TextStyle(
                    color: _pink,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

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
            borderRadius: BorderRadius.circular(13),
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
                      color: _darkPlum,
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
    );
  }

  // LABEL FORM
  Widget _label(String text) {
    return Row(
      children: [
        Text(
          text,
          style: const TextStyle(
            color: _darkPlum,
            fontSize: 12,
            fontWeight: FontWeight.w600,
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
    final accent = pink ? _pink : _plum;

    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: _muted,
        fontSize: 11,
        fontWeight: FontWeight.w400,
      ),
      prefixIcon: Icon(
        icon,
        color: accent,
        size: 19,
      ),
      filled: true,
      fillColor: _background,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: _line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(
          color: _line,
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(
          color: _plum,
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(
          color: Color(0xFFD95C65),
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(
          color: Color(0xFFD95C65),
          width: 1.5,
        ),
      ),
    );
  }

  // TOMBOL SIMPAN
  Widget _saveButton() {
    return SizedBox(
      width: double.infinity,
      height: 53,
      child: ElevatedButton.icon(
        onPressed: _simpanMataKuliah,
        icon: Icon(
          sedangEdit
              ? Icons.check_circle_outline_rounded
              : Icons.save_rounded,
          size: 20,
        ),
        label: Text(
          sedangEdit
              ? 'Simpan Perubahan'
              : 'Simpan Mata Kuliah',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _plum,
          foregroundColor: Colors.white,
          elevation: 3,
          shadowColor: _plum.withValues(alpha: 0.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
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