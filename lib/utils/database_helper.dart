import 'dart:io';
import 'package:adapt_note/models/category.dart';
import 'package:adapt_note/models/note.dart';
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

  Future<Database> _initializeDatabase() async {
    var databasePath = await getDatabasesPath();
    var path = join(databasePath, "notes.db");

    var exists = await databaseExists(path);
    if (!exists) {
      print("Creating new copy from asset");

      try {
        await Directory(dirname(path)).create(recursive: true);
      } catch (_) {}

      //Copy from asset
      ByteData data = await rootBundle.load(join("assets", "notes.db"));
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      await File(path).writeAsBytes(bytes, flush: true);
    } else {
      print("Opening existing database");
    }

    return await openDatabase(path, readOnly: false);
  }

  //Category
  Future<List<Map<String, dynamic>>> getCategories() async {
    var db = await _getDatabase();
    var result = await db.query('Category');
    return result;
  }

  Future<int> addCategory(Category category) async {
    var db = await _getDatabase();
    var result = await db.insert('Category', category.toMap());
    return result;
  }

  Future<int> updateCategory(Category category) async {
    var db = await _getDatabase();
    var result = await db.update('Category', category.toMap(),
        where: 'CategoryID = ?', whereArgs: [category.categoryID]);
    return result;
  }

  Future<int> deleteCategory(int categoryID) async {
    var db = await _getDatabase();
    var result = await db
        .delete('Category', where: 'categoryID = ?', whereArgs: [categoryID]);
    return result;
  }

  //Notes
  Future<List<Map<String, dynamic>>> getNotes() async {
    var db = await _getDatabase();
    var result = await db.query('Note', orderBy: 'noteID DESC');
    return result;
  }

  Future<int> addNote(Note note) async {
    var db = await _getDatabase();
    var result = await db.insert('Note', note.toMap());
    return result;
  }

  Future<int> updateNote(Note note) async {
    var db = await _getDatabase();
    var result = await db.update('Note', note.toMap(),
        where: 'noteID = ?', whereArgs: [note.noteID]);
    return result;
  }

  Future<int> deleteNote(int noteID) async {
    var db = await _getDatabase();
    var result =
        await db.delete('Note', where: 'noteID = ?', whereArgs: [noteID]);
    return result;
  }
}
