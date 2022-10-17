import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geoff/utils/networking/auth/app_auth_helper.dart';
import 'package:geoff/utils/networking/auth/session.dart';
import 'package:geoff/utils/system/log.dart';
import 'package:tommy/genny_viewport.dart';
import 'package:tommy/main.dart';
import 'package:tommy/projectenv.dart';
import 'package:tommy/utils/bridge_env.dart';
import 'package:http/http.dart' as http;
import 'package:tommy/utils/bridge_handler.dart';

class Login extends StatefulWidget {
  static final Log _log = Log("Login");

  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _urlController = TextEditingController(text: ProjectEnv.urls.first);
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: SafeArea(
        top: false,
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  !ProjectEnv.devMode
                      ? const String.fromEnvironment('APP_NAME')
                      : "TOMMY",
                  style: const TextStyle(
                      fontSize: 50, fontWeight: FontWeight.w900),
                ),
                OutlinedButton(
                    style: ButtonStyle(
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25)))),
                    onPressed: () {
                      ProjectEnv.baseUrl = _urlController.text;
                      Login._log.log(
                          "Devmode ${ProjectEnv.devMode} ${ProjectEnv.baseUrl}");
                      http
                          .get(Uri.parse(BridgeEnv.bridgeUrl))
                          .then((response) async {
                        Map<String, dynamic> data = jsonDecode(response.body);
                        Login._log.info("Bridge Data $data");
                        BridgeEnv.map.forEach(
                          (key, val) {
                            Login._log.info("Key $key");
                            if (data.containsKey(key)) {
                              BridgeEnv.map[key]!(data[key]);
                            } else {
                              Login._log.warning("Key not found $key");
                            }
                          },
                        );
                        Login._log.info("Value body ${BridgeEnv.realm}");
                        Login._log.info(
                            "Keycloak URI ${BridgeEnv.ENV_KEYCLOAK_REDIRECTURI}");
                        AppAuthHelper.setScopes(["openid"]);
                        await AppAuthHelper.login(
                                authServerUrl:
                                    BridgeEnv.ENV_KEYCLOAK_REDIRECTURI,
                                realm: BridgeEnv.realm,
                                clientId: BridgeEnv.clientID ?? BridgeEnv.realm,
                                redirectUrl:
                                    "life.genny.tommy.appauth://oauth/login_success/")
                            .then((response) {
                          if (response) {
                            navigatorKey.currentState!.pushReplacement(MaterialPageRoute(
                                builder: (context) => GennyViewport(
                                      key: Key(Session.tokenResponse!.idToken!),
                                    )));
                          }
                        });
                        Login._log.info(
                            "Access token ${Session.tokenResponse!.accessToken}");
                        if (Session.tokenResponse!.accessToken != null) {}
                      });
                    },
                    child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.5,
                        child: const Center(child: Text("Login")))),
                ProjectEnv.devMode
                    ? Container(
                      child: Column(
                          children: [
                             Container(
                                  padding: const EdgeInsets.all(8.0),
                                  child: TextFormField(
                                    controller: _urlController,
                                    onChanged: (value) {
                                      setState(() {
                                        ProjectEnv.baseUrl = value;
                                      });
                                    },
                                    decoration: const InputDecoration(
                                        labelText: "Server URL"),
                                  ),
                                ),
                            Container(
                                  padding: const EdgeInsets.all(8.0),
                                  child: TextFormField(
                                    
                                    initialValue: ProjectEnv.grpcPort.toString(),
                                    onChanged: (value) {
                                      setState(() {
                                        ProjectEnv.grpcPort = int.parse(value);
                                      });
                                    },
                                    decoration: const InputDecoration(
                                        labelText: "GRPC Port"),
                                  ),
                                )
                          ],
                        ),
                    )
                    : SizedBox(),
              ]),
        ),
      ),
    );
  }
}
