// import 'package:flutter/material.dart';
// import 'package:internmatch/ProjectEnv.dart';
// import 'package:internmatch/pages/UserMenu.dart';
// import 'Dashboard.dart';
// import 'JournalList.dart';

// var dashContext;
// var _currentIndex = 0;
// const List<Widget> _widgetOptions = <Widget>[
//   Text(
//     'Index 0: Home',
//   ),
//   Text(
//     'Index 1: Business',
//   ),
//   Text(
//     'Index 2: School',
//   ),
// ];

// Widget bottomNav(_eventHelper, context) {
//   dashContext = context;
//   int _currentIndex = 0;
//   final List<Widget> _children = [];
//   return (BottomNavigationBar(
//     type: BottomNavigationBarType.fixed,
//     backgroundColor: Color(ProjectEnv.projectColor),
//     onTap: onTabTapped, // new
//     currentIndex: _currentIndex,
//     items: [
//       BottomNavigationBarItem(
//         icon: new Icon(Icons.dashboard, color: Colors.white),
//         title: new Text(
//           'Dashboard',
//           style: TextStyle(color: Colors.white),
//         ),
//       ),
//       BottomNavigationBarItem(
//         icon: new Icon(Icons.book, color: Colors.white),
//         title: new Text(
//           'View Journals',
//           style: TextStyle(color: Colors.white),
//         ),
//       ),
//       BottomNavigationBarItem(
//         icon: new Icon(Icons.more_vert, color: Colors.white),
//         title: new Text(
//           'More',
//           style: TextStyle(color: Colors.white),
//         ),
//       ),
//     ],
//   ));
// }

// void onTabTapped(int index) {
//   print(index);
//   _currentIndex = index;
//   print(_currentIndex);
// }

// Route _journalListRoute(_journalLists, _eventHelper) {
//   return PageRouteBuilder(
//     pageBuilder: (context, animation, secondaryAnimation) =>
//         JournalList( _eventHelper),
//     transitionsBuilder: (
//       context,
//       animation,
//       secondaryAnimation,
//       child,
//     ) {
//       var begin = Offset(1.0, 0.0);
//       var end = Offset.zero;
//       var curve = Curves.ease;
//       var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
//       var offsetAnimation = animation.drive(tween);
//       return SlideTransition(
//         position: offsetAnimation,
//         child: child,
//       );
//     },
//   );
// }

// Route _dashboardRoute(_eventhelper) {
//   return PageRouteBuilder(
//     pageBuilder: (context, animation, secondaryAnimation) =>
//         Dashboard(_eventhelper),
//     transitionsBuilder: (
//       context,
//       animation,
//       secondaryAnimation,
//       child,
//     ) {
//       var begin = Offset(1.0, 0.0);
//       var end = Offset.zero;
//       var curve = Curves.ease;
//       var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
//       var offsetAnimation = animation.drive(tween);
//       return SlideTransition(
//         position: offsetAnimation,
//         child: child,
//       );
//     },
//   );
// }

// Route _UserMenuRoute(_eventhelper) {
//   return PageRouteBuilder(
//     pageBuilder: (context, animation, secondaryAnimation) =>
//         UserMenu(_eventhelper),
//     transitionsBuilder: (
//       context,
//       animation,
//       secondaryAnimation,
//       child,
//     ) {
//       var begin = Offset(1.0, 0.0);
//       var end = Offset.zero;
//       var curve = Curves.ease;
//       var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
//       var offsetAnimation = animation.drive(tween);
//       return SlideTransition(
//         position: offsetAnimation,
//         child: child,
//       );
//     },
//   );
// }

// Widget screen() {
//   return (_widgetOptions.elementAt(_currentIndex));
// }
