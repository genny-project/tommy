import 'package:flutter/material.dart';
import '../ProjectEnv.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: new BoxDecoration(color: new Color(ProjectEnv.projectColor)),
      alignment: Alignment.center,
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          new Image.asset(ProjectEnv.img,
              width: 300, repeat: ImageRepeat.noRepeat, height: 300),
          Padding(padding: new EdgeInsets.all(10.0)),
          new CircularProgressIndicator()
        ],
      ),
    );
  }
}
