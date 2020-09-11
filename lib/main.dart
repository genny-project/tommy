import 'package:flutter/material.dart';
import './startapp/StartApp.dart';
import './ProjectEnv.dart';
import 'push_nofitications.dart.dart';

void main() async {
    
    PushNotificationsManager().init();
    runApp(new MaterialApp(
      debugShowCheckedModeBanner: false,
      title: ProjectEnv.projectName,
      /*Run the app*/
      home: StartApp()

  ));
}
