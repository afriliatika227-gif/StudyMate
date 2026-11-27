
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

const Color _plum = Color(0xFF66527F);
const Color _darkPlum = Color(0xFF423650);
const Color _background = Color(0xFFFAF8FC);
const Color _line = Color(0xFFEAE5EF);
const Color _muted = Color(0xFF8B8494);
const Color _pink = Color(0xFFD7799E);
const Color _softLavender = Color(0xFFF0EBF7);
const Color _softPink = Color(0xFFFFF0F5);
const Color _softMint = Color(0xFFE8F5EF);
const Color _softPeach = Color(0xFFFFF1E5);

const List<String> _semesterOptions = [
  'Semester 1',
  'Semester 2',
  'Semester 3',
  'Semester 4',
  'Semester 5',
  'Semester 6',
  'Semester 7',
  'Semester 8',
];

class DataDiriScreen extends StatefulWidget {
  const DataDiriScreen({super.key});

  @override
  State<DataDiriScreen> createState() => _DataDiriScreenState();
}

class _DataDiriScreenState extends State<DataDiriScreen> {
  String nama = 'Tika Afrilia';
  String npm = '2413025078';
  String programStudi = 'Pendidikan Teknologi Informasi';
  String semester = 'Semester 5';
  String email = 'tika.afrilia@example.com';

  Uint8List? fotoProfil;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final fotoBase64 = prefs.getString('profile_foto');

      Uint8List? foto;

      if (fotoBase64 != null && fotoBase64.isNotEmpty) {
        try {
          foto = base64Decode(fotoBase64);
        } catch (_) {
          foto = null;
        }
      }

      if (!mounted) return;

