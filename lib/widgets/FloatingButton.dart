import 'package:flutter/material.dart';
import '../models/BaseEntity.dart';
import '../utils/internmatch/GetTokenData.dart';
import '../pages/AddJournal.dart';
import '../pages/JournalList.dart';


Widget floatingButton(context, widget, updateJournalList, BaseEntity user, _eventHelper) {
  if (user.hasRole("SUPERVISOR")) {
    return (null);
  } else {
    return (Padding(
      padding: const EdgeInsets.all(20.0),
      child: FloatingActionButton.extended(
        shape: RoundedRectangleBorder(
          borderRadius: new BorderRadius.circular(200.0),
        ),
        backgroundColor: Colors.green,
        onPressed: () async {
          //setState(() {});
          await Navigator.of(context).push(
              _addJournalRoute(_eventHelper, true, updateJournalList));
          // getJournals();
        },
        label: Text("Add Journal",
            textAlign: TextAlign.center, style: TextStyle(fontSize: 15)),
        elevation: 2.0,
      ),
    ));
  }
}


Route _addJournalRoute(_eventhelper, _enabled, updateCallback) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) =>
        AddJournal(_eventhelper, true, updateCallback),
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

