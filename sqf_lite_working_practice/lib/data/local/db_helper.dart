import 'dart:io';
import 'package:path_provider/path_provider.dart'; // Corrected import
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart'; // Add path for joining directories

class DbHelper {
  DbHelper._();

  static final DbHelper getInstance = DbHelper._();

  final String TABLE_NOTE = "note";
  final String COLUMN_NOTE_SNO = "s_no";
  final String COLUMN_NOTE_TITLE = "title";
  final String COLUMN_NOTE_DESC = "desc";

  Database? myDB;

  Future<Database> getDB() async {
    myDB ??= await openDB();
    return myDB!;
  }

  Future<Database> openDB() async {
    Directory appDir = await getApplicationDocumentsDirectory();
    String dbPath = join(appDir.path, "noteDB.db");

    return openDatabase(dbPath, onCreate: (db, version) {
      db.execute(
          "CREATE TABLE $TABLE_NOTE ( $COLUMN_NOTE_SNO INTEGER PRIMARY KEY AUTOINCREMENT, $COLUMN_NOTE_TITLE TEXT, $COLUMN_NOTE_DESC TEXT)");
    }, version: 1);
  }

  Future<bool> addNote({required String mTitle, required String mDesc}) async {
    var db = await getDB();
    int rowsEffected = await db.insert(TABLE_NOTE, {
      COLUMN_NOTE_TITLE: mTitle,
      COLUMN_NOTE_DESC: mDesc,
    });
    return rowsEffected > 0;
  }

  Future<List<Map<String, dynamic>>> getAllNotes() async {
    var db = await getDB();
    List<Map<String, dynamic>> mData = await db.query(TABLE_NOTE);
    return mData;
  }

  Future<bool> updateNote(
      {required int sno, required String title, required String desc}) async {
    var db = await getDB();

    int rowsEffected = await db.update(
        TABLE_NOTE, {COLUMN_NOTE_TITLE: title, COLUMN_NOTE_DESC: desc},
        where: "$COLUMN_NOTE_SNO = ?", whereArgs: [sno]);
    return rowsEffected > 0;
  }

  Future<bool> deleteNote({required int sno}) async {
    var db = await getDB();

    int rowsEffected = await db
        .delete(TABLE_NOTE, where: "$COLUMN_NOTE_SNO = ?", whereArgs: [sno]);

    return rowsEffected > 0;
  }
}
