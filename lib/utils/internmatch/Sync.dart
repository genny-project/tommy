import 'dart:convert';

import 'package:http/http.dart' as http;
import 'dart:async';
import '../../ProjectEnv.dart';
import '../../models/Answer.dart';
import '../../models/BaseEntity.dart';
import '../../models/QBulkMessage.dart';
import '../../models/QDataAnswerMessage.dart';
import './Device.dart';
import './VersionInfo.dart';
import 'AppAuthHelper.dart';
import 'BaseEntityUtils.dart';

class Sync {
  Sync() {
    //initPlatformState().whenComplete(() => null);
    //_performSync();
  }

  static void doTheSync() async {
    await performSync();
  }

  static Future<bool> performSync() async {
    print(
        "POSTING SYNC DATA TO ${ProjectEnv.httpURL} *************************************");
    // Fetch All Unsynced BaseEntitys'
    return BaseEntity.fetch("JNL_").then((items) {
      //return BaseEntity.fetch("JNL_").then((items) {
      List<Answer> answers = [];
      answers.add(Version.appNameAns);
      answers.add(Version.appBuildNumberAns);
      answers.add(Version.appVersionAns);
      answers.add(Device.deviceCodeAns);
      answers.add(Device.deviceTypeAns);
      answers.add(Device.deviceVersionAns);

      List<String> existingCodes = [];
      String userCode = BaseEntityUtils.getUserCode();

      print(
          "POSTING SYNC DATA IN ${items.length} BASEENTITIES TO ${ProjectEnv.httpURL}");
      if (items.length > 0) {
        for (BaseEntity be in items) {
          String synced = be.getValue("PRI_SYNC", "FALSE");
          print("Item ${be.code} has sync = $synced");
          //  if (synced == "FALSE") {
          answers.addAll(be.getAsAnswers());
          //  } else {
          //existingCodes.add(be.code);
          //  }
        }
      } else {
        Answer existingAnswer =
            new Answer(userCode, userCode, "PRI_EXISTING_CODES", "EMPTY");
        answers.add(existingAnswer);
      }
      // if (existingCodes.isNotEmpty) {
      //   String existingCodesStr = existingCodes.join(",");
      //   Answer existingAnswer = new Answer(
      //       userCode, userCode, "PRI_EXISTING_CODES", existingCodesStr);
      //   answers.insert(0, existingAnswer);
      // }

      print(
          "POSTING SYNC DATA IN ${answers.length} ANSWERS TO ${ProjectEnv.httpURL}");

      QDataAnswerMessage answerMsg = new QDataAnswerMessage(answers);
      var json = jsonEncode(answerMsg);
      // make POST request
      // print("Posting User Data $json");
      return Sync.postHTTP(ProjectEnv.httpURL, json).then((statusCode) {
        print("Sync Status Code =  $statusCode");
        return true;
      });
    });
  }

  Future<bool> _performSync2() async {
    print(
        "POSTING SYNC DATA TO ${ProjectEnv.httpURL} *************************************");
    // Fetch All Unsynced BaseEntitys
    return BaseEntity.fetchBaseEntitys("", "PRI_SYNC", "FALSE").then((items) {
      List<Answer> answers = [];

      if (items.length > 0) {
        print(
            "POSTING SYNC DATA IN ${items.length} BASEEENTITIES TO ${ProjectEnv.httpURL}");
        for (BaseEntity be in items) {
          String status = be.getValue("PRI_STATUS", "UNKNOWN");
          print("Item ${be.code} has status = $status");
          answers.addAll(be.getAsAnswers());
        }

        print(
            "POSTING SYNC DATA IN ${answers.length} ANSWERS TO ${ProjectEnv.httpURL}");
        QDataAnswerMessage answerMsg = new QDataAnswerMessage(answers);
        var json = jsonEncode(answerMsg);
        // make POST request
        print("Posting User Data $json");
        return Sync.postHTTP(ProjectEnv.httpURL, json).then((statusCode) {
          print("Sync Status Code =  $statusCode");
          return true;
        });
      } else {
        return false;
      }
    });
  }

  static Future<String> postHTTP(url, data) async {
    var token = ProjectEnv.token;
    if (ProjectEnv.token == null) {
      token = AppAuthHelper.token;
    }
    return http
        .post(url,
            headers: {
              'Authorization': 'Bearer $token',
            },
            body: data)
        .then((response) {
      if (response.statusCode == 200) {
        print(response.statusCode);
        print("Content Length= $response.contentLength");
        print(response.headers);
        print(response.request);

        QBulkMessage.processQBulkMessage(response.body).then((_) {
          return (response.statusCode.toString());
        });
      } else {
        print("Error response from backend sync server");
      }
      return (response.statusCode.toString());
    });
  }
}
