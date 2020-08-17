import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:internmatch/models/BridgeEnv.dart';
import 'package:internmatch/models/EntityAttribute.dart';
import 'package:internmatch/models/Event.dart';

import 'package:internmatch/models/BaseEntity.dart' as b;
import 'package:internmatch/models/Answer.dart' as ans;
import 'package:internmatch/models/QDataAnswerMessage.dart';
import 'package:internmatch/models/SessionData.dart';
import 'package:internmatch/utils/internmatch/DatabaseHelper.dart';
import 'package:internmatch/utils/internmatch/GetTokenData.dart';
import 'package:internmatch/utils/internmatch/MessageWrapper.dart';
import 'package:internmatch/utils/internmatch/PushToHTTP.dart';
import 'package:internmatch/utils/internmatch/Websocket.dart';

import '../../ProjectEnv.dart';
import 'Device.dart';

class EventHandler {
  Function _logoutCallback;

  EventHandler(Function callback) {
    _logoutCallback = callback;
    if (ProjectEnv.token == null) {
      // this.initWebSocketConnection();
      // this.sendAuth();
    }
  }

  initWebSocketConnection() async {
    await socket.initCommunication(BridgeEnvs.vertexUrl);

    print(
        "Length of Access Token:: ${Session.tokenResponse.accessToken.length}");

    this.registerWebsocket();
  }

  String __getAccessToken() {
    return Session.tokenResponse.accessToken;
    //Get token form database;
  }

  sendPing() {
    socket.sendMessage(json.encode(message.pingMessage()));
  }

  registerWebsocket() {
    socket.sendMessage(
        json.encode(message.registerMessage(this.__getSessionState())));
  }

  sendAuth() {
    this.sendEvent(event: authInit, sendWithToken: true);
  }

  // sendToDB({date, learningOutcomes, task, hour, status, name, feedback}) async {
  //   var formattedDate = formatDate(date);

  //   b.BaseEntity beJournal = new b.BaseEntity(
  //       "JNL_${tokenData['sub'].toString().toUpperCase()}_$formattedDate",
  //       "Journal");

  //   beJournal.addDate("PRI_JOURNAL_DATE", date);
  //   beJournal.addString(
  //       "PRI_JOURNAL_LEARNING_OUTCOMES", learningOutcomes.toString());
  //   beJournal.addString("PRI_JOURNAL_TASKS", task.toString());
  //   beJournal.addDouble("PRI_JOURNAL_HOURS", hour);
  //   beJournal.addString("PRI_STATUS", status.toString());
  //   beJournal.addString("PRI_FEEDBACK", feedback.toString());
  //   beJournal.addString("PRI_SYNC", "FALSE");
  //   print("Persisting the new journal data");
  //   beJournal.persist();

  // }

//update edited journals
  // updateJournal(beCode, date, hour, task, learningOutcomes, status) async {
  //   print("base entity code [ $beCode]");
  //   b.BaseEntity.getBaseEntityByCode(beCode).then((beJournal) {
  //     beJournal.addString(
  //         "PRI_JOURNAL_LEARNING_OUTCOMES", learningOutcomes.toString());
  //     beJournal.addString("PRI_JOURNAL_TASKS", task.toString());
  //     beJournal.addDouble("PRI_JOURNAL_HOURS", hour);
  //     beJournal.addString("PRI_STATUS", status.toString());
  //     beJournal.addString("PRI_SYNC", "FALSE");
  //     print("Editing and saving  the new journal data");
  //     beJournal.persist();

  //   });
  // }

  // create QDataAnswerMessage
  qDataAnswerMessage(beCode, date, hour, task, learningOutcomes, status) {
   b.BaseEntity.getBaseEntityByCode(beCode).then((beJournal) {
    var answerMsg = beJournal.getAsQDataAnswerMessage();
    var userData = jsonEncode(answerMsg);
    Device.postHTTP(ProjectEnv.httpURL, userData);
    });
   
  }

//formatting date

  String formatDate(String date) {
    var dateElements = (date ?? '1/Jan/2020').split('/');
    var month = '00';
    switch (dateElements[1]) {
      case 'Jan':
        {
          month = '01';
        }
        break;
      case 'Feb':
        {
          month = '02';
        }
        break;
      case 'Mar':
        {
          month = '03';
        }
        break;
      case 'Apr':
        {
          month = '04';
        }
        break;
      case 'May':
        {
          month = '05';
        }
        break;
      case 'Jun':
        {
          month = '06';
        }
        break;
      case 'Jul':
        {
          month = '07';
        }
        break;
      case 'Aug':
        {
          month = '08';
        }
        break;
      case 'Sep':
        {
          month = '09';
        }
        break;
      case 'Oct':
        {
          month = '10';
        }
        break;
      case 'Nov':
        {
          month = '11';
        }
        break;
      case 'Dec':
        {
          month = '12';
        }
        break;
      default:
        {
          //statements;
        }
        break;
    }
    var dayNum = int.parse(dateElements[0]);
    var dayStr = '';
    if (dayNum < 10) {
      dayStr = '0' + dayNum.toString();
    } else {
      dayStr = dayNum.toString();
    }
    var fixedDate = dateElements[2] + month + dayStr;
    print("fixedDate::::" + fixedDate);
    return fixedDate;
  }

  storeTokenInDB(String token) async {
    var db = new DatabaseHelper();

    //Session.tokenResponse.accessToken = await db.saveToken(new KeyCloakToken("$token"));
  }

  /*void fetchTokenFromDB() async {
    var db = new DatabaseHelper();
    KeyCloakToken tokenFromDB = await db.retrieveToken(1);
  }*/

  String __getSessionState() {
    return Session.tokenResponse.tokenAdditionalParameters['session_state'];
  }

  logout() {
    print("logout event detected");
   
    _logoutCallback();
  }

  sendEvent({event, sendWithToken, eventType, data, items, beCode}) {
    // generate Event
    var accessToken;
    OutgoingEvent eventObject;

    if (sendWithToken) {
      accessToken = this.__getAccessToken();
    }

    eventObject = event(
        eventType: eventType,
        data: data,
        token: accessToken,
        items: items,
        beCode: beCode);
    final eventMessage = eventObject.eventMsg().toString();
    print('sending event ::' + eventMessage);
    socket.sendMessage(
        json.encode(message.eventMessage('address.inbound', eventMessage)));
  }

  handleIncomingMessage(incomingMessage) {
    var jsonMessage = json.decode(incomingMessage);
    print("EventHandler :: $jsonMessage");
    /* List<dynamic> data = incomingMessage;
    //String jsonString = latin1.decode(incomingMessage);
    
    var sessionState = Session.tokenResponse.tokenAdditionalParameters['session_state'];
    print("Decoded Message :: $data"); */

    /*  var type = jsonString['type'];
    var address = jsonString['address'];
    var body = jsonString['body']['items']['baseEntityAttributes']; */
    /* if(address == sessionState){
      print("Handling JSON Object from Server");
      print("Msg Type :: $type");
       print("Address  :: $address");
        print("BaseEntityAttributes :: $body"); */
  }
}
//}
