import './AliasCode.dart';
import './EntityAttribute.dart';
import '../utils/internmatch/BaseEntityUtils.dart';
import '../utils/internmatch/DatabaseHelper.dart';
import '../utils/internmatch/GetTokenData.dart';
import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:sqflite/sqflite.dart';

import 'Answer.dart';
import 'QDataAnswerMessage.dart';

part 'BaseEntity.g.dart';

@JsonSerializable(explicitToJson: true)
class BaseEntity {
  static String className = "BaseEntity";
  static String tablename = className.toLowerCase();

  String uuid = tokenData['sub']; // uniquely identiy user
  List<EntityAttribute> baseEntityAttributes = [];
  List links;
  List questions;
  String code;
  String created =
      DateFormat('yyyy-MM-ddTHH:mm:ss').format(DateTime.now().toUtc()) +
          ".${DateTime.now().toUtc().millisecond}";
  String name;
  String realm;

  //baseEntity constructor
  BaseEntity(this.code, this.name);

  factory BaseEntity.fromJson(Map<String, dynamic> json) =>
      _$BaseEntityFromJson(json);
  Map<String, dynamic> toJson() => _$BaseEntityToJson(this);

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();

    map['realm'] = tokenData['azp'];
    map['code'] = this.code;
    map['name'] = this.name;
    map['created'] = this.created;
    if (this.links != null) {
      map['links'] = this.links.map((link) => link.toMap()).toList();
    }
    if (this.questions != null) {
      map['questions'] =
          this.questions.map((question) => question.toMap()).toList();
    }
    if (this.baseEntityAttributes != null) {
      map['baseEntityAttributes'] = this
          .baseEntityAttributes
          .map((baseEntityAttribute) => baseEntityAttribute.toMap())
          .toList();
    }
    return map;
  }

  Map<String, dynamic> toMapDB() {
    var map = Map<String, dynamic>();
    map['uuid'] = tokenData['sub'];
    map['realm'] = tokenData['azp'];
    map['code'] = this.code;
    map['name'] = this.name;
    map['created'] = this.created;
    if (this.links != null) {
      map['links'] = this.links.map((link) => link.toMap()).toList();
    }
    if (this.questions != null) {
      map['questions'] =
          this.questions.map((question) => question.toMap()).toList();
    }

    return map;
  }

  BaseEntity.fromMap(Map<String, dynamic> map) {
    this.realm = map["realm"];
    this.code = map["code"];
    this.name = map["name"];
    this.links = map["links"];
    this.questions = map["questions"];
    this.created = map["created"];
    if (map['baseEntityAttributes'] != null) {
      this.baseEntityAttributes = [];
      map['baseEntityAttributes'].forEach((v) {
        EntityAttribute ea = new EntityAttribute.fromMap(v);
        ea.baseentityCode = this.code;
        this.add(ea);
      });
    }
  }

