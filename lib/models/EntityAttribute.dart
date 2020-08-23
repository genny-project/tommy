import '../models/Answer.dart';
import '../utils/internmatch/DatabaseHelper.dart';
import '../utils/internmatch/GetTokenData.dart';
import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:sqflite/sqflite.dart';

import 'BaseEntity.dart';

part 'EntityAttribute.g.dart';

@JsonSerializable(explicitToJson: true)
class EntityAttribute {
  static String className = "EntityAttribute";
  static String tablename = className.toLowerCase();

  String uuid;
  String baseentityCode;
  String attributeCode;
  String attributeName;
  bool readonly;
  int index = 0;
  int id = 0;
  String created =
      DateFormat('yyyy-MM-ddTHH:mm:ss').format(DateTime.now().toUtc()) +
          ".${DateTime.now().toUtc().millisecond}";
  String valueString;
  double valueDouble;
  bool valueBoolean;
  int valueInteger;
  DateTime valueDate;
  DateTime valueDateTime;

  double weight = 1.0;
  bool inferred;
  bool privacyFlag;

  EntityAttribute(this.baseentityCode, this.attributeCode, this.attributeName,
      this.valueString);

  factory EntityAttribute.fromJson(Map<String, dynamic> json) =>
      _$EntityAttributeFromJson(json);
  Map<String, dynamic> toJson() => _$EntityAttributeToJson(this);

  Map<String, dynamic> toMap() {
    print(tokenData['sub']);
    var map = Map<String, dynamic>();
    map['baseentityCode'] = this.baseentityCode;
    map['attributeCode'] = this.attributeCode;
    map['attributeName'] = this.attributeName;
    map['created'] = this.created;
    map['valueString'] = this.valueString;
    map['valueDouble'] = this.valueDouble;

    map['valueBoolean'] = this.valueBoolean;
    ;

    map['valueInteger'] = this.valueInteger;
    if (this.valueDate != null) {
      DateFormat df = DateFormat('yyyy-MM-dd');
      map['valueDate'] = df.format(this.valueDate);
    }
    if (this.valueDateTime != null) {
      map['valueDateTime'] = valueDateTime.toIso8601String();
      print(
          "############################valueDateTime = ${map['valueDateTime']}");
    }
    map['weight'] = this.weight;
    map['readonly'] = this.readonly;
    map['inferred'] = this.inferred;
    map['privacyFlag'] = this.privacyFlag;

    return map;
  }
  
  Map<String, dynamic> toMapDB() {
   // print(tokenData['sub'] );
   //print("Mapping to DB : "+this.baseentityCode);
    var map = Map<String, dynamic>();
    map['uuid'] = tokenData['sub'];
    map['baseentityCode'] = this.baseentityCode;
    map['attributeCode'] = this.attributeCode;
    map['attributeName'] = this.attributeName;
    map['created'] = this.created;
    map['valueString'] = this.valueString;
    map['valueDouble'] = this.valueDouble;
    if (this.valueBoolean != null) {
      if (this.valueBoolean == true) {
        map['valueBoolean'] = "TRUE";
      } else {
        map['valueBoolean'] = "FALSE";
      }
    }
    map['valueInteger'] = this.valueInteger;
    if (this.valueDate != null) {
      DateFormat df = DateFormat('yyyy-MM-dd');
      map['valueDate'] = df.format(this.valueDate);
    }
    if (this.valueDateTime != null) {
      map['valueDateTime'] = valueDateTime.toIso8601String();
    }
    map['weight'] = this.weight;
    if (this.readonly != null) {
      if (this.readonly == true) {
        map['readonly'] = "TRUE";
      } else {
        map['readonly'] = "FALSE";
      }
    }
    if (this.inferred != null) {
      if (this.inferred == true) {
        map['inferred'] = "TRUE";
      } else {
        map['inferred'] = "FALSE";
      }
    }
    if (this.privacyFlag != null) {
      if (this.privacyFlag == true) {
        map['privacyFlag'] = "TRUE";
      } else {
        map['privacyFlag'] = "FALSE";
      }
    }
   //print("Finished Mapping to DB : "+this.baseentityCode);
    return map;
  }

