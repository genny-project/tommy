import 'package:flutter/material.dart';
import './StartApp/StartApp.dart';
import './ProjectEnv.dart';

void main() async {
  
    runApp(new MaterialApp(
      debugShowCheckedModeBanner: false,
      title: ProjectEnv.projectName,
      /*Run the app*/
      home: StartApp()
  ));
}
