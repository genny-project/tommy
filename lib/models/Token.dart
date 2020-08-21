import '../utils/internmatch/AppAuthHelper.dart';
import '../utils/internmatch/DatabaseHelper.dart';
import '../utils/internmatch/GetTokenData.dart';
import 'package:sqflite/sqflite.dart';

class Token {
  static String className = "Token";
  static String tablename = className.toLowerCase();

  DateTime lastUpdated;

  Token(this.lastUpdated);

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    if (this.lastUpdated != null) {
      map['lastUpdated'] = lastUpdated.toIso8601String();
      print("lastUpdated = ${map['lastUpdated']}");
    }
    return map;
  }

  Map<String, dynamic> toMapDB() {
    var map = new Map<String, dynamic>();
    String uid = tokenData['sub'];
    String token = AppAuthHelper.token;
    map["uuid"] = uid;
    map["token"] = token;
    if (this.lastUpdated != null) {
      map['lastUpdated'] = lastUpdated.toIso8601String();
      print("lastUpdated = ${map['lastUpdated']}");
    }
    return map;
  }

  Token.fromMap(Map<String, dynamic> map) {
    if (map["lastUpdated"] != null) {
      this.lastUpdated = DateTime.parse(map["lastUpdated"]);
    }
  }

  Token.fromMapDB(Map<String, dynamic> map) {
    if (map["lastUpdated"] != null) {
      this.lastUpdated = DateTime.parse(map["lastUpdated"]);
    }
  }

  static void createTable(Database db, int version) {
    var query =
        "CREATE TABLE '$tablename' ( uuid TEXT, token TEXT, lastUpdated TEXT)";
    DatabaseHelper.internal().executeQuery(db, query);
    print("$className table created in $className.dart");
  }

  Future<void> persist() async {
    return DatabaseHelper.internal().db.then((db) {
      if (lastUpdated != null) {
        print("adding lastUpdated :: $lastUpdated ");
        DatabaseHelper.internal().insertInToDB(toMapDB(), "$tablename");
      }
    });
  }
}
