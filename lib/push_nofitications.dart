import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'ProjectEnv.dart';
import 'dart:convert';

import './widgets/AlertMessage.dart';
import './models/BaseEntity.dart';
import './pages/ViewJournal.dart';

import 'utils/internmatch/UserEventHelper.dart';

class PushNotificationsManager {

  BuildContext context;

  UserEventHelper eventHelper;

  PushNotificationsManager(BuildContext context){

    this.context = context;

  }

  // PushNotificationsManager._();

  // factory PushNotificationsManager() => _instance;

  // static final PushNotificationsManager _instance = PushNotificationsManager._();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future onSelectNotification(String payload) async {
    // if (payload != null) {
    //   print('notification payload: ' + payload, debug: true);
    // }
    await Fluttertoast.showToast(
        msg: "Notification Clicked",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIos: 1,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 16.0);
    /*Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => new SecondScreen(payload)),
    );*/
  }

  Future onDidRecieveLocalNotification(
      int id, String title, String body, String payload) async {
    // display a dialog with the notification details, tap ok to go to another page
    showDialog(
      context: context,
      builder: (BuildContext context) => new CupertinoAlertDialog(
        title: new Text(title),
        content: new Text(body),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: new Text('Ok'),
            onPressed: () async {
              Navigator.of(context, rootNavigator: true).pop();
              await Fluttertoast.showToast(
                  msg: "Notification Clicked",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIos: 1,
                  backgroundColor: Colors.black54,
                  textColor: Colors.white,
                  fontSize: 16.0);
            },
          ),
        ],
      ),
    );
  }

  Future<void> init() async {
    if (!_initialized) {
      
      var initializationSettingsAndroid =
        new AndroidInitializationSettings('@mipmap/ic_launcher');

      var initializationSettingsIOS = new IOSInitializationSettings(
        onDidReceiveLocalNotification: onDidRecieveLocalNotification);

      var initializationSettings = new InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

      flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);

      _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print('on message $message');
        // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
        //displayNotification(message);
        // _showItemDialog(message);
        String popUpMessage = message["notification"]["body"];
        showAlertMessage('$popUpMessage', context);
      },
      onResume: (Map<String, dynamic> message) async {
        print('on resume $message');
        //FcmObject fcmMessage 
        // ViewJournal();
      },
      onLaunch: (Map<String, dynamic> message) async {
        print('on launch $message');
        // ViewJournal();
      },
    );
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });

    _firebaseMessaging.getToken().then((String fcmtoken) {
      assert(fcmtoken != null);
      ProjectEnv.notifytoken = fcmtoken;
      print("toke = $fcmtoken");
    });
      
      _initialized = true;
    }
  }
  Future<void> checkJournalMessage() async {
    // this stuff is unfortuantly specific to internmatch as of making this (if you could tell from the eventHelper being imported from an internmatch folder)
    //ViewJournal(_eventHelper);
    //ViewJournal(eventHelper, index, baseEntityItem, user, name, getFilteredList)




  }
}