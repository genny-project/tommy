import 'dart:core';

import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/io.dart';
import 'dart:convert';

WebSockets socket = new WebSockets();

class WebSockets {
  static final WebSockets _sockets = new WebSockets._internal();

  factory WebSockets() {
    return _sockets;
  }

  WebSockets._internal();

  /*websocket ope channel */
  IOWebSocketChannel _channel;

  var channel1;

  bool _isOn = false;

  /*CLoses the webSocket Communication*/
  // reset() {
  //   if (_channel != null) {
  //     if (_channel.sink != null) {
  //       _channel.sink.close();
  //       _isOn = false;
  //     }
  //   }
  // }

  /* Listener */
  /* List of methods to be called when a new message*/
  /* comes in. */

  ObserverList<Function> _listener = new ObserverList<Function>();

  /* Initializint the web socket connection */

  initCommunication(vertexUrl) async {
    try {
      String socketUrl = getUrlForWebSocket(vertexUrl);
      _channel = IOWebSocketChannel.connect(socketUrl,
          pingInterval: new Duration(seconds: 5));
      _channel.stream.listen(_onIncomingMessage);
      /* common handler to receiving message from server */
    } catch (e) {
      print("WebSocket: Unable to make a connection with :" + vertexUrl);
      print("Exception logs: " + e.toString());
    }
  }

  /*This method customized http: vertexurl to wss*/
  String getUrlForWebSocket(vertexUrl) {
    RegExp regExp = new RegExp("^wss:\/\/.*websocket");
    if (regExp.firstMatch(vertexUrl) != null) {
      return vertexUrl;
    }

    regExp = new RegExp("https(.*)");
    String url = regExp.firstMatch(vertexUrl)?.group(1);
    if (url != null) {
      return "wss" + url + "/websocket";
    } else {
      return null;
    }
  }

  /* Send Auth_INIT Event message to the vertex*/
  sendMessage(message) {
    if (_channel != null) {
      if (_channel != null) {
        print("WebSocket: Sending Message ::: $message");
        _channel.sink.add(message);
      }
    }
  }

  /*Listenes for incomming message from server */
  registerListener() {
    _channel.stream.listen(_onIncomingMessage);
  }

  registerAddressToListener(address) {}

  registerAddressToSender(address) {}

  /*Remove for message from server */
  removeListener(Function callback) {
    _listener.remove(callback);
  }

  /*invoked each time when receiving the incoming message form the server*/
  _onIncomingMessage(message) {
    _isOn = true;
    print("Receiving form the server");
    var serverData = latin1.decode(message);
    print("Server Data ::: $serverData");
   // eventHandler.handleIncomingMessage(serverData);
  }
}
