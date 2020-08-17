import 'package:flutter/material.dart';
import 'package:internmatch/ProjectEnv.dart';
import 'package:internmatch/models/BaseEntity.dart';
import 'package:internmatch/pages/CustomState.dart';
import 'package:internmatch/pages/FetchJournals.dart';
import 'package:internmatch/utils/internmatch/DatabaseHelper.dart';
import 'package:internmatch/utils/internmatch/EventHandler.dart';
import 'package:internmatch/utils/internmatch/GetTokenData.dart';
import 'package:internmatch/utils/internmatch/Sync.dart';
import 'package:internmatch/utils/internmatch/UserEventHelper.dart';
import 'package:internmatch/widgets/FloatingButton.dart';
import 'package:internmatch/widgets/countButton.dart';

int tabIndex = 0;
String unapprovedCount;
String approvedCount;
String rejectedCount;

class DashboardScreen extends StatefulWidget {
  UserEventHelper _eventHelper;
  var _journalLists;
  var _setIndex;

  DashboardScreen(UserEventHelper eventHelper, setIndex) {
    _eventHelper = eventHelper;
    _setIndex = setIndex;
  }

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends CustomState<DashboardScreen>
    with WidgetsBindingObserver {
  DatabaseHelper databaseHelper = DatabaseHelper();
  EventHandler eventHandler;
  var user;
  var firstname;
  var _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    super.setState(() {});
    setState(() {});
    WidgetsBinding.instance.addObserver(this);
  }

  void updateJournalList() async {
    print("Syncing Data in page refresh");
    await fetchBaseEntity("UNAPPROVED");
    await fetchBaseEntity("APPROVED");
    await fetchBaseEntity("REJECTED");
    setState(() {});
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
      print("Dashboard Screen showing");
    }
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final navigatorKey = GlobalKey<NavigatorState>();

  Future<bool> callAsyncFetch() =>
      Future.delayed(Duration(seconds: 2), () => true);

  Future<bool> waitForName() async {
     return Sync.performSync().then((_) {
    return BaseEntity.getBaseEntityByCode("USER").then((user) {
      this.user = user;
      if (user != null) {
        this.firstname =
            user.getValue("PRI_FIRSTNAME", tokenData["given_name"].toString());
        // print("firstname from be is ${this.firstname}");

      } else {
        this.firstname = tokenData["given_name"].toString();
      }
      return true;
    });
     });
  }

  @override
  Future<bool> loadWidget(BuildContext context, isInit) async {
    return await waitForName();
    //return await waitForUnapprovedCount();
  }

  @override
  Widget customBuild(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            floatingActionButton: floatingButton(context, widget,
                updateJournalList, this.user, widget._eventHelper),
            appBar: new AppBar(
              elevation: 0.0,
              centerTitle: true,
              title: Text(ProjectEnv.projectName),
              backgroundColor: Color(ProjectEnv.projectColor),
            ),
            key: _scaffoldKey,
            body: ListView(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.only(
                    top: 20.0,
                  ),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: new Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(bottom: 10.0),
                                child: Text(
                                  "Hi ${this.firstname},",
                                  style: TextStyle(
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blueGrey),
                                ),
                              ),
                              Center(
                                child: Text(
                                  "Here is your total for today",
                                  style: TextStyle(
                                      fontSize: 15, color: Colors.blueGrey),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(padding: new EdgeInsets.all(10.0)),
                        Container(
                            alignment: Alignment.topCenter,
                            child: displayCountButtons(context, widget, user,
                                updateJournalList, widget._setIndex)),
                      ]),
                ),
              ],
            )));
  }
}

Widget displayCountButtons(
    context, widget, user, updateJournalList, _setIndex) {
  if (user.hasRole("INTERN")) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
      CountButton(Colors.orangeAccent, "UNAPPROVED", "JNL_", "PRI_STATUS",
          "UNAPPROVED", updateJournalList, _setIndex, 0, false),
      CountButton(Colors.green, "APPROVED", "JNL_", "PRI_STATUS", "APPROVED",
          updateJournalList, _setIndex, 1, false),
      CountButton(Colors.redAccent, "REJECTED", "JNL_", "PRI_STATUS",
          "REJECTED", updateJournalList, _setIndex, 2, false)
    ]);
  }
  if (user.hasRole("SUPERVISOR")) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
      CountButton(
          Colors.orangeAccent,
          "Journals you need\n        to approve",
          "JNL_",
          "PRI_STATUS",
          "UNAPPROVED",
          updateJournalList,
          _setIndex,
          0,
          false),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: CountButton(
            Colors.green,
            "Interns you \n  supervise",
            "PER_",
            "PRI_IS_INTERN",
            "UNAPPROVED",
            updateJournalList,
            _setIndex,
            0,
            true),
      ),
    ]);
  } else {
    return Container(width: 0.0);
  }
}
