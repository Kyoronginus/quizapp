import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    String path = join(await getDatabasesPath(), 'quiz.db');
    bool exists = await databaseExists(path); // Check if the database file exists

    if (!exists) {
      // If the database file doesn't exist, create it and call createDB method
      print('Database does not exist. Creating database and initializing schema...');
      _database = await openDatabase(
        path,
        version: 1,
        onCreate: _createDb,
      );
    } else {
      // If the database file exists, open it directly
      print('Database exists. Opening existing database...');
      _database = await openDatabase(path);
    }

    // Always add questions to the database
    await _addQuestionsToDatabase();

    return _database!;
  }

  Future<void> _createDb(Database db, int version) async {
    // Create tables
    await db.execute('''
      CREATE TABLE Questions (
        id INTEGER PRIMARY KEY,
        question TEXT,
        option1 TEXT,
        option2 TEXT,
        option3 TEXT,
        correctAnswer INTEGER
      )
    ''');

    // Insert sample data
    await _addQuestionsToDatabase();
  }

  Future<void> _addQuestionsToDatabase() async {
    List<Map<String, dynamic>> questions = [

    ];

    for (var question in questions) {
      await _database!.insert('Questions', question);
    }
  }

  Future<List<Map<String, dynamic>>> getQuestions() async {
    final db = await database;
    return await db.query('Questions');
  }

  Future<void> printAllQuestions() async {
    String databasePath = await getDatabasesPath();
    print('Database path: $databasePath');
    final questions = await getQuestions();
    print('All Questions:');
    questions.forEach((question) {
      print('ID: ${question['id']}');
      print('Question: ${question['question']}');
      print('Option 1: ${question['option1']}');
      print('Option 2: ${question['option2']}');
      print('Option 3: ${question['option3']}');
      print('Correct Answer: ${question['correctAnswer']}');
      print('');
    });
  }
}
