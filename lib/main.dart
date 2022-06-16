import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:tommy/pages/login.dart';

Future<void> main() async {
  await dotenv.load(fileName: '.env');
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyApp({Key? key}) : super(key: key);
  @override
  State<MyApp> createState() => _MyAppState();
  static StreamController<ThemeData> streamController =
      StreamController.broadcast();
  static void changeTheme(ThemeData themeData) {
    streamController.add(themeData);
  }
}

class _MyAppState extends State<MyApp> {
  late StreamSubscription<ThemeData> subscription;
  ThemeData appTheme = ThemeData.light();
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    subscription.cancel();
  }
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      subscription = MyApp.streamController.stream.listen((event) {
        print("Got event!");
        setState(() {
          appTheme = event;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: appTheme,
      home: const Login(),
    );
  }
}