  EntityAttribute.fromMap(Map<String, dynamic> map) {
    this.baseentityCode = map["baseentityCode"];
    this.attributeCode = map["attributeCode"];
    this.attributeName = map["attributeName"];
    //this.readonly = map["readonly"];
    this.created = map["created"];
    this.valueString = map["valueString"];
    if (map["valueDouble"] != null) {
      dynamic vd = map["valueDouble"];
      if (vd is int) {
        int vdi = map["valueDouble"];
        this.valueDouble = vdi.ceilToDouble();
      } else if (vd is double) {
        this.valueDouble = map["valueDouble"];
      } else if (vd is String) {
        String vds = map["valueDouble"];
        this.valueDouble = double.parse(vds);
      }
    }

    if (map["valueDate"] != null) {
      this.valueDate = DateTime.parse(map["valueDate"]);
    }

    if (map["valueDateTime"] != null) {
      this.valueDateTime = DateTime.parse(map["valueDateTime"]);
    }

    this.valueInteger = map["valueInteger"];
        this.valueBoolean = map["valueBoolean"];
    this.weight = map["weight"].toDouble();
    this.readonly = map["readonly"];

    this.inferred = map["inferred"];
    this.privacyFlag = map["privacyFlag"];
  }

  EntityAttribute.fromMapDB(Map<String, dynamic> map) {
    this.baseentityCode = map["baseentityCode"];

    this.attributeCode = map["attributeCode"];
    this.attributeName = map["attributeName"];

    this.created = map["created"];
    this.valueString = map["valueString"];
    if (map["valueDouble"] != null) {
      //  print("fromMap : valueDouble = ["+map["valueDouble"].toString()+"]");
      dynamic vd = map["valueDouble"];
      if (vd is int) {
        int vdi = map["valueDouble"];
        this.valueDouble = vdi.ceilToDouble();
      } else if (vd is double) {
        this.valueDouble = map["valueDouble"];
      } else if (vd is String) {
        String vds = map["valueDouble"];
        this.valueDouble = double.parse(vds);
      }
    }

    if (map["valueBoolean"] != null) {
      if (map["valueBoolean"] == "TRUE") {
        this.valueBoolean = true;
      } else {
        this.valueBoolean = false;
      }
    }
    if (map["valueDate"] != null) {
      this.valueDate = DateTime.parse(map["valueDate"]);
    }

    if (map["valueDateTime"] != null) {
      this.valueDateTime = DateTime.parse(map["valueDateTime"]);
    }
    this.valueInteger = map["valueInteger"];
    this.weight = map["weight"].toDouble();
    if (map["readonly"] != null) {
      if (map["readonly"] == "TRUE") {
        this.readonly = true;
      } else {
        this.readonly = false;
      }
    }
    if (map["inferred"] != null) {
      if (map["inferred"] == "TRUE") {
        this.inferred = true;
      } else {
        this.inferred = false;
      }
    }
    if (map["privacyFlag"] != null) {
      if (map["privacyFlag"] == "TRUE") {
        this.privacyFlag = true;
      } else {
        this.privacyFlag = false;
      }
    }
  }
  @override
  String toString() {
    return "{baseentityCode: $baseentityCode, attributeCode: $attributeCode, attributeName: $attributeName, valueBoolean: $valueBoolean, valueString: $valueString}";
  }

  Future<void> persist(Database dbClient) async {
    //  print(
    //     "Saving EA :: $baseentityCode [ $attributeCode ] : $valueDouble : $valueBoolean : $valueString");
    DatabaseHelper.internal()
        .insert(dbClient, toMapDB(), "baseentity_attribute");
  }

  static Future<List<EntityAttribute>> fetch(String codeFilterString) async {
    String uid = tokenData['sub'];
    var entityAttributeList = await DatabaseHelper.internal()
        .retrieveFromDB("baseentity_attribute", " where uuid='$uid'");
    List<EntityAttribute> eaList = [];
    if (entityAttributeList != null) {
      entityAttributeList.forEach((m) {
        EntityAttribute ea = EntityAttribute.fromMapDB(m);
        if (ea.baseentityCode.startsWith(codeFilterString)) {
          eaList.add(ea);
        }
      });
    }
    return eaList;
  }

  static void createTable(Database db, int version) {
    var query =
        "CREATE TABLE 'baseentity_attribute' (uuid TEXT, baseentityCode TEXT, attributeCode TEXT, attributeName TEXT, readonly  TEXT, created TEXT, valueString TEXT, valueDouble NUMERIC, valueInteger INTEGER, valueBoolean TEXT, valueDate TEXT, valueDateTime TEXT, weight REAL,inferred TEXT , privacyFlag TEXT, unique (uuid,baseentityCode,attributeCode))";
    DatabaseHelper.internal().executeQuery(db, query);
  }

