import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  // =========================
  // MEMUAT DATA DARI STORAGE
  // =========================
  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();

    final fotoBase64 = prefs.getString('profile_foto');

    if (!mounted) return;

    setState(() {
      nama = prefs.getString('profile_nama') ?? 'Tika Afrilia';
      npm = prefs.getString('profile_npm') ?? '2413025078';
      programStudi = prefs.getString('profile_program_studi') ??
          'Pendidikan Teknologi Informasi';
      semester = prefs.getString('profile_semester') ?? 'Semester 5';
      email = prefs.getString('profile_email') ??
          'tika.afrilia@example.com';

      if (fotoBase64 != null && fotoBase64.isNotEmpty) {
        fotoProfil = base64Decode(fotoBase64);
      }

      isLoading = false;
    });
  }

  // =========================
  // MENYIMPAN DATA KE STORAGE
  // =========================
  Future<void> _saveProfile({
    required String namaBaru,
    required String npmBaru,
    required String programStudiBaru,
    required String semesterBaru,
    required String emailBaru,
    required Uint8List? fotoBaru,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('profile_nama', namaBaru);
    await prefs.setString('profile_npm', npmBaru);
    await prefs.setString(
      'profile_program_studi',
      programStudiBaru,
    );
    await prefs.setString(
      'profile_semester',
      semesterBaru,
    );
    await prefs.setString('profile_email', emailBaru);

    if (fotoBaru != null) {
      final fotoBase64 = base64Encode(fotoBaru);
      await prefs.setString('profile_foto', fotoBase64);
    } else {
      await prefs.remove('profile_foto');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Diri'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // =========================
            // FOTO PROFIL
            // =========================
            CircleAvatar(
              radius: 60,
              backgroundColor: const Color(0xFFEAF4FF),
              backgroundImage: fotoProfil != null
                  ? MemoryImage(fotoProfil!)
                  : null,
              child: fotoProfil == null
                  ? const Icon(
                      Icons.person,
                      size: 60,
                      color: Color(0xFF6EA8FE),
                    )
                  : null,
            ),

            const SizedBox(height: 16),

            Text(
              nama,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 4),

            const Text(
              'Mahasiswa',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 15,
              ),
            ),

            const SizedBox(height: 30),

            // =========================
            // DATA DIRI
            // =========================
            _buildInfoCard(
              icon: Icons.person_outline,
              title: 'Nama Lengkap',
              value: nama,
            ),

            _buildInfoCard(
              icon: Icons.badge_outlined,
              title: 'NPM',
              value: npm,
            ),

            _buildInfoCard(
              icon: Icons.school_outlined,
              title: 'Program Studi',
              value: programStudi,
            ),

            _buildInfoCard(
              icon: Icons.menu_book_outlined,
              title: 'Semester',
              value: semester,
            ),

            _buildInfoCard(
              icon: Icons.email_outlined,
              title: 'Email',
              value: email,
            ),

            const SizedBox(height: 20),

            // =========================
            // TOMBOL EDIT
            // =========================
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final hasil = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditDataDiriScreen(
                        nama: nama,
                        npm: npm,
                        programStudi: programStudi,
                        semester: semester,
                        email: email,
                        fotoProfil: fotoProfil,
                      ),
                    ),
                  );

                  if (hasil != null && hasil is Map) {
                    final namaBaru = hasil['nama'] as String;
                    final npmBaru = hasil['npm'] as String;
                    final programStudiBaru =
                        hasil['programStudi'] as String;
                    final semesterBaru =
                        hasil['semester'] as String;
                    final emailBaru =
                        hasil['email'] as String;
                    final fotoBaru =
                        hasil['fotoProfil'] as Uint8List?;

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
                      fotoProfil = fotoBaru;
                    });
                  }
                },
                icon: const Icon(Icons.edit),
                label: const Text('Edit Data Diri'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFEAF4FF),
          child: Icon(
            icon,
            color: const Color(0xFF6EA8FE),
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.grey,
          ),
        ),
        subtitle: Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
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

