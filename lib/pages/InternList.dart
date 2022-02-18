import 'package:flutter/material.dart';

import '../ProjectEnv.dart';
import '../models/BaseEntity.dart';
import '../pages/CustomState.dart';
import '../utils/internmatch/GetTokenData.dart';
import '../utils/internmatch/UserEventHelper.dart';
import '../widgets/InternListBuilder.dart';

class InternList extends StatefulWidget {
  UserEventHelper _eventHelper;

  InternList(UserEventHelper eventHelper) {
    _eventHelper = eventHelper;
  }

  @override
  _InternListState createState() => _InternListState();
}

class _InternListState extends CustomState<InternList> {
  var _user;
  var firstname;

  Future<bool> waitForItems() async {
    return BaseEntity.getBaseEntityByCode("USER").then((user) {
      this._user = user;
      if (user != null) {
        this.firstname =
            user.getValue("PRI_FIRSTNAME", tokenData["given_name"].toString());
        // print("firstname from be is ${this.firstname}");

      } else {
        this.firstname = tokenData["given_name"].toString();
      }
      return true;
    });
  }

  @override
  Future<bool> loadWidget(BuildContext context, isInit) async {
    return await waitForItems();
  }

  @override
  void initState() {
    super.initState();
    super.setState(() {});
    setState(() {});
  }

  @override
  Widget customBuild(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
            appBar: new AppBar(
              centerTitle: true,
              title: Text("Interns you Supervise"),
              backgroundColor: Color(ProjectEnv.projectColor),
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: Container(
              child: InternListBuilder(widget._eventHelper, true, firstname),
              padding: const EdgeInsets.all(10.0),
            )));
  }
}
