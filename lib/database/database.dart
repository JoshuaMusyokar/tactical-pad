import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:tactical_pad/models/project.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _database;
  DatabaseHelper._init();

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'tactical_pad.db');
    print('Initializing the database at $path');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE projects (
        id TEXT PRIMARY KEY,
        name TEXT,
        createdAt TEXT,
        updatedAt TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE frames (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        projectId TEXT,
        playerPositions TEXT,
        coachPositions TEXT,
        conePositions TEXT,
        ballPositions TEXT,
        timestamp TEXT,
        FOREIGN KEY (projectId) REFERENCES projects (id)
      )
    ''');

    print('===========Tables have been created successfully========.');
  }

  Future<int> insertProject(Map<String, dynamic> project) async {
    final db = await database;
    print('Inserting project with id: ${project['id']}');
    return await db.insert('projects', project);
  }

  Future<Project?> getProject(String id) async {
    final db = await database;
    final result = await db.query(
      'projects',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      print('Project found with id: $id');
      return Project.fromMap(result.first);
    }

    print('No project found with id: $id');
    return null;
  }

  Future<int> updateProject(Map<String, dynamic> project) async {
    final db = await database;
    print('Updating project with id: ${project['id']}');
    return await db.update(
      'projects',
      {
        'id': project['id'],
        'name': project['name'],
        'updatedAt': project['updatedAt'],
      },
      where: 'id = ?',
      whereArgs: [project['id']],
    );
  }

  Future<int> deleteProject(String id) async {
    final db = await database;
    print('Deleting project with id: $id');
    return await db.delete(
      'projects',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> insertFrame(Map<String, dynamic> frame) async {
    final db = await database;
    print('Inserting frame for projectId: ${frame['projectId']}');
    return await db.insert('frames', frame);
  }

  Future<List<Map<String, dynamic>>> getFrames(String projectId) async {
    final db = await database;
    print('Retrieving frames for projectId: $projectId');
    return await db.query(
      'frames',
      where: 'projectId = ?',
      whereArgs: [projectId],
    );
  }
}
