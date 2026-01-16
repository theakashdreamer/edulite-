import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DraftDatabase {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;

    final path = join(await getDatabasesPath(), 'drafts.db');

    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE drafts (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            from_email TEXT,
            to_email TEXT,
            subject TEXT,
            delta TEXT,
            updated_at TEXT
          )
        ''');
      },
    );

    return _db!;
  }
}
