import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:path/path.dart';

class ContriDatabase {
  static final ContriDatabase instance = ContriDatabase._init();

  ContriDatabase._init();

  static sqflite.Database? _database;

  Future<sqflite.Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('contri.db');
    return _database!;
  }

  Future<sqflite.Database> _initDB(String filePath) async {
    final dbPath = await sqflite.getDatabasesPath();
    final path = join(dbPath, filePath);
    return await sqflite.openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(sqflite.Database db, int version) async {
    await db.execute('''
      CREATE TABLE sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        tax REAL NOT NULL,
        tip REAL NOT NULL,
        color INTEGER NOT NULL DEFAULT 0
      )
    ''');
    await db.execute('''
      CREATE TABLE diners (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        session_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        FOREIGN KEY (session_id) REFERENCES sessions(id)
      )
    ''');
    await db.execute('''
      CREATE TABLE dishes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        session_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        price REAL NOT NULL,
        FOREIGN KEY (session_id) REFERENCES sessions(id)
      )
    ''');
    await db.execute('''
      CREATE TABLE assignments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        session_id INTEGER NOT NULL,
        diner_id INTEGER NOT NULL,
        dish_id INTEGER NOT NULL,
        FOREIGN KEY (session_id) REFERENCES sessions(id),
        FOREIGN KEY (diner_id) REFERENCES diners(id),
        FOREIGN KEY (dish_id) REFERENCES dishes(id)
      )
    ''');
  }

  Future<int> addSession(Map<String, dynamic> sessionData) async {
    final db = await instance.database;
    final sessionId = await db.insert('sessions', {
      'date': sessionData['date'],
      'tax': sessionData['tax'],
      'tip': sessionData['tip'],
      'color': sessionData['color'],
    });

    final dinerIds = <int>[];
    for (var diner in sessionData['diners']) {
      final dinerId = await db.insert('diners', {
        'session_id': sessionId,
        'name': diner['name'],
      });
      dinerIds.add(dinerId);
    }

    final dishIds = <int>[];
    for (var dish in sessionData['dishes']) {
      final dishId = await db.insert('dishes', {
        'session_id': sessionId,
        'name': dish['name'],
        'quantity': dish['quantity'],
        'price': dish['price'],
      });
      dishIds.add(dishId);
    }

    for (var i = 0; i < sessionData['diners'].length; i++) {
      final diner = sessionData['diners'][i];
      for (var dishIndex in diner['dishes']) {
        await db.insert('assignments', {
          'session_id': sessionId,
          'diner_id': dinerIds[i],
          'dish_id': dishIds[dishIndex],
        });
      }
    }

    return sessionId;
  }

  Future<List<Map<String, dynamic>>> getSessions() async {
    final db = await instance.database;
    final sessions = await db.query('sessions', orderBy: 'date DESC');

    final result = <Map<String, dynamic>>[];
    for (var session in sessions) {
      final diners = await db.query(
        'diners',
        where: 'session_id = ?',
        whereArgs: [session['id']],
      );
      final dishes = await db.query(
        'dishes',
        where: 'session_id = ?',
        whereArgs: [session['id']],
      );
      final assignments = await db.query(
        'assignments',
        where: 'session_id = ?',
        whereArgs: [session['id']],
      );

      final assignmentMatrix = List.generate(
        dishes.length,
            (_) => List.filled(diners.length, false),
      );
      for (var assignment in assignments) {
        final dinerIndex = diners.indexWhere((d) => d['id'] == assignment['diner_id']);
        final dishIndex = dishes.indexWhere((d) => d['id'] == assignment['dish_id']);
        if (dinerIndex != -1 && dishIndex != -1) {
          assignmentMatrix[dishIndex][dinerIndex] = true;
        }
      }

      result.add({
        'id': session['id'],
        'date': session['date'],
        'tax': session['tax'],
        'tip': session['tip'],
        'color': session['color'],
        'diners': diners,
        'dishes': dishes,
        'assignments': assignmentMatrix,
        'diner_count': diners.length,
        'total': session['total'] ?? (dishes.fold<double>(
          0.0,
              (sum, dish) => sum + ((dish['quantity'] as int) * (dish['price'] as double)),
        ) *
            (1 + (session['tax'] as double) / 100) +
            (session['tip'] as double)),
      });
    }

    return result;
  }

  Future<int> updateSession(Map<String, dynamic> sessionData, int id) async {
    final db = await instance.database;
    await db.delete('diners', where: 'session_id = ?', whereArgs: [id]);
    await db.delete('dishes', where: 'session_id = ?', whereArgs: [id]);
    await db.delete('assignments', where: 'session_id = ?', whereArgs: [id]);

    final result = await db.update(
      'sessions',
      {
        'date': sessionData['date'],
        'tax': sessionData['tax'],
        'tip': sessionData['tip'],
        'color': sessionData['color'],
      },
      where: 'id = ?',
      whereArgs: [id],
    );

    final dinerIds = <int>[];
    for (var diner in sessionData['diners']) {
      final dinerId = await db.insert('diners', {
        'session_id': id,
        'name': diner['name'],
      });
      dinerIds.add(dinerId);
    }

    final dishIds = <int>[];
    for (var dish in sessionData['dishes']) {
      final dishId = await db.insert('dishes', {
        'session_id': id,
        'name': dish['name'],
        'quantity': dish['quantity'],
        'price': dish['price'],
      });
      dishIds.add(dishId);
    }

    for (var i = 0; i < sessionData['diners'].length; i++) {
      final diner = sessionData['diners'][i];
      for (var dishIndex in diner['dishes']) {
        await db.insert('assignments', {
          'session_id': id,
          'diner_id': dinerIds[i],
          'dish_id': dishIds[dishIndex],
        });
      }
    }

    return result;
  }

  Future<int> deleteSession(int id) async {
    final db = await instance.database;
    await db.delete('assignments', where: 'session_id = ?', whereArgs: [id]);
    await db.delete('diners', where: 'session_id = ?', whereArgs: [id]);
    await db.delete('dishes', where: 'session_id = ?', whereArgs: [id]);
    return await db.delete('sessions', where: 'id = ?', whereArgs: [id]);
  }
}