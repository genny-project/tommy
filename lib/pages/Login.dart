import 'package:flutter/material.dart';
import 'package:internmatch/ProjectEnv.dart';


class Login extends StatelessWidget {
  Function _login;

  Login(Function callback) {
    _login = callback;
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: new BoxDecoration(color: new Color(ProjectEnv.projectColor)),
      alignment: Alignment.center,
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          new Image.asset(ProjectEnv.img,
              width: 300, repeat: ImageRepeat.noRepeat, height: 300),
          SizedBox(
          height: 50,
          width: 200,
            child: OutlineButton(
              borderSide: BorderSide(
                color: Colors.white,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(200.0),
              ),
              color: Color(ProjectEnv.projectColor),
              child: Text("Login",
                  style: TextStyle(
                    color: Colors.white, fontSize: 20
                  )),
              onPressed: (() => _login()),
            ),
          )
        ],
      ),
    );
  }
}