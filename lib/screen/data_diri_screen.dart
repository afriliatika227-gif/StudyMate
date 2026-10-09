
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

  // Memuat data profil dari penyimpanan lokal.
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
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal memuat data diri.'),
        ),
      );
    }
  }

  // Menyimpan data profil.
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

    // Jika foto null, jangan hapus foto lama secara otomatis.
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
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Data gagal disimpan. Silakan coba kembali.',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
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
            CircleAvatar(
              radius: 60,
              backgroundColor: const Color(0xFFEAF4FF),
              backgroundImage:
                  fotoProfil != null ? MemoryImage(fotoProfil!) : null,
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
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Mahasiswa',
              style: TextStyle(color: Colors.grey, fontSize: 15),
            ),
            const SizedBox(height: 30),

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

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _bukaEditDataDiri,
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
    prodiController = TextEditingController(text: widget.programStudi);
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

  // Memilih foto dari laptop atau perangkat.
  Future<void> _pilihFoto() async {
    if (sedangMemilihFoto) return;

    setState(() {
      sedangMemilihFoto = true;
    });

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

      setState(() {
        fotoSementara = bytes;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Foto gagal dibuka. Coba pilih gambar JPG atau PNG.',
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          sedangMemilihFoto = false;
        });
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
            ),

            const SizedBox(height: 25),

            TextField(
              controller: namaController,
              decoration: const InputDecoration(
                labelText: 'Nama Lengkap',
                prefixIcon: Icon(Icons.person_outline),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: npmController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'NPM',
                prefixIcon: Icon(Icons.badge_outlined),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: prodiController,
              decoration: const InputDecoration(
                labelText: 'Program Studi',
                prefixIcon: Icon(Icons.school_outlined),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              initialValue: semesterOptions.contains(semester)
                  ? semester
                  : 'Semester 5',
              decoration: const InputDecoration(
                labelText: 'Semester',
                prefixIcon: Icon(Icons.menu_book_outlined),
                border: OutlineInputBorder(),
              ),
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
                  setState(() {
                    semester = value;
                  });
                }
              },
            ),

            const SizedBox(height: 16),

            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email_outlined),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: sedangMemilihFoto
                    ? null
                    : _simpanPerubahan,
                icon: const Icon(Icons.save_outlined),
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

            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
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