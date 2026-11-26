
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

const Color _biru = Color(0xFF3478C8);
const Color _biruTua = Color(0xFF344054);
const Color _background = Color(0xFFF5F7FA);
const Color _line = Color(0xFFE4E8EF);
const Color _abu = Color(0xFF7C8798);
const Color _lavender = Color(0xFF8870CE);

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
          child: CircularProgressIndicator(color: _biru),
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
            color: _biruTua,
            fontWeight: FontWeight.w600,
            fontSize: 19,
          ),
        ),
        iconTheme: const IconThemeData(color: _biruTua),
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
        padding: const EdgeInsets.fromLTRB(18, 20, 18, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildProfileHeader(),

            const SizedBox(height: 25),

            const Text(
              'Informasi Pribadi',
              style: TextStyle(
                color: _biruTua,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 5),

            const Text(
              'Berikut adalah informasi data dirimu.',
              style: TextStyle(
                color: _abu,
                fontSize: 12,
              ),
            ),

            const SizedBox(height: 16),

            _buildInfoCard(
              icon: Icons.person_outline_rounded,
              title: 'Nama Lengkap',
              value: nama,
              iconColor: _biru,
              iconBackground: const Color(0xFFEAF2FC),
            ),

            _buildInfoCard(
              icon: Icons.badge_outlined,
              title: 'NPM',
              value: npm,
              iconColor: const Color(0xFF8870CE),
              iconBackground: const Color(0xFFF0ECFC),
            ),

            _buildInfoCard(
              icon: Icons.school_outlined,
              title: 'Program Studi',
              value: programStudi,
              iconColor: const Color(0xFF36A875),
              iconBackground: const Color(0xFFE7F6EF),
            ),

            _buildInfoCard(
              icon: Icons.menu_book_outlined,
              title: 'Semester',
              value: semester,
              iconColor: const Color(0xFFE39A42),
              iconBackground: const Color(0xFFFFF3E5),
            ),

            _buildInfoCard(
              icon: Icons.email_outlined,
              title: 'Email',
              value: email,
              iconColor: const Color(0xFFD7799E),
              iconBackground: const Color(0xFFFCECF2),
            ),

            const SizedBox(height: 12),

            SizedBox(
              height: 50,
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
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _biru,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
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
        vertical: 24,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF2FC),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: const Color(0xFFD8E7F8),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: CircleAvatar(
              radius: 48,
              backgroundColor: const Color(0xFFDCEBFC),
              backgroundImage:
                  fotoProfil != null ? MemoryImage(fotoProfil!) : null,
              child: fotoProfil == null
                  ? const Icon(
                      Icons.person_rounded,
                      size: 52,
                      color: _biru,
                    )
                  : null,
            ),
          ),

          const SizedBox(height: 16),

          Text(
            nama,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w600,
              color: _biruTua,
            ),
          ),

          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 13,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(7),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.school_outlined,
                  size: 15,
                  color: _biru,
                ),
                SizedBox(width: 6),
                Text(
                  'Mahasiswa',
                  style: TextStyle(
                    color: _biru,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          Text(
            npm,
            style: const TextStyle(
              color: _biruTua,
              fontSize: 13,
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
      margin: const EdgeInsets.only(bottom: 11),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: _line),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 22,
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: _abu,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  value,
                  style: const TextStyle(
                    color: _biruTua,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
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
        color: _abu,
        fontSize: 13,
      ),
      prefixIcon: Icon(
        icon,
        color: _biru,
        size: 21,
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 15,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: _biru,
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
            color: _biruTua,
            fontWeight: FontWeight.w600,
            fontSize: 19,
          ),
        ),
        iconTheme: const IconThemeData(color: _biruTua),
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
        padding: const EdgeInsets.fromLTRB(18, 22, 18, 30),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: CircleAvatar(
                radius: 52,
                backgroundColor: const Color(0xFFEAF2FC),
                backgroundImage: fotoSementara != null
                    ? MemoryImage(fotoSementara!)
                    : null,
                child: fotoSementara == null
                    ? const Icon(
                        Icons.person_rounded,
                        size: 56,
                        color: _biru,
                      )
                    : null,
              ),
            ),

            const SizedBox(height: 10),

            TextButton.icon(
              onPressed: sedangMemilihFoto ? null : _pilihFoto,
              icon: sedangMemilihFoto
                  ? const SizedBox(
                      width: 17,
                      height: 17,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: _biru,
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
                foregroundColor: _biru,
              ),
            ),

            const SizedBox(height: 18),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF2FC),
                borderRadius: BorderRadius.circular(13),
                border: Border.all(
                  color: const Color(0xFFD8E7F8),
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.edit_note_rounded,
                    color: _biru,
                    size: 22,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Perbarui informasi pribadimu melalui formulir berikut.',
                      style: TextStyle(
                        color: _biruTua,
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            TextField(
              controller: namaController,
              textCapitalization: TextCapitalization.words,
              decoration: _inputDecoration(
                'Nama Lengkap',
                Icons.person_outline,
              ),
            ),

            const SizedBox(height: 14),

            TextField(
              controller: npmController,
              keyboardType: TextInputType.number,
              decoration: _inputDecoration(
                'NPM',
                Icons.badge_outlined,
              ),
            ),

            const SizedBox(height: 14),

            TextField(
              controller: prodiController,
              decoration: _inputDecoration(
                'Program Studi',
                Icons.school_outlined,
              ),
            ),

            const SizedBox(height: 14),

            DropdownButtonFormField<String>(
              initialValue: _semesterOptions.contains(semester)
                  ? semester
                  : 'Semester 5',
              decoration: _inputDecoration(
                'Semester',
                Icons.menu_book_outlined,
              ),
              dropdownColor: Colors.white,
              borderRadius: BorderRadius.circular(12),
              items: _semesterOptions
                  .map(
                    (item) => DropdownMenuItem<String>(
                      value: item,
                      child: Text(
                        item,
                        style: const TextStyle(
                          color: _biruTua,
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

            const SizedBox(height: 14),

            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: _inputDecoration(
                'Email',
                Icons.email_outlined,
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              height: 50,
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
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _biru,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 11),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _biruTua,
                  side: const BorderSide(color: _line),
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Batal',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
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