  //to check if a base Entity exists in the table
  static Future<bool> isExisting(String code) async {
    int count = await getCount(code);
    if (count >= 1) {
      return true;
    } else {
      return false;
    }
  }

  static Future<int> getCount(String codePattern) async {
    String uid = tokenData['sub'];
    Future<Database> db = DatabaseHelper.internal().db;
    var dbClient = await db;
    int count;
    String query;

    query =
        "SELECT COUNT(attributeCode) FROM 'baseentity_attribute' WHERE attributeCode LIKE '$codePattern' and uuid='$uid' ";

    count = Sqflite.firstIntValue(await dbClient.rawQuery(query));
    //print("Inside getBaseEntityCount + $count");
    return count;
  }

  static Future<int> getDateCount(String codePattern, String date) async {
    String uid = tokenData['sub'];
    Future<Database> db = DatabaseHelper.internal().db;
    var dbClient = await db;
    int count;
    String query;
    query =
        "SELECT COUNT(attributeCode) FROM 'baseentity_attribute' WHERE attributeCode LIKE '$codePattern' AND valueString = '$date' and uuid='$uid'";
    count = Sqflite.firstIntValue(await dbClient.rawQuery(query));
    // print("Inside getBaseEntityCount + $count");
    return count;
  }

  static Future<BaseEntity> fetchEntityAttributes(BaseEntity be) async {
    String uid = tokenData['sub'];
    Future<Database> db = DatabaseHelper.internal().db;
    var dbClient = await db;
    String query =
        "SELECT * FROM 'baseentity_attribute' WHERE baseentityCode = '${be.code}' and uuid='$uid'";
    // print("fetchNtityAttributes in ea = $query");
    return dbClient.rawQuery(query).then((mapList) {
      if (be.baseEntityAttributes == null) {
        be.baseEntityAttributes = new List<EntityAttribute>();
      }
      for (var v in mapList) {
        EntityAttribute ea = EntityAttribute.fromMapDB(v);
        be.baseEntityAttributes.add(ea);
      }

      return be;
    });
  }

  static Future<List<BaseEntity>> fetchEntityAttributesBeList(
      List<BaseEntity> bes) async {
    String uid = tokenData['sub'];
    Future<Database> db = DatabaseHelper.internal().db;
    var dbClient = await db;
    for (var be in bes) {
      String query =
          "SELECT * FROM 'baseentity_attribute' WHERE baseentityCode = '${be.code}' and uuid='$uid'";
      print("fetchEntityAttributes in ea = $query");
      var mapList = await dbClient.rawQuery(query);

      if (be.baseEntityAttributes == null) {
        be.baseEntityAttributes = [];
      }
      for (var v in mapList) {
        EntityAttribute ea = EntityAttribute.fromMapDB(v);
        be.baseEntityAttributes.add(ea);
      }
    }
    return bes;
  }

  Answer asAnswer(String userCode) {
    Answer ans;
    if (valueBoolean != null) {
      if (valueBoolean) {
        ans = new Answer(
            userCode, this.baseentityCode, this.attributeCode, "TRUE");
      } else {
        ans = new Answer(
            userCode, this.baseentityCode, this.attributeCode, "FALSE");
      }
    } else if (valueString != null) {
      ans = new Answer(
          userCode, this.baseentityCode, this.attributeCode, valueString);
    } else if (valueDouble != null) {
      ans = new Answer(userCode, this.baseentityCode, this.attributeCode,
          valueDouble.toString());
    } else if (valueDate != null) {
      ans = new Answer(userCode, this.baseentityCode, this.attributeCode,
          valueDate.toString());
    } else if (valueDateTime != null) {
      ans = new Answer(userCode, this.baseentityCode, this.attributeCode,
          valueDateTime.toString());
    } else if (valueInteger != null) {
      ans = new Answer(userCode, this.baseentityCode, this.attributeCode,
          valueInteger.toString());
    }
    ans.inferred = this.inferred;
    return ans;
  }

  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! EntityAttribute) return false;
    EntityAttribute o = other;
    return (attributeCode == o.attributeCode) &&
        (baseentityCode == o.baseentityCode);
  }

  int get hashCode => "$attributeCode:$baseentityCode:$valueString".hashCode;
}
