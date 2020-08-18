import 'package:flutter/material.dart';
import '../models/BaseEntity.dart';
import '../pages/AppInfo.dart';
import '../pages/Profile.dart';
import '../pages/Support.dart';
import 'package:intl/intl.dart';
import 'package:package_info/package_info.dart';
import '../utils/internmatch/UserEventHelper.dart';
import '../pages/Dashboard.dart';
import '../ProjectEnv.dart';
import '../utils/internmatch/SqlConsole.dart';
import 'CustomState.dart';

//var _eventhelper;
class UserMenu extends StatefulWidget {
  UserEventHelper _eventHelper;

  UserMenu(UserEventHelper eventHelper) {
    _eventHelper = eventHelper;
  }

  @override
  _UserMenuState createState() => _UserMenuState();
}

class _UserMenuState extends CustomState<UserMenu> {
  BaseEntity user;
  DateTime date = DateTime.now();
  DateFormat dateFormat = new DateFormat().addPattern("EEEE, MMMM d y");
  String versionName;

  Future<bool> getUser() async {
    return BaseEntity.getBaseEntityByCode("USER").then((be) {
      this.user = be;
      return true;
    });
  }

  @override
  Future<bool> loadWidget(BuildContext context, isInit) async {
    await getVersion().then((version) {
      versionName = version;
    });
    return true;
  }

  Future<String> getVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    print("Version is: ${packageInfo.version}");
    return packageInfo.version.toString();
  }

  @override
  Widget customBuild(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          appBar: new AppBar(
            centerTitle: true,
            title: Text("Account"),
            backgroundColor: Color(ProjectEnv.projectColor),
          ),
          backgroundColor: Colors.white,
          body: Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                FlatButton(
                    child: CircleAvatar(
                      radius: 100,
                      backgroundColor: Colors.white,
                      backgroundImage: AssetImage("images/OfficialLogo-TB.png"),
                    ),
                    onPressed: () {},
                    onLongPress: () async {
                      Navigator.of(context).push(_sqlConsoleRoute());
                    }),
                Card(
                  color: Colors.white,
                  margin:
                      EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                  child: ListTile(
                    leading: Icon(
                      Icons.account_circle,
                      color: Color(ProjectEnv.projectColor),
                    ),
                    title: Text("Profile",
                        style: TextStyle(
                          fontSize: 20,
                          color: Color(ProjectEnv.projectColor),
                        )),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Profile()),
                      );
                    },
                  ),
                ),
                Card(
                  color: Colors.white,
                  margin:
                      EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                  child: ListTile(
                    leading: Icon(
                      Icons.info,
                      color: Color(ProjectEnv.projectColor),
                    ),
                    title: Text("Help and Support",
                        style: TextStyle(
                          fontSize: 20,
                          color: Color(ProjectEnv.projectColor),
                        )),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Support(versionName)),
                      );
                    },
                  ),
                ),
                Card(
                  color: Colors.white,
                  margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10),
                  child: ListTile(
                    leading: Icon(
                      Icons.help,
                      color: Color(ProjectEnv.projectColor),
                    ),
                    title: Text("App info",
                        style: TextStyle(
                          fontSize: 20,
                          color: Color(ProjectEnv.projectColor),
                        )),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AppInfo(versionName)),
                      );
                    },
                  ),
                ),
                Card(
                  color: Colors.white,
                  margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10),
                  child: ListTile(
                    leading: Icon(
                      Icons.exit_to_app,
                      color: Color(ProjectEnv.projectColor),
                    ),
                    title: Text("Sign Out",
                        style: TextStyle(
                          fontSize: 20,
                          color: Color(ProjectEnv.projectColor),
                        )),
                    onTap: () {
                      Navigator.pop(context);
                      widget._eventHelper.logout();
                    },
                  ),
                ),
                RaisedButton(
                shape: RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(200.0),
                ),
                color: Colors.green,
                child: Text('sqlConsoleRoute',
                    style: TextStyle(color: Colors.white, fontSize: 15)),
                onPressed: () {
                  Navigator.of(context).push(_sqlConsoleRoute());
                }),
                displayDev(context, user),
              ])),
        ));
  }

  Widget displayDev(context, user) {
    getUser();
    if ((user != null) && (user.hasRole("DEV"))) {
      return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RaisedButton(
                shape: RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(200.0),
                ),
                color: Colors.green,
                child: Text('sqlConsoleRoute',
                    style: TextStyle(color: Colors.white, fontSize: 15)),
                onPressed: () {
                  Navigator.of(context).push(_sqlConsoleRoute());
                }),
          ]);
    } else {
      return Container(width: 0.0);
    }
  }
}

Route _dashboardlRoute(_eventhelper) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) =>
        Dashboard(_eventhelper),
    transitionsBuilder: (
      context,
      animation,
      secondaryAnimation,
      child,
    ) {
      var begin = Offset(1.0, 0.0);
      var end = Offset.zero;
      var curve = Curves.easeOutSine;
      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      var offsetAnimation = animation.drive(tween);
      return SlideTransition(
        position: offsetAnimation,
        child: child,
      );
    },
  );
}

Route _sqlConsoleRoute() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => SqlConsole(),
    transitionsBuilder: (
      context,
      animation,
      secondaryAnimation,
      child,
    ) {
      var begin = Offset(1.0, 0.0);
      var end = Offset.zero;
      var curve = Curves.easeOutSine;
      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      var offsetAnimation = animation.drive(tween);
      return SlideTransition(
        position: offsetAnimation,
        child: child,
      );
    },
  );
}
