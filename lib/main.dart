import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:tommy/pages/login.dart';


  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
Future<void> main() async {
  await dotenv.load(fileName: '.env');
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  State<MyApp> createState() => _MyAppState();
  static StreamController<ThemeData> streamController =
      StreamController.broadcast();
  static void changeTheme(ThemeData themeData) {
    streamController.add(themeData);
  }
  static void navigate(MaterialPageRoute route) {
    //this works if you call two commands but not one?
    //i am just as confused as you are.

    navigatorKey.currentState?.pushReplacement(route);
    navigatorKey.currentState?.pop();
    navigatorKey.currentState?.pushReplacement(MaterialPageRoute(builder: (context) => Container()));
  }
}

class _MyAppState extends State<MyApp> {
  late StreamSubscription<ThemeData> subscription;
  ThemeData appTheme = ThemeData.light();
  @override
  void dispose() {
    super.dispose();
    subscription.cancel();
  }
  
  @override
  void initState() {
    super.initState();
    setState(() {
      subscription = MyApp.streamController.stream.listen((event) { 
        setState(() {
          appTheme = event;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: appTheme,
      navigatorKey: navigatorKey,
      home: const Login(),
    );
  }
}
