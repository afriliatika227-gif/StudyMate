import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  // =========================================================
  // DATABASE
  // =========================================================

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('studymate.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 3,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  // =========================================================
  // MEMBUAT DATABASE BARU
  // =========================================================

  Future<void> _createDB(
    Database db,
    int version,
  ) async {
    // =======================================================
    // TABEL COURSES
    // =======================================================

    await db.execute('''
      CREATE TABLE courses (
        course_id INTEGER PRIMARY KEY AUTOINCREMENT,
        course_name TEXT NOT NULL,
        course_code TEXT NOT NULL,
        lecturer_name TEXT NOT NULL,
        semester INTEGER NOT NULL
      )
    ''');

    // =======================================================
    // TABEL SCHEDULES
    // =======================================================

    await db.execute('''
      CREATE TABLE schedules (
        schedule_id INTEGER PRIMARY KEY AUTOINCREMENT,
        course_id INTEGER NOT NULL,
        day TEXT NOT NULL,
        start_time TEXT NOT NULL,
        end_time TEXT NOT NULL,
        room TEXT NOT NULL,
        FOREIGN KEY (course_id)
          REFERENCES courses (course_id)
          ON DELETE CASCADE
      )
    ''');

    // =======================================================
    // TABEL TASKS
    // =======================================================

    await db.execute('''
      CREATE TABLE tasks (
        task_id INTEGER PRIMARY KEY AUTOINCREMENT,
        course_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        deadline TEXT NOT NULL,
        status TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (course_id)
          REFERENCES courses (course_id)
          ON DELETE CASCADE
      )
    ''');

    // =======================================================
    // TABEL PROFILE
    // =======================================================

    await db.execute('''
      CREATE TABLE profile (
        profile_id INTEGER PRIMARY KEY,
        nama TEXT NOT NULL,
        npm TEXT NOT NULL,
        program_studi TEXT NOT NULL,
        semester TEXT NOT NULL,
        email TEXT NOT NULL,
        foto BLOB
      )
    ''');

    // =======================================================
    // DATA PROFILE AWAL
    // =======================================================

    await db.insert('profile', {
      'profile_id': 1,
      'nama': 'Tika Afrilia',
      'npm': '2413025078',
      'program_studi': 'Pendidikan Teknologi Informasi',
      'semester': 'Semester 5',
      'email': 'tika.afrilia@example.com',
      'foto': null,
    });

    // =======================================================
    // DATA MATA KULIAH AWAL
    // =======================================================

    await _insertInitialCourses(db);
  }

  // =========================================================
  // UPGRADE DATABASE
  // =========================================================

  Future<void> _upgradeDB(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    // -------------------------------------------------------
    // Upgrade dari versi 1 ke versi 2
    // -------------------------------------------------------

    if (oldVersion < 2) {
      final result = await db.query('courses');

      if (result.isEmpty) {
        await _insertInitialCourses(db);
      }
    }

    // -------------------------------------------------------
    // Upgrade dari versi 2 ke versi 3
    // Menambahkan tabel profile
    // -------------------------------------------------------

    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE profile (
          profile_id INTEGER PRIMARY KEY,
          nama TEXT NOT NULL,
          npm TEXT NOT NULL,
          program_studi TEXT NOT NULL,
          semester TEXT NOT NULL,
          email TEXT NOT NULL,
          foto BLOB
        )
      ''');

      await db.insert('profile', {
        'profile_id': 1,
        'nama': 'Tika Afrilia',
        'npm': '2413025078',
        'program_studi': 'Pendidikan Teknologi Informasi',
        'semester': 'Semester 5',
        'email': 'tika.afrilia@example.com',
        'foto': null,
      });
    }
  }

  // =========================================================
  // DATA MATA KULIAH AWAL
  // =========================================================

  Future<void> _insertInitialCourses(
    Database db,
  ) async {
    final initialCourses = [
      {
        'course_name': 'Pemrograman Mobile',
        'course_code': 'PTI501',
        'lecturer_name': 'Dr. Budi Santoso, M.Kom.',
        'semester': 5,
      },
      {
        'course_name': 'Internet of Things',
        'course_code': 'PTI502',
        'lecturer_name': 'Rina Wulandari, M.T.',
        'semester': 5,
      },
      {
        'course_name': 'Metodologi Penelitian',
        'course_code': 'PTI503',
        'lecturer_name': 'Dr. Andi Saputra, M.Pd.',
        'semester': 5,
      },
      {
        'course_name': 'Statistika Pendidikan',
        'course_code': 'PTI504',
        'lecturer_name': 'Siti Rahma, M.Pd.',
        'semester': 5,
      },
      {
        'course_name': 'Perencanaan Pembelajaran',
        'course_code': 'PTI505',
        'lecturer_name': 'Dewi Lestari, M.Pd.',
        'semester': 5,
      },
      {
        'course_name': 'Jaringan Komputer',
        'course_code': 'PTI506',
        'lecturer_name': 'Agus Setiawan, M.Kom.',
        'semester': 5,
      },
    ];

    for (final course in initialCourses) {
      await db.insert(
        'courses',
        course,
      );
    }
  }

  // =========================================================
  // CRUD MATA KULIAH
  // =========================================================

  Future<int> insertCourse(
    Map<String, dynamic> course,
  ) async {
    final db = await database;

    return await db.insert(
      'courses',
      course,
    );
  }

  Future<List<Map<String, dynamic>>> getCourses() async {
    final db = await database;

    return await db.query(
      'courses',
      orderBy: 'course_id ASC',
    );
  }

  Future<Map<String, dynamic>?> getCourse(
    int id,
  ) async {
    final db = await database;

    final result = await db.query(
      'courses',
      where: 'course_id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return result.first;
    }

    return null;
  }

  Future<int> updateCourse(
    int id,
    Map<String, dynamic> course,
  ) async {
    final db = await database;

    return await db.update(
      'courses',
      course,
      where: 'course_id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteCourse(
    int id,
  ) async {
    final db = await database;

    return await db.delete(
      'courses',
      where: 'course_id = ?',
      whereArgs: [id],
    );
  }

  // =========================================================
  // PROFILE
  // =========================================================

  // Mengambil data profile
  Future<Map<String, dynamic>?> getProfile() async {
    final db = await database;

    final result = await db.query(
      'profile',
      where: 'profile_id = ?',
      whereArgs: [1],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return result.first;
    }

    return null;
  }

  // Menyimpan perubahan profile
  Future<int> updateProfile(
    Map<String, dynamic> profile,
  ) async {
    final db = await database;

    return await db.update(
      'profile',
      profile,
      where: 'profile_id = ?',
      whereArgs: [1],
    );
  }

  // =========================================================
  // CLOSE DATABASE
  // =========================================================

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}