class _EditDataDiriScreenState
    extends State<EditDataDiriScreen> {
  late TextEditingController namaController;
  late TextEditingController npmController;
  late TextEditingController prodiController;
  late TextEditingController emailController;

  late String semester;

  Uint8List? fotoSementara;

  @override
  void initState() {
    super.initState();

    namaController =
        TextEditingController(text: widget.nama);

    npmController =
        TextEditingController(text: widget.npm);

    prodiController =
        TextEditingController(text: widget.programStudi);

    emailController =
        TextEditingController(text: widget.email);

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

  // =========================
  // PILIH FOTO DARI LAPTOP
  // =========================
  Future<void> _pilihFoto() async {
    final ImagePicker picker = ImagePicker();

    final XFile? foto = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (foto == null) {
      return;
    }

    final Uint8List bytes = await foto.readAsBytes();

    if (!mounted) return;

    setState(() {
      fotoSementara = bytes;
    });
  }

  // =========================
  // SIMPAN PERUBAHAN
  // =========================
  void _simpanPerubahan() {
    Navigator.pop(
      context,
      {
        'nama': namaController.text.trim(),
        'npm': npmController.text.trim(),
        'programStudi': prodiController.text.trim(),
        'semester': semester,
        'email': emailController.text.trim(),
        'fotoProfil': fotoSementara,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Data Diri'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // =========================
            // PREVIEW FOTO
            // =========================
            CircleAvatar(
              radius: 60,
              backgroundColor: const Color(0xFFEAF4FF),
              backgroundImage: fotoSementara != null
                  ? MemoryImage(fotoSementara!)
                  : null,
              child: fotoSementara == null
                  ? const Icon(
                      Icons.person,
                      size: 60,
                      color: Color(0xFF6EA8FE),
                    )
                  : null,
            ),

            const SizedBox(height: 12),

            TextButton.icon(
              onPressed: _pilihFoto,
              icon: const Icon(
                Icons.camera_alt_outlined,
              ),
              label: const Text('Ubah Foto Profil'),
            ),

            const SizedBox(height: 25),

            // =========================
            // NAMA
            // =========================
            TextField(
              controller: namaController,
              decoration: const InputDecoration(
                labelText: 'Nama Lengkap',
                prefixIcon: Icon(
                  Icons.person_outline,
                ),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            // =========================
            // NPM
            // =========================
            TextField(
              controller: npmController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'NPM',
                prefixIcon: Icon(
                  Icons.badge_outlined,
                ),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            // =========================
            // PROGRAM STUDI
            // =========================
            TextField(
              controller: prodiController,
              decoration: const InputDecoration(
                labelText: 'Program Studi',
                prefixIcon: Icon(
                  Icons.school_outlined,
                ),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            // =========================
            // SEMESTER
            // =========================
            DropdownButtonFormField<String>(
              initialValue: semester,
              decoration: const InputDecoration(
                labelText: 'Semester',
                prefixIcon: Icon(
                  Icons.menu_book_outlined,
                ),
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'Semester 1',
                  child: Text('Semester 1'),
                ),
                DropdownMenuItem(
                  value: 'Semester 2',
                  child: Text('Semester 2'),
                ),
                DropdownMenuItem(
                  value: 'Semester 3',
                  child: Text('Semester 3'),
                ),
                DropdownMenuItem(
                  value: 'Semester 4',
                  child: Text('Semester 4'),
                ),
                DropdownMenuItem(
                  value: 'Semester 5',
                  child: Text('Semester 5'),
                ),
                DropdownMenuItem(
                  value: 'Semester 6',
                  child: Text('Semester 6'),
                ),
                DropdownMenuItem(
                  value: 'Semester 7',
                  child: Text('Semester 7'),
                ),
                DropdownMenuItem(
                  value: 'Semester 8',
                  child: Text('Semester 8'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    semester = value;
                  });
                }
              },
            ),

            const SizedBox(height: 16),

            // =========================
            // EMAIL
            // =========================
            TextField(
              controller: emailController,
              keyboardType:
                  TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(
                  Icons.email_outlined,
                ),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 30),

            // =========================
            // SIMPAN
            // =========================
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _simpanPerubahan,
                icon: const Icon(
                  Icons.save_outlined,
                ),
                label: const Text(
                  'Simpan Perubahan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // =========================
            // BATAL
            // =========================
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Batal'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}