import 'dart:io';
import '../../models/BaseEntity.dart';
import '../../models/EntityAttribute.dart';
import '../../models/AliasCode.dart';
import '../../models/Token.dart';

import '../../models/UserToken.dart';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';
import 'package:flutter_test/flutter_test.dart';

import 'GetTokenData.dart';

class DatabaseHelper {
  static const String dbName = "database";
  static const String tokenTable = "tokens";

  static final DatabaseHelper instance = new DatabaseHelper.internal();

  factory DatabaseHelper() => instance;
  static Database _db;

  DatabaseHelper.internal();

  Future<Database> get db async {
    if (_db != null) {
      // print("Database Online");
      return _db;
    }
    return initDb().then((db) {
      _db = db;
      print("Database Initialized");
      return db;
    });
  }

  Future<Database> attachDb(
      Database db, String databaseName, String databaseAlias) async {
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    String absoluteEndPath = join(documentDirectory.path, databaseName);
    await db.rawQuery("ATTACH DATABASE '$absoluteEndPath' as '$databaseAlias'");
    return db;
  }

  Future<Database> initDb() async {
    print("Creating Database ");
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    String path = join(
        documentDirectory.path, "main.db"); //home://directory/files/maindb.db
    //     var db = await openDatabase(path, version: 1, onCreate: createGennyTable);

    return openDatabase(path, version: 1, onCreate: createGennyTable)
        .then((db) {
      // return attachDb(db, "$uuId.db","db").then((db) { return db;});
      return db;
    });
  }

  void executeQuery(Database db, query) async {
    await db.execute(query);
    //db.close();
  }

  void createTokenTables(Database db, int version) async {
    var query =
        "CREATE TABLE '$tokenTable'('uuid' TEXT, 'id' INTEGER PRIMARY KEY,'token' TEXT, unique (uuid,id))";
    executeQuery(db, query);
  }

  void createGennyTable(Database db, version) async {
    print("Database Success ");

    print("this is the function createGennyTable ");
    Token.createTable(db, version);
    AliasCode.createTable(db, version);
    BaseEntity.createTable(db, version);
    EntityAttribute.createTable(db, version);
  }

  //CRUD Operations

//Insertion returns 1 or 0 i.e. Integer

  Future<int> insertInToDB(Map item, tableName) async {
    var dbClient = await db;
    int result = await dbClient.insert("$tableName", item,
        conflictAlgorithm: ConflictAlgorithm.replace);
    return result;
  }

  Future<int> insert(Database dbClient, Map item, tableName) async {
    int result = await dbClient.insert("$tableName", item,
        conflictAlgorithm: ConflictAlgorithm.replace);
    return result;
  }

/* fetching all values from database */

  Future<List<Map<String, dynamic>>> retrieveFromDB(
      String tableName, String constraints) async {
    var dbClient = await db;
    var result;
    String query;
    String uid = tokenData['sub'];
    if (constraints != null) {
      query = "SELECT * FROM '$tableName' $constraints";
    } else {
      query = "SELECT * FROM '$tableName' where uuid='$uid'";
    }

    result = await dbClient.rawQuery(query);

    if (result.length == 0) return null;
    return result;
  }

  Future close() async {
    var dbClient = await db;
    return dbClient.close();
  }

  Future<List<Map<String, dynamic>>> debugFunction(String query) async {
    var dbClient = await db;
    var result = dbClient.rawQuery(query);
    return result;
  }
}
