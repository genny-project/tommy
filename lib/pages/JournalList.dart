import 'dart:async';
import 'package:flutter/material.dart';
import '../models/BaseEntity.dart';
import '../pages/CustomState.dart';
import '../utils/internmatch/UserEventHelper.dart';
import '../widgets/ListBuilder.dart';
import '../ProjectEnv.dart';
import '../pages/DashboardScreen.dart';

class JournalList extends StatefulWidget {
  static final _myTabbedPageKey = new GlobalKey<_JournalListState>();
  UserEventHelper _eventHelper;
  var _callback;

  JournalList(UserEventHelper eventHelper, updateJournalList()) {
    _eventHelper = eventHelper;
    _callback = updateJournalList;
  }

  @override
  _JournalListState createState() => _JournalListState();
}

class _JournalListState extends CustomState<JournalList>
    with SingleTickerProviderStateMixin {
  var user;
  TabController tabController;
  static var count1 = 0;
  static var count2 = 0;
  static var count3 = 0;

  final List<Tab> myTabs = <Tab>[
    new Tab(text: 'Submitted($count1)'),
    new Tab(text: 'Approved($count2)'),
    new Tab(text: 'Rejected($count3)')
  ];

  Future<bool> waitForItems() async {
    return getFilteredList().then((value) {
      return BaseEntity.getBaseEntityByCode("USER").then((user) {
        this.user = user;
        return true;
      });
    });
  }

  Future<bool> getFilteredList() async {
    return BaseEntity.fetchBaseEntitys("JNL_", "PRI_STATUS", "UNAPPROVED")
        .then((value1) {
      return BaseEntity.fetchBaseEntitys("JNL_", "PRI_STATUS", "APPROVED")
          .then((value2) {
        return BaseEntity.fetchBaseEntitys("JNL_", "PRI_STATUS", "REJECTED")
            .then((value3) {
          count1 = value1.length;
          count2 = value2.length;
          count3 = value3.length;
          return true;
        });
      });
    });
  }

  @override
  Future<bool> loadWidget(BuildContext context, isInit) async {
    return await waitForItems();
  }

  @override
  void initState() {
    super.initState();
    widget._callback;
    tabController = new TabController(vsync: this, length: myTabs.length);
    tabController.animateTo(tabIndex);
    super.setState(() {});
    setState(() {});
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget customBuild(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        key: _scaffoldKey,
        extendBody: true,
        appBar: new AppBar(
          bottom: new TabBar(
            controller: tabController,
            tabs: myTabs,
            onTap: (int index) {},
          ),
          centerTitle: true,
          title: Text(ProjectEnv.projectName),
          backgroundColor: Color(ProjectEnv.projectColor),
        ),
        body: new Container(
            padding: const EdgeInsets.only(
              bottom: 30.0,
            ),
            child: TabBarView(
              controller: tabController,
              children: <Widget>[
                ListBuilder(widget._eventHelper, "UNAPPROVED", user,
                    Colors.orangeAccent),
                ListBuilder(
                    widget._eventHelper, "APPROVED", user, Colors.green),
                ListBuilder(
                    widget._eventHelper, "REJECTED", user, Colors.redAccent),
              ],
            )),
      ),
    );
  }
}
