import 'package:flutter/material.dart';

Widget showAlertMessage(String message, context) {
  AlertDialog alertDialog = AlertDialog(
      title: Text("Information"),
      content: Container(
        child: SingleChildScrollView(
          child: Text(message),
        ),
      ));
  showDialog(context: context, builder: (_) => alertDialog);
}