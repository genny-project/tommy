import 'package:internmatch/models/BaseEntity.dart';

import 'package:internmatch/utils/internmatch/DatabaseHelper.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:internmatch/models/AliasCode.dart';
part 'QDataBaseEntityMessage.g.dart';

@JsonSerializable(explicitToJson: true)
class QDataBaseEntityMessage {
  List<BaseEntity> items;
  int total = 1;
  int returnCount = 1;
  String data_type;
  bool delete = false;
  bool replace = false;
  String aliasCode;
  String msg_type;
  String option;

  QDataBaseEntityMessage(
      this.data_type, this.aliasCode, this.msg_type, String option);

  factory QDataBaseEntityMessage.fromJson(Map<String, dynamic> json) =>
      _$QDataBaseEntityMessageFromJson(json);
  Map<String, dynamic> toJson() => _$QDataBaseEntityMessageToJson(this);

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    map['total'] = this.total;
    map['returnCount'] = this.returnCount;
    map['data_type'] = this.data_type;
    map['delete'] = this.delete;
    map['replace'] = this.replace;
    map['aliasCode'] = this.aliasCode;
    map['msg_type'] = this.msg_type;
    map['option'] = this.option;
    if (this.items != null) {
      map['items'] = this.items.map((items) => items.toMapDB()).toList();
    }
    return map;
  }

  persistAliasCode(AliasCode aliasCode) async
  {
      await aliasCode.persist();
  }

  QDataBaseEntityMessage.fromMap(Map<String, dynamic> map) {
    this.total = map["total"];
    this.returnCount = map["returnCount"];
    this.data_type = map["data_type"];
    this.delete = map["delete"];
    this.replace = map["replace"];
    this.aliasCode = map["aliasCode"];
    this.msg_type = map["msg_type"];
    this.option = map["option"];
    if (map['items'] != null) {
      items = new List<BaseEntity>();
      map['items'].forEach((v) {
        BaseEntity be = new BaseEntity.fromMap(v);
        String beCode = be.code;
        if (be.code.startsWith("JNL_")) {
         if(!be.hasValue("PRI_STATUS")){
          be.addString("PRI_STATUS", "UNAPPROVED");
        }
        if(!be.hasValue("PRI_FEEDBACK")){
          be.addString("PRI_FEEDBACK", "");
        }
      }
        AliasCode aliasCode = new AliasCode(this.aliasCode, beCode);
        persistAliasCode(aliasCode);
        items.add(be);
      });
    }
  }

/* 
QBulkMessageJSON = response.value;
Convert QBulkMessageJSON to QBulkMessage Model class;

QDataBaseEntityMessage class ready
*/

  persist() async {
    // Now persist all the BaseEntities
    items.forEach((be) {
      be.persist("QBaseEentityMessage");
    });
  }


 
}
