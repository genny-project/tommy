import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tommy/genny_viewport.dart';
import 'package:tommy/models/BridgeEnv.dart';
import 'package:tommy/models/Session.dart';
import 'package:tommy/utils/AppAuthHelper.dart';
import 'package:http/http.dart' as http;

class Login extends StatelessWidget {
  const Login({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        TextButton(
            onPressed: () {
              http.get(Uri.parse(BridgeEnvs.bridgeUrl)).then((response) async {
                Map<String,dynamic> data = jsonDecode(response.body);
                BridgeEnvs.map.forEach(
                  (key, val) {
                    print("Key $key");
                    try {
                      BridgeEnvs.map[key](data[key]);
                    } catch (e) {
                      print("Key not found $key");
                    }
                    
                  },
                );
                print("Value body ${data}");
                Session.tokenResponse = await AppAuthHelper.authTokenResponse();
                print("Access token ${Session.tokenResponse?.accessToken}");
                if(Session.tokenResponse?.accessToken != null) {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => const GennyViewport()));
                }
              });
            },
            child: Text("Login"))
      ]),
    );
  }
}
