// import 'dart:convert';
// import './utils/MessageWrapper.dart';
// import 'package:web_socket_channel/io.dart';
// import "dart:async";
// import './models/Event.dart';

// void main() {
//   sendEvent(
//       event: sendCode, sendWithToken: false, data: "asas", eventType: "semd");
// }

// sendEvent({event, sendWithToken, eventType, data, items, beCode}) {
//   // generate Event
//   var accessToken;
//   OutgoingEvent eventObject;

//   if (sendWithToken) {
//     accessToken = "asdasd";
//   }

//   eventObject = event(
//       eventType: eventType,
//       data: data,
//       token: accessToken,
//       items: items,
//       beCode: beCode);
//   final eventMessage = eventObject.eventMsg().toString();
//   print('sending event ::' + eventMessage);
// }
