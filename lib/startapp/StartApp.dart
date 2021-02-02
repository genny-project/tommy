import 'package:flutter/material.dart';
import '../ProjectEnv.dart';

import 'package:uuid/uuid.dart';
import 'package:uuid/uuid_util.dart';
import '../models/BridgeEnv.dart';

import '../ProjectEnv.dart';

import '../startapp/Home.dart';
import '../utils/internmatch/ApiHelper.dart';
import '../pages/SplashScreen.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/cupertino.dart';

var dbData;
var  dbData1;

class StartApp extends StatefulWidget {
  StartApp({Key key}) : super(key: key);

  @override
  _StartAppState createState() => _StartAppState();
}

class _StartAppState extends State<StartApp> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();

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

  @override
  void initState() {
    
    print("Initialising StartApp initState before initState");
    //code for generating unique user id
    var uuid = new Uuid();
    var uniqueId = uuid.v4(options: {'rng': UuidUtil.cryptoRNG});
    print("JNL_$uniqueId");

    super.initState();

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
      },
      onResume: (Map<String, dynamic> message) async {
        print('on resume $message');
      },
      onLaunch: (Map<String, dynamic> message) async {
        print('on launch $message');
      },
    );
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });

    Future<String> testtoken = _firebaseMessaging.getToken();
    print(testtoken);

    _firebaseMessaging.getToken().then((String fcmtoken) {
      assert(fcmtoken != null);
      print("toke = $fcmtoken");
    });

    if (!BridgeEnvs.fetchSuccess) {
      getEnvFromBridge();
    }
  }

 

  void getEnvFromBridge() async {
    if (ProjectEnv.token == null) {
      print("Fetching Envs From :::: " + BridgeEnvs.bridgeUrl);
      await bridgeApiHelper.makeApiRequest(BridgeEnvs.bridgeUrl).then((data) {
        BridgeEnvs.map.forEach(
          (key, val) => BridgeEnvs.map[key](data[key]),
        );

        setfetchSuccessTrue();
      });
    } else {
      print("Skipping BridgeEnvs fetch from bridge , Fetching Envs From ProjectEnvs");

      setfetchSuccessTrue();
    }
  }

  void setfetchSuccessTrue() {
    setState(() {
      BridgeEnvs.fetchSuccess = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    print("Initialising StartApp build");
    return !BridgeEnvs.fetchSuccess ? Scaffold(body: SplashScreen()) : Home();
  }
}
