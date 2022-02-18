import 'dart:async';

import 'package:flutter/material.dart';

import '../ProjectEnv.dart';
import '../models/SessionData.dart';
import '../pages/Dashboard.dart';
import '../pages/Login.dart';
import '../utils/internmatch/AppAuthHelper.dart';
import '../utils/internmatch/DatabaseHelper.dart';
import '../utils/internmatch/Device.dart';
import '../utils/internmatch/EventHandler.dart';
import '../utils/internmatch/UserEventHelper.dart';
import '../utils/internmatch/VersionInfo.dart';

class Home extends StatefulWidget {
  Home({Key key}) : super(key: key);

  @override
  State createState() => new AuthSession();
}

class AuthSession extends State<Home> with WidgetsBindingObserver {
  //We need to call this function as it initates the State
  EventHandler _eventHandler;
  Widget _currentView;
  Timer timer;
  @override
  void initState() {
    print("Initialising StartApp initState");

    WidgetsBinding.instance.addObserver(this);
    !Session.isLoggedIn ? _currentView = Login(login) : setup();
    super.initState();

    // timer = Timer.periodic(Duration(seconds: 360 * 5),
    //     (Timer t) => AppAuthHelper.authTokenResponse());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('state = $state');
    if (AppLifecycleState.resumed == state) {
      print("Home showing");
    }
  }

  void setup() async {
    _eventHandler = new EventHandler(logout);
    //getBridgeData();

    //DatabaseHelper.internal().initDb();
    await DatabaseHelper.internal().db;
    // Sync.doTheSync();
    Device device = new Device();
    Version version = new Version();
    device.initPlatformState().then((_) {
      version.initPlatformState().then((_) {
        //Sync.performSync().then((_) {
        setCurrentView(Dashboard(new UserEventHelper(_eventHandler)));
        // });
      });
    });
  }

  void logout() async {
    AppAuthHelper.logOut();
    Session.sessionState = SessionState.LoggedOut;
    _eventHandler = null;
    setCurrentView(Login(login));
  }

  void login() async {
    // Session.sessionState = SessionState.LoggedIn;
    // setup();
    Session.tokenResponse = await AppAuthHelper.authTokenResponse();
    if ((Session.tokenResponse != null) || (ProjectEnv.token != null)) {
      Session.sessionState = SessionState.LoggedIn;
      setup();
    }
  }

  /*
   * Calling this function will re-render the widget, by calling build function with current state
  */
  void setCurrentView(Widget view) {
    setState(() {
      _currentView = view;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentView,
    );
  }
}
