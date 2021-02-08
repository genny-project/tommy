import 'package:flutter/material.dart';
import '../ProjectEnv.dart';

import 'package:uuid/uuid.dart';
import 'package:uuid/uuid_util.dart';

import '../models/BridgeEnv.dart';

import '../startapp/Home.dart';
import '../utils/internmatch/ApiHelper.dart';
import '../pages/SplashScreen.dart';

import '../push_nofitications.dart';


var dbData;
var  dbData1;

class StartApp extends StatefulWidget {
  StartApp({Key key}) : super(key: key);

  @override
  _StartAppState createState() => _StartAppState();
}

class _StartAppState extends State<StartApp> {

  @override
  void initState() {
    
    print("Initialising StartApp initState before initState");
    //code for generating unique user id
    var uuid = new Uuid();
    var uniqueId = uuid.v4(options: {'rng': UuidUtil.cryptoRNG});
    print("JNL_$uniqueId");

    super.initState();

    PushNotificationsManager _pushNotifications = new PushNotificationsManager(context);
    _pushNotifications.init();

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
