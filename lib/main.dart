import 'package:flutter/material.dart';
import './startapp/StartApp.dart';
import './ProjectEnv.dart';

void main() async {
  
    runApp(new MaterialApp(
      debugShowCheckedModeBanner: false,
      title: ProjectEnv.projectName,
      /*Run the app*/
      home: StartApp()
  ));
}
