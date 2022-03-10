import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tommy/genny_viewport.dart';
import 'package:tommy/models/bridge_env.dart';
import 'package:tommy/models/session.dart';
import 'package:tommy/utils/app_auth_helper.dart';
import 'package:http/http.dart' as http;
import 'package:tommy/utils/log.dart';

class Login extends StatelessWidget {

  static final Log _log = Log("Login");
  
  const Login({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        TextButton(
            onPressed: () {
              http.get(Uri.parse(BridgeEnv.bridgeUrl)).then((response) async {
                Map<String,dynamic> data = jsonDecode(response.body);
                BridgeEnv.map.forEach(
                  (key, val) {
                    _log.info("Key $key");
                    try {
                      BridgeEnv.map[key](data[key]);
                    } catch (e) {
                      _log.error("Key not found $key", e);
                    }
                    
                  },
                );
                _log.info("Value body $data");
                Session.tokenResponse = await AppAuthHelper.authTokenResponse();
                _log.info("Access token ${Session.tokenResponse?.accessToken}");
                if(Session.tokenResponse?.accessToken != null) {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => const GennyViewport()));
                }
              });
            },
            child: const Text("Login"))
      ]),
    );
  }
}
