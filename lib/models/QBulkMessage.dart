import 'dart:convert';

import 'package:internmatch/models/QDataBaseEntityMessage.dart';
import 'package:json_annotation/json_annotation.dart';

import 'BaseEntity.dart';
part 'QBulkMessage.g.dart';
 
var jsonData =
    '{"status": "OK", "value": {"data_type": "QBulkMessage","messages": [{"items": [ "baseEntityAttributes": [ {  "baseentityCode": "PRJ_INTERNMATCH", "attributeCode": "ENV_REALM","attributeName": "ENV_REALM","readonly": false, "index": 0,"created": "2020-03-15T12:13:03.378","valueString": "internmatch","weight": 0.0,"inferred": false,"privacyFlag": true},{"baseentityCode": "PRJ_INTERNMATCH","attributeCode": "ENV_UPPY_URL","attributeName": "Uppy Server URL","readonly": false,"index": 0,"created": "2020-03-15T12:27:45.727", "valueString": "https://uppy.outcome-hub.com","weight": 1.0, "inferred": false, "privacyFlag": false},],"links": [],"questions": [],"code": "PRJ_INTERNMATCH","index": 0,"created": "2020-03-15T12:27:09","id": 1,"name": "internmatch","realm": "internmatch"}],"total": 1,"returnCount": 1,"data_type": "BaseEntity","delete": false,"replace": false,"aliasCode": "PROJECT","msg_type": "DATA_MSG","option": "EXEC"}]}}';

@JsonSerializable(explicitToJson: true)
class QBulkMessage {
  String data_type;
  List<QDataBaseEntityMessage> messages;

  QBulkMessage(this.data_type,this.messages);

  factory QBulkMessage.fromJson(Map<String, dynamic> json) {
    var dataType = json['data_type'];
    var messages = json['messages']
          .map((messages) => messages.toMap())
          .toList();
    return QBulkMessage(dataType,messages);
}


 
  // factory QBulkMessage.fromJson(Map<String, dynamic> json)
  // {
  //   var data_type = null;
  //   var messages = null;
  //     Map<String, dynamic> qBulkMessageMap = jsonDecode(json);
  //     if (qBulkMessageMap.get('status') == "OK") {
  //         Map<String, dynamic> jsonMap = qBulkMessageMap.get('value'));
  //         data_type = jsonMap["data_type"];
    
  //         if (jsonMap['messages'] != null) {
  //           messages = new List<QDataBaseEntityMessage>();
  //           jsonMap['messages'].forEach((v) {
  //             messages.add(new QDataBaseEntityMessage.fromMap(v));
  //           });

  //         }
  //       //  qBulkMessage.persist();
  //       }
  //     }
  //     return QBulkMessage(data_type,messages);
  // }

  static Future<void> processQBulkMessage(String responseBody) async
  {
     Map<String, dynamic> qBulkMessageMap = jsonDecode(responseBody);
      qBulkMessageMap.forEach((k, v) {
        if (k == 'value') {
          //print("QBulkMessage -> key is ::[$k]");
          //print("QBulkMessage value is ::[$v]");
          var qBulkMessage = QBulkMessage.fromMap(v);
          
          List<QDataBaseEntityMessage> msgs = qBulkMessage.messages;
         for ( var msg in msgs) {
            if (msg.items.isNotEmpty) {
              List<BaseEntity> baseentities = msg.items;
              for (var be in baseentities) {
                  be.persist("Sync");
                  //print(be);
              }
          }
          }
        }
      });

  }



  QBulkMessage.fromMap(Map<String, dynamic> map) {
    this.data_type = map["data_type"];
    
     if (map['messages'] != null) {
      messages = new List<QDataBaseEntityMessage>();
      map['messages'].forEach((v) {
        messages.add(new QDataBaseEntityMessage.fromMap(v));
      });
    }
}

  persist() async {
         // Now persist all the BaseEntitieMessages
         messages.forEach((beMsg) {
           beMsg.persist();
        });
  }

   @override
  String toString() {
    var ret =  "{data_type: $data_type}";
    return ret;
  }

}
/* 
  fields 
  - data_type: String
  - messages: QDataBaseEntityMessage[]

*/
