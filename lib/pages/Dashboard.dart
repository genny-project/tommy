import 'package:flutter/material.dart';
import '../ProjectEnv.dart';
import '../pages/FetchJournals.dart';
import '../utils/internmatch/DatabaseHelper.dart';
import '../utils/internmatch/EventHandler.dart';
import '../utils/internmatch/Sync.dart';
import '../utils/internmatch/UserEventHelper.dart';
import '../pages/JournalList.dart';
import '../pages/DashboardScreen.dart';
import 'UserMenu.dart';

class Dashboard extends StatefulWidget {
  UserEventHelper _eventHelper;

  Dashboard(UserEventHelper eventHelper) {
    _eventHelper = eventHelper;
  }

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> with WidgetsBindingObserver {
  DatabaseHelper databaseHelper = DatabaseHelper();
  EventHandler eventHandler;
  var _currentIndex = 0;

  void setIndex(index) {
    setState(() {
      _currentIndex = index;
    });
  }

    void updateJournalList() async {
    await fetchBaseEntity("UNAPPROVED");
    await fetchBaseEntity("APPROVED");
    await fetchBaseEntity("REJECTED");
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    super.setState(() {});
    setState(() {});
    WidgetsBinding.instance.addObserver(this);
    updateJournalList();
  }

  Future<void> doSync() async {
    await Sync.performSync();
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
      print("Dashbboard showing");
    }
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    final _pageOptions = [
      DashboardScreen(widget._eventHelper, setIndex),
      JournalList(widget._eventHelper, updateJournalList),
      UserMenu(widget._eventHelper),
    ];
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Color(ProjectEnv.projectColor),
          onTap: (int index) async {
            setState(() {
              _currentIndex = index;
            });
          },
          currentIndex: _currentIndex,
          items: [
            BottomNavigationBarItem(
              icon: new Icon(Icons.dashboard, color: Colors.white),
              title: new Text(
                'Dashboard',
                style: TextStyle(color: Colors.white),
              ),
            ),
            BottomNavigationBarItem(
              icon: new Icon(Icons.book, color: Colors.white),
              title: new Text(
                'View Journals',
                style: TextStyle(color: Colors.white),
              ),
            ),
            BottomNavigationBarItem(
              icon: new Icon(Icons.account_circle, color: Colors.white),
              title: new Text(
                'Account',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        key: _scaffoldKey,
        body: IndexedStack(children: <Widget>[
          Center(
            child: _pageOptions[_currentIndex],
          ),
        ]),
      ),
    );
  }
}