import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:internmatch/ProjectEnv.dart';
import 'package:internmatch/models/BaseEntity.dart';
import 'package:internmatch/pages/ViewJournal.dart';
import 'package:internmatch/utils/internmatch/GetTokenData.dart';

class Profile extends StatefulWidget {
  @override
  ProfileState createState() => ProfileState();
}

class ProfileState extends State<Profile> with SingleTickerProviderStateMixin {
  bool _status = true;
  final FocusNode myFocusNode = FocusNode();
  TextEditingController _nameController;
  TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _nameController = TextEditingController(text: tokenData['given_name']);
    _emailController = TextEditingController(text: tokenData['email']);
    return new Scaffold(
        appBar: AppBar(
          title: Text('Profile'),
          backgroundColor: Color(ProjectEnv.projectColor),
          leading: new IconButton(
              icon: new Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context)),
        ),
        body: new Container(
          color: Colors.white,
          child: new ListView(
            children: <Widget>[
              Column(
                children: <Widget>[
                  new Container(
                    color: Color(0xffFFFFFF),
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 25.0),
                      child: new Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                              padding: EdgeInsets.only(
                                  left: 25.0, right: 25.0, top: 25.0),
                              child: new Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  new Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      new Text(
                                        'Personal Information',
                                        style: TextStyle(
                                            fontSize: 18.0,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  new Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[],
                                  )
                                ],
                              )),
                          Padding(
                              padding: EdgeInsets.only(
                                  left: 25.0, right: 25.0, top: 25.0),
                              child: new Row(
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  new Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      new Text(
                                        'Name',
                                        style: TextStyle(
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ],
                              )),
                          Padding(
                              padding: EdgeInsets.only(
                                  left: 25.0, right: 25.0, top: 2.0),
                              child: new Row(
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  new Flexible(
                                    child: new TextFormField(
                                      controller: _nameController,
                                      decoration: const InputDecoration(),
                                      enabled: !_status,
                                      autofocus: !_status,
                                    ),
                                  ),
                                ],
                              )),
                          Padding(
                              padding: EdgeInsets.only(
                                  left: 25.0, right: 25.0, top: 25.0),
                              child: new Row(
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  new Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      new Text(
                                        'Email ID',
                                        style: TextStyle(
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ],
                              )),
                          Padding(
                              padding: EdgeInsets.only(
                                  left: 25.0, right: 25.0, top: 2.0),
                              child: new Row(
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  new Flexible(
                                    child: new TextField(
                                      controller: _emailController,
                                      decoration:
                                          const InputDecoration(hintText: ""),
                                      enabled: !_status,
                                    ),
                                  ),
                                ],
                              )),
                          // Padding(
                          //     padding: EdgeInsets.only(
                          //         left: 25.0, right: 25.0, top: 25.0),
                          //     child: new Row(
                          //       mainAxisSize: MainAxisSize.max,
                          //       children: <Widget>[
                          //         new Column(
                          //           mainAxisAlignment: MainAxisAlignment.start,
                          //           mainAxisSize: MainAxisSize.min,
                          //           children: <Widget>[
                          //             new Text(
                          //               'Host Company',
                          //               style: TextStyle(
                          //                   fontSize: 16.0,
                          //                   fontWeight: FontWeight.bold),
                          //             ),
                          //           ],
                          //         ),
                          //       ],
                          //     )),
                          // Padding(
                          //     padding: EdgeInsets.only(
                          //         left: 25.0, right: 25.0, top: 2.0),
                          //     child: new Row(
                          //       mainAxisSize: MainAxisSize.max,
                          //       children: <Widget>[
                          //         new Flexible(
                          //           child: new TextField(
                          //             decoration: const InputDecoration(
                          //                 hintText: "Gada Technology", hintStyle: TextStyle( color: Colors.black,)),
                          //             enabled: !_status,
                          //           ),
                          //         ),
                          //       ],
                          //     )),
                          // Padding(
                          //     padding: EdgeInsets.only(
                          //         left: 25.0, right: 25.0, top: 25.0),
                          //     child: new Row(
                          //       mainAxisSize: MainAxisSize.max,
                          //       mainAxisAlignment: MainAxisAlignment.start,
                          //       children: <Widget>[
                          //         Expanded(
                          //           child: Container(
                          //             child: new Text(
                          //               'Internship Start date',
                          //               style: TextStyle(
                          //                   fontSize: 16.0,
                          //                   fontWeight: FontWeight.bold),
                          //             ),
                          //           ),
                          //           flex: 2,
                          //         ),
                          //         Expanded(
                          //           child: Container(
                          //             child: new Text(
                          //               '',
                          //               style: TextStyle(
                          //                   fontSize: 16.0,
                          //                   fontWeight: FontWeight.bold),
                          //             ),
                          //           ),
                          //           flex: 2,
                          //         ),
                          //       ],
                          //     )),
                          // Padding(
                          //     padding: EdgeInsets.only(
                          //         left: 25.0, right: 25.0, top: 2.0),
                          //     child: new Row(
                          //       mainAxisSize: MainAxisSize.max,
                          //       mainAxisAlignment: MainAxisAlignment.start,
                          //       children: <Widget>[
                          //         Flexible(
                          //           child: Padding(
                          //             padding: EdgeInsets.only(right: 10.0),
                          //             child: new TextField(
                          //               decoration: const InputDecoration(
                          //                   hintText: "16th March 2020",hintStyle: TextStyle( color: Colors.black,)),
                          //               enabled: !_status,
                          //             ),
                          //           ),
                          //           flex: 2,
                          //         ),
                          //         Flexible(
                          //           child: new TextField(
                          //             decoration: const InputDecoration(
                          //                 hintText: ""),
                          //             enabled: !_status,
                          //           ),
                          //           flex: 2,
                          //         ),
                          //       ],
                          //     )),
                          !_status ? _getActionButtons() : new Container(),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ));
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    myFocusNode.dispose();
    super.dispose();
  }

  Widget _getActionButtons() {
    return Padding(
      padding: EdgeInsets.only(left: 25.0, right: 25.0, top: 45.0),
      child: new Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: 10.0),
              child: Container(
                  child: new RaisedButton(
                child: new Text("Save"),
                textColor: Colors.white,
                color: Colors.green,
                onPressed: () {
                  setState(() {
                    _status = true;
                    FocusScope.of(context).requestFocus(new FocusNode());
                  });
                },
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(20.0)),
              )),
            ),
            flex: 2,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 10.0),
              child: Container(
                  child: new RaisedButton(
                child: new Text("Cancel"),
                textColor: Colors.white,
                color: Colors.red,
                onPressed: () {
                  setState(() {
                    _status = true;
                    FocusScope.of(context).requestFocus(new FocusNode());
                  });
                },
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(20.0)),
              )),
            ),
            flex: 2,
          ),
        ],
      ),
    );
  }
}