      setState(() {
        nama = prefs.getString('profile_nama') ?? 'Tika Afrilia';
        npm = prefs.getString('profile_npm') ?? '2413025078';
        programStudi = prefs.getString('profile_program_studi') ??
            'Pendidikan Teknologi Informasi';
        semester = prefs.getString('profile_semester') ?? 'Semester 5';
        email = prefs.getString('profile_email') ??
            'tika.afrilia@example.com';
        fotoProfil = foto;
        isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal memuat data diri.'),
        ),
      );
    }
  }

  Future<void> _saveProfile({
    required String namaBaru,
    required String npmBaru,
    required String programStudiBaru,
    required String semesterBaru,
    required String emailBaru,
    required Uint8List? fotoBaru,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final berhasil = await prefs.setString('profile_nama', namaBaru);
    if (!berhasil) {
      throw Exception('Gagal menyimpan nama.');
    }

    await prefs.setString('profile_npm', npmBaru);
    await prefs.setString('profile_program_studi', programStudiBaru);
    await prefs.setString('profile_semester', semesterBaru);
    await prefs.setString('profile_email', emailBaru);

    if (fotoBaru != null) {
      await prefs.setString(
        'profile_foto',
        base64Encode(fotoBaru),
      );
    }
  }

  Future<void> _bukaEditDataDiri() async {
    final hasil = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => EditDataDiriScreen(
          nama: nama,
          npm: npm,
          programStudi: programStudi,
          semester: semester,
          email: email,
          fotoProfil: fotoProfil,
        ),
      ),
    );

    if (!mounted || hasil == null) return;

    try {
      final namaBaru = hasil['nama'] as String;
      final npmBaru = hasil['npm'] as String;
      final programStudiBaru = hasil['programStudi'] as String;
      final semesterBaru = hasil['semester'] as String;
      final emailBaru = hasil['email'] as String;
      final fotoBaru = hasil['fotoProfil'] as Uint8List?;

      await _saveProfile(
        namaBaru: namaBaru,
        npmBaru: npmBaru,
        programStudiBaru: programStudiBaru,
        semesterBaru: semesterBaru,
        emailBaru: emailBaru,
        fotoBaru: fotoBaru,
      );

      if (!mounted) return;

      setState(() {
        nama = namaBaru;
        npm = npmBaru;
        programStudi = programStudiBaru;
        semester = semesterBaru;
        email = emailBaru;
        fotoProfil = fotoBaru ?? fotoProfil;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data diri berhasil disimpan.'),
          backgroundColor: Color(0xFF36A875),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Data gagal disimpan. Silakan coba kembali.',
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: _background,
        body: Center(
          child: CircularProgressIndicator(color: _plum),
        ),
      );
    }

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: const Text(
          'Data Diri',
          style: TextStyle(
            color: _darkPlum,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        iconTheme: const IconThemeData(color: _darkPlum),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(
            height: 1,
            thickness: 1,
            color: _line,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildProfileHeader(),

            const SizedBox(height: 28),

            const Text(
              'Informasi Pribadi',
              style: TextStyle(
                color: _darkPlum,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 5),

            const Text(
              'Informasi akun dan identitas akademikmu.',
              style: TextStyle(
                color: _muted,
                fontSize: 12,
              ),
            ),

            const SizedBox(height: 17),

            _buildInfoCard(
              icon: Icons.person_outline_rounded,
              title: 'Nama Lengkap',
              value: nama,
              iconColor: _plum,
              iconBackground: _softLavender,
            ),

            _buildInfoCard(
              icon: Icons.badge_outlined,
              title: 'Nomor Pokok Mahasiswa',
              value: npm,
              iconColor: _pink,
              iconBackground: _softPink,
            ),

            _buildInfoCard(
              icon: Icons.school_outlined,
              title: 'Program Studi',
              value: programStudi,
              iconColor: const Color(0xFF36A875),
              iconBackground: _softMint,
            ),

            _buildInfoCard(
              icon: Icons.menu_book_outlined,
              title: 'Semester',
              value: semester,
              iconColor: const Color(0xFFE39A42),
              iconBackground: _softPeach,
            ),

            _buildInfoCard(
              icon: Icons.email_outlined,
              title: 'Email',
              value: email,
              iconColor: _pink,
              iconBackground: _softPink,
            ),

            const SizedBox(height: 14),

            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _bukaEditDataDiri,
                icon: const Icon(
                  Icons.edit_outlined,
                  size: 19,
                ),
                label: const Text(
                  'Edit Data Diri',
                  style: TextStyle(
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
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 27,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFF0EBF7),
            Color(0xFFFFF0F5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(21),
        border: Border.all(
          color: const Color(0xFFEAE1F0),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _plum.withValues(alpha: 0.10),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 49,
              backgroundColor: _softLavender,
              backgroundImage:
                  fotoProfil != null ? MemoryImage(fotoProfil!) : null,
              child: fotoProfil == null
                  ? const Icon(
                      Icons.person_rounded,
                      size: 53,
                      color: _plum,
                    )
                  : null,
            ),
          ),

          const SizedBox(height: 17),

          Text(
            nama,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w800,
              color: _darkPlum,
            ),
          ),

          const SizedBox(height: 11),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: Colors.white,
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.school_rounded,
                  size: 15,
                  color: _plum,
                ),
                SizedBox(width: 6),
                Text(
                  'Mahasiswa',
                  style: TextStyle(
                    color: _plum,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 13),

          Text(
            npm,
            style: const TextStyle(
              color: _muted,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required Color iconColor,
    required Color iconBackground,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 15,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: _line),
        boxShadow: [
          BoxShadow(
            color: _darkPlum.withValues(alpha: 0.025),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 22,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  value,
                  style: const TextStyle(
                    color: _darkPlum,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ======================================================
// HALAMAN EDIT DATA DIRI
// ======================================================

class EditDataDiriScreen extends StatefulWidget {
  final String nama;
  final String npm;
  final String programStudi;
  final String semester;
  final String email;
  final Uint8List? fotoProfil;

  const EditDataDiriScreen({
    super.key,
    required this.nama,
    required this.npm,
    required this.programStudi,
    required this.semester,
    required this.email,
    required this.fotoProfil,
  });

  @override
  State<EditDataDiriScreen> createState() =>
      _EditDataDiriScreenState();
}

class _EditDataDiriScreenState extends State<EditDataDiriScreen> {
  late final TextEditingController namaController;
  late final TextEditingController npmController;
  late final TextEditingController prodiController;
  late final TextEditingController emailController;

  late String semester;
  Uint8List? fotoSementara;
  bool sedangMemilihFoto = false;

  @override
  void initState() {
    super.initState();

    namaController = TextEditingController(text: widget.nama);
    npmController = TextEditingController(text: widget.npm);
    prodiController =
        TextEditingController(text: widget.programStudi);
    emailController = TextEditingController(text: widget.email);

    semester = widget.semester;
    fotoSementara = widget.fotoProfil;
  }

  @override
  void dispose() {
    namaController.dispose();
    npmController.dispose();
    prodiController.dispose();
    emailController.dispose();
    super.dispose();
  }

  Future<void> _pilihFoto() async {
    if (sedangMemilihFoto) return;

    setState(() => sedangMemilihFoto = true);

    try {
      final picker = ImagePicker();

      final XFile? foto = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
        maxWidth: 1000,
        maxHeight: 1000,
      );

      if (foto == null) return;

      final bytes = await foto.readAsBytes();

      if (bytes.isEmpty) {
        throw Exception('File foto kosong.');
      }

      if (!mounted) return;

      setState(() => fotoSementara = bytes);
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Foto gagal dibuka. Coba pilih gambar JPG atau PNG.',
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => sedangMemilihFoto = false);
      }
    }
  }

  void _simpanPerubahan() {
    final namaBaru = namaController.text.trim();
    final npmBaru = npmController.text.trim();
    final prodiBaru = prodiController.text.trim();
    final emailBaru = emailController.text.trim();

    if (namaBaru.isEmpty ||
        npmBaru.isEmpty ||
        prodiBaru.isEmpty ||
        emailBaru.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Semua data wajib diisi.'),
        ),
      );
      return;
    }

    Navigator.pop(
      context,
      <String, dynamic>{
        'nama': namaBaru,
        'npm': npmBaru,
        'programStudi': prodiBaru,
        'semester': semester,
        'email': emailBaru,
        'fotoProfil': fotoSementara,
      },
    );
  }

  InputDecoration _inputDecoration(
    String label,
    IconData icon,
  ) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
        color: _muted,
        fontSize: 13,
      ),
      prefixIcon: Icon(
        icon,
        color: _plum,
        size: 21,
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: _plum,
          width: 1.5,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: const Text(
          'Edit Data Diri',
          style: TextStyle(
            color: _darkPlum,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        iconTheme: const IconThemeData(color: _darkPlum),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(
            height: 1,
            thickness: 1,
            color: _line,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 23, 20, 32),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _plum.withValues(alpha: 0.09),
                    blurRadius: 16,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 53,
                backgroundColor: _softLavender,
                backgroundImage: fotoSementara != null
                    ? MemoryImage(fotoSementara!)
                    : null,
                child: fotoSementara == null
                    ? const Icon(
                        Icons.person_rounded,
                        size: 57,
                        color: _plum,
                      )
                    : null,
              ),
            ),

            const SizedBox(height: 12),

            TextButton.icon(
              onPressed: sedangMemilihFoto ? null : _pilihFoto,
              icon: sedangMemilihFoto
                  ? const SizedBox(
                      width: 17,
                      height: 17,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: _plum,
                      ),
                    )
                  : const Icon(
                      Icons.camera_alt_outlined,
                      size: 18,
                    ),
              label: Text(
                sedangMemilihFoto
                    ? 'Memuat Foto...'
                    : 'Ubah Foto Profil',
              ),
              style: TextButton.styleFrom(
                foregroundColor: _plum,
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),

            const SizedBox(height: 20),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFF0EBF7),
                    Color(0xFFFFF0F5),
                  ],
                ),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: const Color(0xFFEAE1F0),
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.edit_note_rounded,
                    color: _plum,
                    size: 24,
                  ),
                  SizedBox(width: 11),
                  Expanded(
                    child: Text(
                      'Perbarui informasi pribadimu melalui formulir berikut.',
                      style: TextStyle(
                        color: _darkPlum,
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 23),

            _buildFormLabel('Nama Lengkap'),
            TextField(
              controller: namaController,
              textCapitalization: TextCapitalization.words,
              decoration: _inputDecoration(
                'Masukkan nama lengkap',
                Icons.person_outline,
              ),
            ),

            const SizedBox(height: 16),

            _buildFormLabel('NPM'),
            TextField(
              controller: npmController,
              keyboardType: TextInputType.number,
              decoration: _inputDecoration(
                'Masukkan NPM',
                Icons.badge_outlined,
              ),
            ),

            const SizedBox(height: 16),

            _buildFormLabel('Program Studi'),
            TextField(
              controller: prodiController,
              decoration: _inputDecoration(
                'Masukkan program studi',
                Icons.school_outlined,
              ),
            ),

            const SizedBox(height: 16),

            _buildFormLabel('Semester'),
            DropdownButtonFormField<String>(
              initialValue: _semesterOptions.contains(semester)
                  ? semester
                  : 'Semester 5',
              decoration: _inputDecoration(
                'Pilih semester',
                Icons.menu_book_outlined,
              ),
              dropdownColor: Colors.white,
              borderRadius: BorderRadius.circular(14),
              items: _semesterOptions
                  .map(
                    (item) => DropdownMenuItem<String>(
                      value: item,
                      child: Text(
                        item,
                        style: const TextStyle(
                          color: _darkPlum,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => semester = value);
                }
              },
            ),

            const SizedBox(height: 16),

            _buildFormLabel('Email'),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: _inputDecoration(
                'Masukkan alamat email',
                Icons.email_outlined,
              ),
            ),

            const SizedBox(height: 27),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed:
                    sedangMemilihFoto ? null : _simpanPerubahan,
                icon: const Icon(
                  Icons.save_outlined,
                  size: 19,
                ),
                label: const Text(
                  'Simpan Perubahan',
                  style: TextStyle(
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

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              height: 49,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _darkPlum,
                  side: const BorderSide(color: _line),
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Batal',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          label,
          style: const TextStyle(
            color: _darkPlum,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
