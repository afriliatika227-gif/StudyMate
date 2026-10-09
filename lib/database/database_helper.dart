
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  DatabaseHelper._privateConstructor();

  static final DatabaseHelper instance =
      DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'studymate.db');

    return openDatabase(
      path,
      version: 4,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE courses (
        course_id INTEGER PRIMARY KEY AUTOINCREMENT,
        course_name TEXT NOT NULL,
        course_code TEXT NOT NULL,
        lecturer_name TEXT NOT NULL,
        semester INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE schedules (
        schedule_id INTEGER PRIMARY KEY AUTOINCREMENT,
        course_id INTEGER NOT NULL,
        day TEXT NOT NULL,
        start_time TEXT NOT NULL,
        end_time TEXT NOT NULL,
        room TEXT NOT NULL,
        FOREIGN KEY(course_id)
          REFERENCES courses(course_id)
          ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE tasks (
        task_id INTEGER PRIMARY KEY AUTOINCREMENT,
        course_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        deadline TEXT NOT NULL,
        deadline_time TEXT NOT NULL DEFAULT '23:59',
        status TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY(course_id)
          REFERENCES courses(course_id)
          ON DELETE CASCADE
      )
    ''');

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
      'program_studi': 'PTI',
      'semester': '5',
      'email': 'tika.afrilia@example.com',
      'foto': null,
    });

    final courses = [
      {
        'course_name': 'Pemrograman Mobile',
        'course_code': 'PM',
        'lecturer_name': '-',
        'semester': 5,
      },
      {
        'course_name': 'Internet of Things',
        'course_code': 'IoT',
        'lecturer_name': '-',
        'semester': 5,
      },
      {
        'course_name': 'Metodologi Penelitian',
        'course_code': 'MP',
        'lecturer_name': '-',
        'semester': 5,
      },
      {
        'course_name': 'Statistika Pendidikan',
        'course_code': 'SP',
        'lecturer_name': '-',
        'semester': 5,
      },
      {
        'course_name': 'Perencanaan Pembelajaran',
        'course_code': 'PP',
        'lecturer_name': '-',
        'semester': 5,
      },
      {
        'course_name': 'Jaringan Komputer',
        'course_code': 'JK',
        'lecturer_name': '-',
        'semester': 5,
      },
    ];

    for (final course in courses) {
      await db.insert('courses', course);
    }
  }

  Future<void> _upgradeDB(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      final result = await db.query('courses');

      if (result.isEmpty) {
        final courses = [
          {
            'course_name': 'Pemrograman Mobile',
            'course_code': 'PM',
            'lecturer_name': '-',
            'semester': 5,
          },
          {
            'course_name': 'Internet of Things',
            'course_code': 'IoT',
            'lecturer_name': '-',
            'semester': 5,
          },
          {
            'course_name': 'Metodologi Penelitian',
            'course_code': 'MP',
            'lecturer_name': '-',
            'semester': 5,
          },
          {
            'course_name': 'Statistika Pendidikan',
            'course_code': 'SP',
            'lecturer_name': '-',
            'semester': 5,
          },
          {
            'course_name': 'Perencanaan Pembelajaran',
            'course_code': 'PP',
            'lecturer_name': '-',
            'semester': 5,
          },
          {
            'course_name': 'Jaringan Komputer',
            'course_code': 'JK',
            'lecturer_name': '-',
            'semester': 5,
          },
        ];

        for (final course in courses) {
          await db.insert('courses', course);
        }
      }
    }

    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS profile (
          profile_id INTEGER PRIMARY KEY,
          nama TEXT NOT NULL,
          npm TEXT NOT NULL,
          program_studi TEXT NOT NULL,
          semester TEXT NOT NULL,
          email TEXT NOT NULL,
          foto BLOB
        )
      ''');

      final profiles = await db.query(
        'profile',
        where: 'profile_id = ?',
        whereArgs: [1],
      );

      if (profiles.isEmpty) {
        await db.insert('profile', {
          'profile_id': 1,
          'nama': 'Tika Afrilia',
          'npm': '2413025078',
          'program_studi': 'PTI',
          'semester': '5',
          'email': 'tika.afrilia@example.com',
          'foto': null,
        });
      }
    }

    if (oldVersion < 4) {
      await db.execute('''
        ALTER TABLE tasks
        ADD COLUMN deadline_time TEXT NOT NULL DEFAULT '23:59'
      ''');
    }
  }

  // =========================
  // CRUD MATA KULIAH
  // =========================

  Future<int> insertCourse(
    Map<String, dynamic> course,
  ) async {
    final db = await database;
    return db.insert('courses', course);
  }

  Future<List<Map<String, dynamic>>> getCourses() async {
    final db = await database;
    return db.query('courses', orderBy: 'course_id ASC');
  }

  Future<Map<String, dynamic>?> getCourse(int id) async {
    final db = await database;
    final result = await db.query(
      'courses',
      where: 'course_id = ?',
      whereArgs: [id],
    );

    return result.isEmpty ? null : result.first;
  }

  Future<int> updateCourse(
    int id,
    Map<String, dynamic> course,
  ) async {
    final db = await database;
    return db.update(
      'courses',
      course,
      where: 'course_id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteCourse(int id) async {
    final db = await database;
    return db.delete(
      'courses',
      where: 'course_id = ?',
      whereArgs: [id],
    );
  }

  // =========================
  // CRUD TUGAS
  // =========================

  Future<List<Map<String, dynamic>>> getTasks() async {
    final db = await database;

    return db.rawQuery('''
      SELECT
        tasks.task_id,
        tasks.title,
        tasks.description,
        tasks.deadline,
        tasks.deadline_time,
        tasks.status,
        tasks.created_at,
        courses.course_name
      FROM tasks
      INNER JOIN courses
        ON tasks.course_id = courses.course_id
      ORDER BY tasks.task_id DESC
    ''');
  }

  Future<int> insertTask({
    required String courseName,
    required String title,
    required String description,
    required String deadline,
    required String deadlineTime,
    required String status,
  }) async {
    final db = await database;

    final courses = await db.query(
      'courses',
      columns: ['course_id'],
      where: 'course_name = ?',
      whereArgs: [courseName],
      limit: 1,
    );

    if (courses.isEmpty) {
      throw Exception('Mata kuliah tidak ditemukan.');
    }

    return db.insert('tasks', {
      'course_id': courses.first['course_id'],
      'title': title,
      'description': description,
      'deadline': deadline,
      'deadline_time': deadlineTime,
      'status': status,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<int> updateTask({
    required int taskId,
    required String courseName,
    required String title,
    required String description,
    required String deadline,
    required String deadlineTime,
    required String status,
  }) async {
    final db = await database;

    final courses = await db.query(
      'courses',
      columns: ['course_id'],
      where: 'course_name = ?',
      whereArgs: [courseName],
      limit: 1,
    );

    if (courses.isEmpty) {
      throw Exception('Mata kuliah tidak ditemukan.');
    }

    return db.update(
      'tasks',
      {
        'course_id': courses.first['course_id'],
        'title': title,
        'description': description,
        'deadline': deadline,
        'deadline_time': deadlineTime,
        'status': status,
      },
      where: 'task_id = ?',
      whereArgs: [taskId],
    );
  }

  Future<int> updateTaskStatus(
    int taskId,
    String status,
  ) async {
    final db = await database;

    return db.update(
      'tasks',
      {'status': status},
      where: 'task_id = ?',
      whereArgs: [taskId],
    );
  }

  Future<int> deleteTask(int taskId) async {
    final db = await database;

    return db.delete(
      'tasks',
      where: 'task_id = ?',
      whereArgs: [taskId],
    );
  }

  // =========================
  // CRUD PROFIL
  // =========================

  Future<Map<String, dynamic>?> getProfile() async {
    final db = await database;

    final result = await db.query(
      'profile',
      where: 'profile_id = ?',
      whereArgs: [1],
    );

    return result.isEmpty ? null : result.first;
  }

  Future<int> updateProfile(
    Map<String, dynamic> profile,
  ) async {
    final db = await database;

    return db.update(
      'profile',
      profile,
      where: 'profile_id = ?',
      whereArgs: [1],
    );
  }

  // =========================
  // TUTUP DATABASE
  // =========================

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}