// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:fluttertoast/fluttertoast.dart';

// class PushNotificationsManager {

//   PushNotificationsManager._();

//   factory PushNotificationsManager() => _instance;

//   static final PushNotificationsManager _instance = PushNotificationsManager._();

//   final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
//   FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();

//   bool _initialized = false;

//   Future onSelectNotification(String payload) async {
//     // if (payload != null) {
//     //   print('notification payload: ' + payload, debug: true);
//     // }
//     await Fluttertoast.showToast(
//         msg: "Notification Clicked",
//         toastLength: Toast.LENGTH_SHORT,
//         gravity: ToastGravity.BOTTOM,
//         timeInSecForIos: 1,
//         backgroundColor: Colors.black54,
//         textColor: Colors.white,
//         fontSize: 16.0);
//     /*Navigator.push(
//       context,
//       new MaterialPageRoute(builder: (context) => new SecondScreen(payload)),
//     );*/
//   }

//   Future onDidRecieveLocalNotification(
//       int id, String title, String body, String payload) async {
//     // display a dialog with the notification details, tap ok to go to another page
//     showDialog(
//       context: context,
//       builder: (BuildContext context) => new CupertinoAlertDialog(
//         title: new Text(title),
//         content: new Text(body),
//         actions: [
//           CupertinoDialogAction(
//             isDefaultAction: true,
//             child: new Text('Ok'),
//             onPressed: () async {
//               Navigator.of(context, rootNavigator: true).pop();
//               await Fluttertoast.showToast(
//                   msg: "Notification Clicked",
//                   toastLength: Toast.LENGTH_SHORT,
//                   gravity: ToastGravity.BOTTOM,
//                   timeInSecForIos: 1,
//                   backgroundColor: Colors.black54,
//                   textColor: Colors.white,
//                   fontSize: 16.0);
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> init() async {
//     if (!_initialized) {
      
//       // For iOS request permission first.
//       _firebaseMessaging.requestNotificationPermissions();
//       _firebaseMessaging.configure();

//       // For testing purposes print the Firebase Messaging token
//       String token = await _firebaseMessaging.getToken();
//       print("FirebaseMessaging token: $token");
      
//       _initialized = true;
//     }
//   }
// }