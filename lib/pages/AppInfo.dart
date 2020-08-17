import 'package:flutter/material.dart';
import 'package:internmatch/ProjectEnv.dart';
import 'package:intl/intl.dart';

class AppInfo extends StatefulWidget {
  var version;

  AppInfo(var versionName) {
    version = versionName;
  }
  @override
  _AppInfoState createState() => _AppInfoState();
}

class _AppInfoState extends State<AppInfo> {
  DateTime date = DateTime.now();
  DateFormat dateFormat = new DateFormat().addPattern("EEEE, MMMM d y");
  String versionName;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
            appBar: AppBar(
              backgroundColor: Color(ProjectEnv.projectColor),
              leading: new IconButton(
                  icon: new Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context)),
            ),
            body: Center(
              child: Container(
                decoration: new BoxDecoration(
                    color: new Color(ProjectEnv.projectColor)),
                alignment: Alignment.center,
                child: new Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    new Image.asset(ProjectEnv.img,
                        width: 300, repeat: ImageRepeat.noRepeat, height: 200),
                        Text("Powered By GADA Technology",style: TextStyle(color: Colors.white, fontSize: 20),),
                          Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Text("v${widget.version}", style: TextStyle(color: Colors.white, fontSize: 20),),
                          ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
                          child: Text("26th JUNE 2020",style: TextStyle(color: Colors.white, fontSize: 15),),
                        )
                  ],
                ),
              ),
            )));
  }
}