//saving base entities into the db
  persist(String source) async {
    DatabaseHelper.internal().db.then((db) {
      print("$source -> Persisting BaseEntity: $code");
      DatabaseHelper.internal().insertInToDB(toMapDB(), "baseentity");
      // Now persist all the entityAttributes
      if ((baseEntityAttributes != null) && (baseEntityAttributes.isNotEmpty)) {
        for (var ea in baseEntityAttributes) {
          ea.baseentityCode = this.code; // forcee
          ea.persist(db);
        }
      }
    });
  }

  @override
  String toString() {
    return "{code: $code, name: $name, realm: $realm}";
  }

  static Future<List<BaseEntity>> fetch(String codeFilterString) async {
    String uid = tokenData['sub'];
    var baseEntityList = await DatabaseHelper.internal()
        .retrieveFromDB("baseentity", " where uuid='$uid' ");
    List<BaseEntity> beList = [];
    if (baseEntityList != null) {
      if (baseEntityList.isNotEmpty) {
        for (var m in baseEntityList) {
          BaseEntity be = BaseEntity.fromMap(m);
          var be2 = await EntityAttribute.fetchEntityAttributes(be);
          if (be2.code.startsWith(codeFilterString)) {
            beList.add(be2);
          }
        }
      }
    }
    return beList;
  }

  static Future<List<BaseEntity>> fetchBaseEntitys(String codeFilterString,
      String attributeCodeFilter, String valueFilter) async {
    String uid = tokenData['sub'];
    String query =
        "SELECT * FROM '$tablename' WHERE code LIKE '$codeFilterString%' and uuid='$uid'";
    // print("Query in fetchBaseEntitys=$query");
    return BaseEntity.fetchBaseEntitysFromQuery(query).then((results) async {
      List<BaseEntity> filtered = [];
      Set<BaseEntity> filteredSet = new Set<BaseEntity>();
      // print("returned result count is ${results.length}");
      for (var be in results) {
        var be2 = await EntityAttribute.fetchEntityAttributes(be);
        for (var ea in be2.baseEntityAttributes) {
          if (ea.attributeCode == attributeCodeFilter) {
            if (ea.valueString != null) {
              if (ea.valueString == valueFilter) {
                filtered.add(be2);
                filteredSet.add(be2);
                // print("Adding filtered ${be2.code} with pri_status $status");
              }
            }
          }
        } // for

      }
      // print("filtered returned item count is ${filtered.length}");
      //return filtered;
      return filteredSet.toList();
    });
  }

  static Future<List<BaseEntity>> fetchBaseEntitysByBoolean(
      String codeFilterString,
      String attributeCodeFilter,
      bool valueFilter) async {
    String uid = tokenData['sub'];
    String query =
        "SELECT * FROM '$tablename' WHERE code LIKE '$codeFilterString%' and uuid='$uid'";
    var results = await BaseEntity.fetchBaseEntitysFromQuery(query);
    List<BaseEntity> filtered = [];
    Set<BaseEntity> filteredSet = new Set<BaseEntity>();
    for (var be in results) {
      var be2 = await EntityAttribute.fetchEntityAttributes(be);
      for (var ea in be2.baseEntityAttributes) {
        if (ea.attributeCode == attributeCodeFilter) {
          if (ea.valueBoolean != null) {
            if (ea.valueBoolean == valueFilter) {
              filtered.add(be2);
              filteredSet.add(be2);
            }
          }
        }
      } // for
    }
    return filteredSet.toList();
  }

  static Future<List<BaseEntity>> fetchBaseEntitys2(String codeFilterString,
      String attributeCodeFilter, String valueFilter) async {
    String uid = tokenData['sub'];
    Future<Database> db = DatabaseHelper.internal().db;
    var dbClient = await db;
    String query =
        "SELECT distinct(be) FROM 'baseentity_attribute' ea,'baseentity' be WHERE ea.baseeentityCode LIKE '$codeFilterString%'  and ea.attributeCode = '$attributeCodeFilter' and ea.valueString = '$valueFilter' and ea.baseentityCode = be.code and uuid='$uid' ";
    return dbClient.rawQuery(query).then((map) {
      List<BaseEntity> bes = [];
      for (var v in map) {
        BaseEntity be = BaseEntity.fromMap(v);
        EntityAttribute.fetchEntityAttributes(be).then((be2) {
          bes.add(be);
        });
      }
      return bes;
    });
  }

  String getValue(String attributeCode, String defaultValue) {
    String ret = defaultValue;
    if (baseEntityAttributes.isNotEmpty) {
      for (var ea in baseEntityAttributes) {
        if (ea.attributeCode == attributeCode) {
          ret = ea.valueString;
          return ret;
        }
      }
    }
    return ret;
  }

  double getValueDouble(String attributeCode, double defaultValue) {
    double ret = defaultValue;
    if (baseEntityAttributes.isNotEmpty) {
      for (var ea in baseEntityAttributes) {
        if (ea.attributeCode == attributeCode) {
          ret = ea.valueDouble;
          return ret;
        }
      }
    }
    return ret;
  }

  int getValueInteger(String attributeCode, int defaultValue) {
    int ret = defaultValue;
    if (baseEntityAttributes.isNotEmpty) {
      for (var ea in baseEntityAttributes) {
        if (ea.attributeCode == attributeCode) {
          ret = ea.valueInteger;
          return ret;
        }
      }
    }
    return ret;
  }

  DateTime getValueDateTime(String attributeCode, DateTime defaultValue) {
    DateTime ret = defaultValue;
    if (baseEntityAttributes.isNotEmpty) {
      for (var ea in baseEntityAttributes) {
        if (ea.attributeCode == attributeCode) {
          ret = ea.valueDateTime;
          return ret;
        }
      }
    }
    return ret;
  }

  DateTime getValueDate(String attributeCode, DateTime defaultValue) {
    DateTime ret = defaultValue;
    if (baseEntityAttributes.isNotEmpty) {
      for (var ea in baseEntityAttributes) {
        if (ea.attributeCode == attributeCode) {
          ret = ea.valueDate;
          return ret;
        }
      }
    }
    return ret;
  }

  bool hasValue(String attributeCode) {
    bool ret = false;
    if (baseEntityAttributes.isNotEmpty) {
      for (var ea in baseEntityAttributes) {
        if (ea.attributeCode == attributeCode) {
          ret = true;
          return ret;
        }
      }
    }
    return ret;
  }

  add(EntityAttribute ea) {
    List eas = [];
    for (var at in baseEntityAttributes) {
      if (at.attributeCode != ea.attributeCode) {
        eas.add(at);
      }
    }
    eas.add(ea);
    this.baseEntityAttributes = eas;
  }

  addDate(String attributeCode, DateTime value) {
    String monthStr = BaseEntityUtils.get2DigitString(value.month);
    String dayStr = BaseEntityUtils.get2DigitString(value.day);

    DateTime noTimeDate = value.subtract(Duration(
        days: 0,
        hours: value.hour,
        minutes: value.minute,
        seconds: value.second));

    EntityAttribute ea = new EntityAttribute(this.code, attributeCode,
        attributeCode, value.year.toString() + "-" + monthStr + "-" + dayStr);
    ea.valueString = null;
    ea.valueDate = noTimeDate;
    add(ea);
  }

  addTime(String attributeCode, DateTime value) {
    String hourStr = BaseEntityUtils.get2DigitString(value.hour);
    String minStr = BaseEntityUtils.get2DigitString(value.minute);
    String secStr = BaseEntityUtils.get2DigitString(value.second);

    EntityAttribute ea = new EntityAttribute(this.code, attributeCode,
        attributeCode, hourStr + ":" + minStr + ":" + secStr);

    add(ea);
  }

  addDateTime(String attributeCode, DateTime value) {
    EntityAttribute ea = new EntityAttribute(
        this.code, attributeCode, attributeCode, value.toIso8601String());
    ea.valueString = null;
    ea.valueDateTime = value;
    add(ea);
  }

  addDouble(String attributeCode, double value) {
    EntityAttribute ea = new EntityAttribute(
        this.code, attributeCode, attributeCode, value.toString());
    ea.valueString = null;
    ea.valueDouble = value;
    add(ea);
  }

  addInteger(String attributeCode, int value) {
    EntityAttribute ea = new EntityAttribute(
        this.code, attributeCode, attributeCode, value.toString());
    ea.valueString = null;
    ea.valueInteger = value;
    add(ea);
  }

  addString(String attributeCode, String value) {
    EntityAttribute ea =
        new EntityAttribute(this.code, attributeCode, attributeCode, value);
    if (attributeCode == "PRI_SYNC") {
      print("SYNC");
    }
    add(ea);
  }

  addBoolean(String attributeCode, bool value) {
    EntityAttribute ea = new EntityAttribute(this.code, attributeCode,
        attributeCode, value.toString().toUpperCase());
    ea.valueString = null;
    ea.valueBoolean = value;
    add(ea);
  }

  static void createTable(Database db, int version) {
    var query =
        "CREATE TABLE 'baseentity' ( uuid TEXT, realm TEXT,code TEXT PRIMARY KEY, name TEXT,  links TEXT, questions TEXT, created TEXT, unique (uuid,code))";
    DatabaseHelper.internal().executeQuery(db, query);
    print("base entity table created in baseentity.dart");
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
        "SELECT COUNT(code) FROM 'baseentity' WHERE code LIKE '$codePattern' and uuid='$uid'";
    count = Sqflite.firstIntValue(await dbClient.rawQuery(query));
    // print("Inside getBaseEntityCount + $count");
    return count;
  }

  static Future<BaseEntity> getBaseEntityByCode(String code) async {
    String uid = tokenData['sub'];
    Future<Database> db = DatabaseHelper.internal().db;

    String query;
    var dbClient = await db;
    if (code.substring(4, 4) != '_') {
      return AliasCode.getBaseEntityCodefromAliasCode(code).then((code2) {
        query =
            "SELECT * FROM 'baseentity' WHERE code = '$code2' and uuid='$uid'";
        return BaseEntity.fetchBaseEntityFromQuery(dbClient, query)
            .then((result) {
          if ((result == null) && (code == "USER")) {
            String userCode = BaseEntityUtils.getUserCode();
            String name = BaseEntityUtils.getUserNameFromToken();
            result = new BaseEntity(userCode, name);
          }
          return result;
        });
      });
    } else {
      query = "SELECT * FROM 'baseentity' WHERE code = '$code' and uuid='$uid'";
      return BaseEntity.fetchBaseEntityFromQuery(dbClient, query)
          .then((result) {
        return result;
      });
    }
  }

  static Future<List<BaseEntity>> fetchBaseEntitysFromQuery(
      String query) async {
    Future<Database> db = DatabaseHelper.internal().db;
    var dbClient = await db;
    // print("QUERY ==[$query]");
    var mapList = await dbClient.rawQuery(query);

    List<BaseEntity> beList = [];
    for (var map in mapList) {
      BaseEntity be = BaseEntity.fromMap(map);
      var be2 = await EntityAttribute.fetchEntityAttributes(be);
      // print("Adding baseentity to list ${be2.code}");
      beList.add(be2);
    }
    // print(">>>>>>>>>> The number of total items is ${beList.length}");

    if (query.contains("JNL")) {
      // ugly.
      // sort by PRI_DATE
      var now = new DateTime.now();
      beList.sort((a, b) {
        DateTime adt = a.getValueDate("PRI_JOURNAL_DATE", now);
        DateTime bdt = b.getValueDate("PRI_JOURNAL_DATE", now);
        if (bdt == null) {
          print("why is bdt null? ");
          return 1;
        } else {
          int cmp = (bdt.compareTo(adt));
          return cmp;
        }
      });
    }

    return beList;
  }

  static Future<BaseEntity> fetchBaseEntityFromQuery(
      Database dbClient, String query) async {
    return dbClient.rawQuery(query).then((mapList) {
      if (mapList != null) {
        if (mapList.isNotEmpty) {
          BaseEntity be = BaseEntity.fromMap(mapList[0]);
          return EntityAttribute.fetchEntityAttributes(be).then((be) {
            return be;
          });
        } else {
          return null;
        }
      } else {
        return null;
      }
    });
  }

  bool hasRole(String role) {
    var ret = false;
    if (role != null) {
      if (!role.startsWith("PRI_IS_")) {
        role = "PRI_IS_" + role;
      }

      if (baseEntityAttributes.isNotEmpty) {
        for (var ea in baseEntityAttributes) {
          if (ea.attributeCode == role) {
            ret = ea.valueBoolean;
            return ret;
          } else if (tokenData['realm_access']['roles']
              .contains(role.toLowerCase())) {
            ret = true;
            return ret;
          }
        }
      }
    } else {
      print("No role passed to hasRole");
    }
    return ret;
  }

  static Future<int> getAttributeCodeValueCount(
      String attributeCode, String valueString) async {
    String uid = tokenData['sub'];
    Future<Database> db = DatabaseHelper.internal().db;
    var dbClient = await db;
    String query;
    query =
        "SELECT COUNT(*) FROM 'baseentity_attribute' WHERE attributeCode = '$attributeCode' AND  valueString = '$valueString' and uuid='$uid'";
    return fetchCountFromQuery(dbClient, query).then((count) {
      //   print(
      //       "Inside getAttributeCodeValueCount $attributeCode + $valueString + $count ");
      return count;
    });
  }

  static Future<int> fetchCountFromQuery(
      Database dbClient, String query) async {
    return dbClient.rawQuery(query).then((map) {
      int count = Sqflite.firstIntValue(map);
      return count;
    });
  }

  QDataAnswerMessage getAsQDataAnswerMessage() {
    List<Answer> items = getAsAnswers();
    var answerMsg = new QDataAnswerMessage(items);
    return answerMsg;
  }

  List<Answer> getAsAnswers() {
    var username = tokenData['preferred_username'];
    var userCode = 'PER_' +
        username
            .replaceAll("&", "_AND_")
            .replaceAll("@", "_AT_")
            .replaceAll(".", "_DOT_")
            .replaceAll("+", "_PLUS_")
            .toUpperCase();

    List<Answer> items = [];
    if (baseEntityAttributes.isNotEmpty) {
      for (var ea in baseEntityAttributes) {
        items.add(ea.asAnswer(userCode));
      }
    }
    return items;
  }

  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! BaseEntity) return false;
    BaseEntity o = other;
    return (code == o.code);
  }

  int get hashCode => "$code".hashCode;
}
