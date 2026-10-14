
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

const Color pastelBackground = Color(0xFFF7F6FF);
const Color pastelLavender = Color(0xFF8B8FE8);
const Color pastelDark = Color(0xFF414778);
const Color pastelMuted = Color(0xFF8587A5);

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
    if (!berhasil) throw Exception('Gagal menyimpan nama.');

    await prefs.setString('profile_npm', npmBaru);
    await prefs.setString('profile_program_studi', programStudiBaru);
    await prefs.setString('profile_semester', semesterBaru);
    await prefs.setString('profile_email', emailBaru);

    // Foto lama tetap dipertahankan jika tidak memilih foto baru.
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
          backgroundColor: Color(0xFF65A895),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data gagal disimpan. Silakan coba kembali.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: pastelBackground,
        body: Center(
          child: CircularProgressIndicator(
            color: pastelLavender,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: pastelBackground,
      appBar: AppBar(
        title: const Text(
          'Data Diri',
          style: TextStyle(
            color: pastelDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: pastelBackground,
        foregroundColor: pastelDark,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 28),
            const Text(
              'Informasi Pribadi',
              style: TextStyle(
                color: pastelDark,
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Berikut adalah informasi data dirimu.',
              style: TextStyle(
                color: pastelMuted,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 18),
            _buildInfoCard(
              icon: Icons.person_outline_rounded,
              title: 'Nama Lengkap',
              value: nama,
              iconColor: const Color(0xFF8988E8),
              iconBackground: const Color(0xFFECEBFF),
            ),
            _buildInfoCard(
              icon: Icons.badge_outlined,
              title: 'NPM',
              value: npm,
              iconColor: const Color(0xFF639DDC),
              iconBackground: const Color(0xFFE5F2FF),
            ),
            _buildInfoCard(
              icon: Icons.school_outlined,
              title: 'Program Studi',
              value: programStudi,
              iconColor: const Color(0xFF9A83D5),
              iconBackground: const Color(0xFFF0E9FF),
            ),
            _buildInfoCard(
              icon: Icons.menu_book_rounded,
              title: 'Semester',
              value: semester,
              iconColor: const Color(0xFF5BABB0),
              iconBackground: const Color(0xFFE3F7F5),
            ),
            _buildInfoCard(
              icon: Icons.email_outlined,
              title: 'Email',
              value: email,
              iconColor: const Color(0xFFE09AB6),
              iconBackground: const Color(0xFFFFEDF4),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 54,
              child: ElevatedButton.icon(
                onPressed: _bukaEditDataDiri,
                icon: const Icon(
                  Icons.edit_rounded,
                  size: 19,
                ),
                label: const Text(
                  'Edit Data Diri',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: pastelLavender,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
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
        vertical: 28,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFE9E8FF),
            Color(0xFFE5F2FF),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: pastelLavender.withValues(alpha: 0.20),
                  blurRadius: 18,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 51,
              backgroundColor: const Color(0xFFDCDFFF),
              backgroundImage:
                  fotoProfil != null ? MemoryImage(fotoProfil!) : null,
              child: fotoProfil == null
                  ? const Icon(
                      Icons.person_rounded,
                      size: 55,
                      color: pastelLavender,
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            nama,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: pastelDark,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.school_rounded,
                  size: 16,
                  color: pastelLavender,
                ),
                SizedBox(width: 6),
                Text(
                  'Mahasiswa',
                  style: TextStyle(
                    color: pastelDark,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            npm,
            style: const TextStyle(
              color: pastelDark,
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
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFECEBFA),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7775B8).withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 47,
            height: 47,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 23,
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
                    color: pastelMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  value,
                  style: const TextStyle(
                    color: pastelDark,
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
      prefixIcon: Icon(
        icon,
        color: const Color(0xFFABAFEE),
      ),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Color(0xFFE6E4F8),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Color(0xFFE6E4F8),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: pastelLavender,
          width: 1.5,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pastelBackground,
      appBar: AppBar(
        title: const Text(
          'Edit Data Diri',
          style: TextStyle(
            color: pastelDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: pastelBackground,
        foregroundColor: pastelDark,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: pastelLavender.withValues(alpha: 0.15),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 55,
                backgroundColor: const Color(0xFFE9E8FF),
                backgroundImage: fotoSementara != null
                    ? MemoryImage(fotoSementara!)
                    : null,
                child: fotoSementara == null
                    ? const Icon(
                        Icons.person_rounded,
                        size: 58,
                        color: pastelLavender,
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: sedangMemilihFoto ? null : _pilihFoto,
              icon: sedangMemilihFoto
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.camera_alt_outlined),
              label: Text(
                sedangMemilihFoto
                    ? 'Memuat Foto...'
                    : 'Ubah Foto Profil',
              ),
              style: TextButton.styleFrom(
                foregroundColor: pastelLavender,
              ),
            ),
            const SizedBox(height: 22),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFEDEBFF),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.edit_note_rounded,
                    color: pastelLavender,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Perbarui informasi pribadimu di bawah ini.',
                      style: TextStyle(
                        color: pastelDark,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            TextField(
              controller: namaController,
              decoration: _inputDecoration(
                'Nama Lengkap',
                Icons.person_outline,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: npmController,
              keyboardType: TextInputType.number,
              decoration: _inputDecoration(
                'NPM',
                Icons.badge_outlined,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: prodiController,
              decoration: _inputDecoration(
                'Program Studi',
                Icons.school_outlined,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: semesterOptions.contains(semester)
                  ? semester
                  : 'Semester 5',
              decoration: _inputDecoration(
                'Semester',
                Icons.menu_book_outlined,
              ),
              dropdownColor: Colors.white,
              borderRadius: BorderRadius.circular(16),
              items: semesterOptions
                  .map(
                    (item) => DropdownMenuItem<String>(
                      value: item,
                      child: Text(item),
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
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: _inputDecoration(
                'Email',
                Icons.email_outlined,
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed:
                    sedangMemilihFoto ? null : _simpanPerubahan,
                icon: const Icon(Icons.save_outlined),
                label: const Text(
                  'Simpan Perubahan',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: pastelLavender,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(17),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: pastelDark,
                  side: const BorderSide(
                    color: Color(0xFFDCD9F5),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(17),
                  ),
                ),
                child: const Text('Batal'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

const List<String> semesterOptions = [
  'Semester 1',
  'Semester 2',
  'Semester 3',
  'Semester 4',
  'Semester 5',
  'Semester 6',
  'Semester 7',
  'Semester 8',
];
