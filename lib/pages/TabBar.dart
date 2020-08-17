import 'package:flutter/material.dart';

Widget tabBar() {
  return (TabBar(
    tabs: [
      Tab(text: "Unapproved"),
      Tab(text: "Approved"),
      Tab(text: "Rejected"),
    ],
  ));
}

Widget tabBarView() {
  return (TabBarView(
    children: <Widget>[Text("First"), Text("Second"), Text("Third")],
  ));
}
