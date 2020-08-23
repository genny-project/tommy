import '../utils/internmatch/BaseEntityUtils.dart';
import '../utils/internmatch/DatabaseHelper.dart';
import '../utils/internmatch/GetTokenData.dart';
import 'package:sqflite/sqflite.dart';

class AliasCode {
  static String className = "AliasCode";
  static String tablename = className.toLowerCase();

  String aliasCode;
  String baseentityCode;

  AliasCode(this.aliasCode, this.baseentityCode);

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    String uid = tokenData['sub'];
    map["uuid"] = uid;
    map["aliasCode"] = aliasCode;
    map['baseentityCode'] = baseentityCode;
    return map;
  }

  AliasCode.fromMap(Map<String, dynamic> map) {
    this.aliasCode = map["aliasCode"];
    this.baseentityCode = map["baseentityCode"];
  }

  static void createTable(Database db, int version) {
    var query =
        "CREATE TABLE '$tablename' ( uuid TEXT, aliasCode TEXT PRIMARY KEY,  baseentityCode TEXT)";
    DatabaseHelper.internal().executeQuery(db, query);
    print("$className table created in $className.dart");
  }

  static Future<int> getCount(String aliasCode) async {
    Future<Database> db = DatabaseHelper.internal().db;
    var dbClient = await db;
    String uid = tokenData['sub'];
    int count;
    String query;
    query =
        "SELECT COUNT(*) FROM '$tablename' WHERE aliasCode = '$aliasCode' and uuid='$uid'";
    count = Sqflite.firstIntValue(await dbClient.rawQuery(query));
    print("Inside $className + $count");
    return count;
  }

  Future<bool> isExisting() async {
    int count = await AliasCode.getCount(aliasCode);
    if (count >= 1) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> persist() async {
    return DatabaseHelper.internal().db.then((db) {
      if (aliasCode != null) {
        print("adding alias :: $aliasCode with $baseentityCode");
        DatabaseHelper.internal().insertInToDB(toMap(), "$tablename");
      }
    });
  }

  static Future<String> getBaseEntityCodefromAliasCode(String aliascode) async {
    Future<Database> db = DatabaseHelper.internal().db;
    var dbClient = await db;
    String uid = tokenData['sub'];
    String query;
    query =
        "SELECT baseentityCode FROM '$tablename' WHERE aliasCode = '$aliascode' and uuid='$uid'";
    List<Map> res = await dbClient.rawQuery(query);
    if (res.length > 0) {
      String beCode = res.first['baseentityCode'];
      return beCode;
    } else {
      if (aliascode == "USER") {
        // UGLY !!!!!!!!
        return BaseEntityUtils.getUserCode();
      }
      return null; // TODO throw error instead!
    }
  }

  static void handleError(String error) {
    print("The fetching error in AliasCode is $error");
  }
}
