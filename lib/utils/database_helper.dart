import 'dart:io';
import 'package:adapt_note/models/category.dart';
import 'package:adapt_note/models/note.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';

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
    var result = await db.query('category');
    return result;
  }

  Future<int> addCategory(Category category) async {
    var db = await _getDatabase();
    var result = await db.insert('category', category.toMap());
    return result;
  }

  Future<int> updateCategory(Category category) async {
    var db = await _getDatabase();
    var result = await db.update('category', category.toMap(),
        where: 'categoryID = ?', whereArgs: [category.categoryID]);
    return result;
  }

  Future<int> deleteCategory(int categoryID) async {
    var db = await _getDatabase();
    var result = await db
        .delete('category', where: 'categoryID = ?', whereArgs: [categoryID]);
    return result;
  }

  //Notes
  Future<List<Map<String, dynamic>>> getNotes() async {
    var db = await _getDatabase();
    var result = await db.rawQuery(
        "select * from note inner join category on category.categoryID = note.categoryID order by noteID Desc;");
    return result;
  }

  Future<List<Note>> getNoteList() async {
    var notesMapList = await getNotes();
    var noteList = List<Note>();
    for (Map map in notesMapList) {
      noteList.add(Note.fromMap(map));
    }

    return noteList;
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

  String dateFormat(DateTime tm) {
    DateTime today = new DateTime.now();
    Duration oneDay = new Duration(days: 1);
    Duration twoDay = new Duration(days: 2);
    Duration oneWeek = new Duration(days: 7);
    String month;

    switch (tm.month) {
      case 1:
        month = "ocak";
        break;
      case 2:
        month = "şubat";
        break;
      case 3:
        month = "mart";
        break;
      case 4:
        month = "nisan";
        break;
      case 5:
        month = "mayıs";
        break;
      case 6:
        month = "haziran";
        break;
      case 7:
        month = "temmuz";
        break;
      case 8:
        month = "ağustos";
        break;
      case 9:
        month = "eylül";
        break;
      case 10:
        month = "ekim";
        break;
      case 11:
        month = "kasım";
        break;
      case 12:
        month = "aralık";
        break;
    }

    Duration difference = today.difference(tm);

    if (difference.compareTo(oneDay) < 1) {
      return "bugün";
    } else if (difference.compareTo(twoDay) < 1) {
      return "dün";
    } else if (difference.compareTo(oneWeek) < 1) {
      switch (tm.weekday) {
        case 1:
          return "pazartesi";
        case 2:
          return "salı";
        case 3:
          return "çarşamba";
        case 4:
          return "perşembe";
        case 5:
          return "cuma";
        case 6:
          return "cumartesi";
        case 7:
          return "pazar";
      }
    } else if (tm.year == today.year) {
      return '${tm.day} $month';
    } else {
      return '${tm.day} $month ${tm.year}';
    }
    return "";
  }
}
