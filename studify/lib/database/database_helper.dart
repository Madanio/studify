import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';
import '../models/student.dart';
import '../models/absence.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('studify.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Table des utilisateurs
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        type TEXT NOT NULL,
        parentEmail TEXT
      )
    ''');

    // Table des étudiants
    await db.execute('''
      CREATE TABLE students (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        studentId TEXT UNIQUE NOT NULL,
        parentEmail TEXT
      )
    ''');

    // Table des absences
    await db.execute('''
      CREATE TABLE absences (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        studentId TEXT NOT NULL,
        date TEXT NOT NULL,
        reason TEXT,
        type TEXT NOT NULL,
        subject TEXT,
        FOREIGN KEY (studentId) REFERENCES students (studentId)
      )
    ''');

    // Données initiales
    await _insertInitialData(db);
  }

  Future<void> _insertInitialData(Database db) async {
    try {
      // Admin par défaut
      await db.insert('users', {
        'username': 'admin',
        'password': 'admin123',
        'type': 'admin',
        'parentEmail': null,
      });

      // Étudiant de test
      await db.insert('students', {
        'name': 'Jean Dupont',
        'studentId': 'STU001',
        'parentEmail': 'parent@example.com',
      });

      await db.insert('users', {
        'username': 'STU001',
        'password': 'student123',
        'type': 'student',
        'parentEmail': 'parent@example.com',
      });

      // Parent de test
      await db.insert('users', {
        'username': 'parent@example.com',
        'password': 'parent123',
        'type': 'parent',
        'parentEmail': null,
      });

      // Quelques absences de test
      final now = DateTime.now();
      await db.insert('absences', {
        'studentId': 'STU001',
        'date': now.subtract(const Duration(days: 2)).toIso8601String(),
        'reason': 'Maladie',
        'type': 'justified',
        'subject': 'Mathématiques',
      });

      await db.insert('absences', {
        'studentId': 'STU001',
        'date': now.subtract(const Duration(days: 5)).toIso8601String(),
        'reason': null,
        'type': 'unjustified',
        'subject': 'Histoire',
      });
    } catch (e) {
      // Ignore errors if data already exists
      // Data might already exist, which is fine
    }
  }

  // Méthodes pour les utilisateurs
  Future<User?> getUser(String username, String password) async {
    final db = await database;
    final maps = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Student>> getAllStudents() async {
    final db = await database;
    final maps = await db.query('students');
    return maps.map((map) => Student.fromMap(map)).toList();
  }

  Future<Student?> getStudent(String studentId) async {
    final db = await database;
    final maps = await db.query(
      'students',
      where: 'studentId = ?',
      whereArgs: [studentId],
    );

    if (maps.isNotEmpty) {
      return Student.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Student>> getStudentsByParent(String parentEmail) async {
    final db = await database;
    final maps = await db.query(
      'students',
      where: 'parentEmail = ?',
      whereArgs: [parentEmail],
    );
    return maps.map((map) => Student.fromMap(map)).toList();
  }

  // Méthodes pour les absences
  Future<List<Absence>> getAbsencesByStudent(String studentId) async {
    final db = await database;
    final maps = await db.query(
      'absences',
      where: 'studentId = ?',
      whereArgs: [studentId],
      orderBy: 'date DESC',
    );
    return maps.map((map) => Absence.fromMap(map)).toList();
  }

  Future<int> insertAbsence(Absence absence) async {
    final db = await database;
    return await db.insert('absences', absence.toMap());
  }

  Future<int> updateAbsence(Absence absence) async {
    final db = await database;
    return await db.update(
      'absences',
      absence.toMap(),
      where: 'id = ?',
      whereArgs: [absence.id],
    );
  }

  Future<int> deleteAbsence(int id) async {
    final db = await database;
    return await db.delete(
      'absences',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> insertStudent(Student student) async {
    final db = await database;
    return await db.insert('students', student.toMap());
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
