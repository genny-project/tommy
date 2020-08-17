import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:image_picker/image_picker.dart';
import 'package:internmatch/utils/internmatch/Device.dart';
import 'package:internmatch/ProjectEnv.dart';
import 'package:internmatch/utils/internmatch/GetTokenData.dart';
import 'package:internmatch/utils/internmatch/VersionInfo.dart';
import 'package:url_launcher/url_launcher.dart';

// This class is
class Support extends StatefulWidget {
  static var version;

  Support(var versionName) {
    version = versionName;
  }
  @override
  _SupportState createState() => _SupportState();
}

class _SupportState extends State<Support> {
  List<String> attachments = [];
  bool isHTML = false;

  final _recipientController = TextEditingController(
    text: 'hello@outcome.life',
  );

  final _subjectController =
      TextEditingController(text: 'InternMatch App - ${tokenData['name']}');

  final _bodyController = TextEditingController(
    text:
        'Device OS: ${Device.deviceType} \nDevice Version: ${Device.deviceVersion} \nApp Version:  ${Version.version}',
  );

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<void> sendIOS() async {
    String body = _bodyController.text.toString();
    String email = _recipientController.text.toString();
    final Uri params = Uri(
      scheme: 'mailto',
      path: '$email',
      query:
          'subject= InternMatch App - ${tokenData['name']} &body=  $body', //add subject and body here
    );

    var url = params.toString();
    if (await canLaunch(url)) {
      await launch(url);
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text("Success! Email sent"),
      ));
    } else {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text("Could not send email. Please  try again in some time"),
      ));
      throw 'Could not launch $url';
    }
  }

  Future<void> sendAndroid() async {
    final Email email = Email(
      body: _bodyController.text,
      subject: _subjectController.text,
      recipients: [_recipientController.text],
      attachmentPaths: attachments,
      isHTML: isHTML,
    );

    String platformResponse;

    try {
      await FlutterEmailSender.send(email);
      platformResponse = 'success';
    } catch (error) {
      platformResponse = error.toString();
    }

    if (!mounted) return;

    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(platformResponse),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primaryColor: Colors.red),
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        key: _scaffoldKey,
        appBar: AppBar(
          backgroundColor: Color(ProjectEnv.projectColor),
          title: Text('Support Email'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: <Widget>[
            IconButton(
              onPressed: () {
                if (Platform.isIOS) {
                  sendIOS();
                } else if (Platform.isAndroid) {
                  sendAndroid();
                }
              },
              icon: Icon(Icons.send),
            )
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: TextField(
                    readOnly: true,
                    controller: _recipientController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Recipient',
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: TextField(
                    readOnly: true,
                    controller: _subjectController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Subject',
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _bodyController,
                    maxLines: 10,
                    decoration: InputDecoration(
                        labelText: 'Body', border: OutlineInputBorder()),
                  ),
                ),
                // CheckboxListTile(
                //   title: Text('HTML'),
                //   onChanged: (bool value) {
                //     setState(() {
                //       isHTML = value;
                //     });
                //   },
                //   value: isHTML,
                // ),
                ...attachments.map(
                  (item) => Text(
                    item,
                    overflow: TextOverflow.fade,
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: Colors.green,
          icon: Icon(Icons.camera),
          label: Text('Add Image'),
          onPressed: _openImagePicker,
        ),
      ),
    );
  }

  void _openImagePicker() async {
    File pick = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      attachments.add(pick.path);
    });
  }
}
