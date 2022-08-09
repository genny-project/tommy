import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geoff/utils/networking/auth/app_auth_helper.dart';
import 'package:geoff/utils/networking/auth/session.dart';
import 'package:geoff/utils/system/log.dart';
import 'package:tommy/genny_viewport.dart';
import 'package:tommy/utils/bridge_env.dart';
import 'package:http/http.dart' as http;

class Login extends StatelessWidget {
  static final Log _log = Log("Login");

  const Login({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: false,
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center, children: [
            const Text("TOMMY", style: TextStyle(fontSize: 50, fontWeight: FontWeight.w900),),
            OutlinedButton(
              style: ButtonStyle(shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)))),
                onPressed: () {
                  http.get(Uri.parse(BridgeEnv.bridgeUrl)).then((response) async {
                    Map<String, dynamic> data = jsonDecode(response.body);
                    _log.info("Bridge Data $data");
                    BridgeEnv.map.forEach(
                      (key, val) {
                        _log.info("Key $key");
                        if (data.containsKey(key)) {
                          BridgeEnv.map[key]!(data[key]);
                        } else {
                          _log.warning("Key not found $key");
                        }
                      },
                    );
                    _log.info("Value body ${BridgeEnv.realm}");
                    _log.info("Keycloak URI ${BridgeEnv.ENV_KEYCLOAK_REDIRECTURI}");
                    await AppAuthHelper.login(
                            authServerUrl: BridgeEnv.ENV_KEYCLOAK_REDIRECTURI,
                            realm: BridgeEnv.realm,
                            clientId: BridgeEnv.clientID,
                            redirectUrl:
                                "life.genny.tommy.appauth://oauth/login_success/")
                        .then((response) {
                      if (response) {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const GennyViewport()));
                      }
                    });
                    _log.info("Access token ${Session.tokenResponse!.accessToken}");
                    if (Session.tokenResponse!.accessToken != null) {}
                  });
                },
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: const Center(child: Text("Login"))))
          ]),
        ),
      ),
    );
  }
}
