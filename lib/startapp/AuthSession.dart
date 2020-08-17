import 'dart:async';
import 'package:flutter/material.dart';
import 'package:internmatch/StartApp/Home.dart';
import 'package:internmatch/models/SessionData.dart';
import 'package:internmatch/utils/internmatch/AppAuthHelper.dart';

import 'package:internmatch/utils/internmatch/EventHandler.dart';
import 'package:internmatch/utils/internmatch/UserEventHelper.dart';
import 'package:internmatch/pages/Dashboard.dart';
import 'package:internmatch/pages/Login.dart';
import '../ProjectEnv.dart';


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
    setCurrentView(Dashboard(new UserEventHelper(_eventHandler)));
  }

  void logout() async {
    AppAuthHelper.logOut();
    Session.sessionState = SessionState.LoggedOut;
    _eventHandler = null;
    setCurrentView(Login(login));
  }

  void login() async {
    Session.sessionState = SessionState.LoggedIn;
    setup();
    Session.tokenResponse = await AppAuthHelper.authTokenResponse();
    if ((Session.tokenResponse != null)||(ProjectEnv.token != null)) {
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