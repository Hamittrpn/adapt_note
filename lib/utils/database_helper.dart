import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:synchronized/synchronized.dart';

class DatabaseHelper {
  static DatabaseHelper _databaseHelper;
  static Database _database;

  factory DatabaseHelper() {
    if (_databaseHelper == null) {
      _databaseHelper = DatabaseHelper._internal();
      return _databaseHelper;
    } else {
      return _databaseHelper;
    }
  }

  DatabaseHelper._internal();

  Future<Database> _getDatabase() async {
    if (_database == null) {
      _database = await _initializeDatabase();
      return _database;
    } else {
      return _database;
    }
  }

  _initializeDatabase() async {
    var lock = Lock();
    Database _db;

    if (_db == null) {
      await lock.synchronized(() async {
        if (_db == null) {
          var databasePath = await getDatabasesPath();
          var path = join(databasePath, "appDB.db");
          var file = new File(path);

          if (!await file.exists()) {
            ByteData data = await rootBundle.load(join("assets", "notes.db"));
            List<int> bytes =
                data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
            await new File(path).writeAsBytes(bytes);
          }
          _db = await openDatabase(path);
        }
      });
    }

    return _db;
  }
}
