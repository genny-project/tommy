import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/BaseEntity.dart';
import '../utils/internmatch/BaseEntityUtils.dart';
import '../utils/internmatch/Sync.dart';
import '../utils/internmatch/UserEventHelper.dart';
import '../widgets/AlertMessage.dart';
import '../ProjectEnv.dart';
import '../pages/Dashboard.dart';

class ViewJournal extends StatefulWidget {
  UserEventHelper _eventHelper;
  int _index;
  bool _enabled;
  BaseEntity _baseEntityItem;
  var _user;
  String _title;
  var _callback;

  ViewJournal(UserEventHelper eventHelper, int index, BaseEntity baseEntityItem,
      var user, String name, void getFilteredList()) {
    _eventHelper = eventHelper;
    _index = index;
    _baseEntityItem = baseEntityItem;
    _user = user;
    _title = name;
    _callback = getFilteredList;
  }

  @override
  _ViewJournalState createState() => _ViewJournalState();
}

bool _sub;

TextEditingController _hourcontroller;
TextEditingController _taskcontroller;
TextEditingController _learningOutcomeController;
TextEditingController _feedbackController;

FocusNode hourFocus;
FocusNode taskFocus;
FocusNode learningOutcomeFocus;
FocusNode feedbackFocus;
final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

class _ViewJournalState extends State<ViewJournal> {
  DateTime date;
  double hour;
  String task;
  String learningOutcome;
  String status;
  String feedback;
  bool sub;
  bool _autoValidate = false;

  void triggerAutoValidate() {
    setState(() => this._autoValidate = true);
  }

  @override
  void initState() {
    super.initState();
    setValues(date);
  }

  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final bool showFab = MediaQuery.of(context).viewInsets.bottom==0.0;
    return new Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: showFab?button(context, widget, triggerAutoValidate):null,
      resizeToAvoidBottomInset: true,
      key: _scaffoldKey,
      appBar: new AppBar(
        centerTitle: true,
        title: Text(ProjectEnv.projectName),
        //title:Text("${widget._title}".toString()),
        backgroundColor: Color(ProjectEnv.projectColor),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: <Widget>[
        (status == "UNAPPROVED"|| status == "REJECTED" && widget._user.hasRole("INTERN"))
              ? Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: RaisedButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(25.0),
                      ),
                      color: Colors.green,
                      child: Text("Update",
                          style: TextStyle(color: Colors.white, fontSize: 15)),
                      onPressed: () async {
                        if (_formKey.currentState.validate()) {
                          _updateButton(
                              widget,
                              context,
                              this.date,
                              this.learningOutcome,
                              this.task,
                              this.hour,
                              this.status,
                              this.feedback);
                          FocusScope.of(context).unfocus();
                        } else {
                          setState(() => this._autoValidate = true);
                        }
                      }),
                )
              : Container(width: 0)
        ],
      ),
      body: viewJournal(widget, context, date, hour, task, learningOutcome),
    );
  }

  void setValues(DateTime date) async {
    this.date =
        widget._baseEntityItem.getValueDate("PRI_JOURNAL_DATE", DateTime.now());
    this.hour = widget._baseEntityItem.getValueDouble("PRI_JOURNAL_HOURS", 0.0);
    this.task = widget._baseEntityItem.getValue("PRI_JOURNAL_TASKS", "");
    this.learningOutcome =
        widget._baseEntityItem.getValue("PRI_JOURNAL_LEARNING_OUTCOMES", "");
    this.status = widget._baseEntityItem.getValue("PRI_STATUS", "UNAPPROVED");
    this.feedback = widget._baseEntityItem.getValue("PRI_FEEDBACK", "");
  }

  Widget viewJournal(widget, context, myDate, hour, task, lo) {
    void setstates(DateTime date) {
      print('calling changeDate');
      setState(() {
        setValues(date);
      });
    }

    String journalStatus = status;
    if (journalStatus == "APPROVED" || widget._user.hasRole("SUPERVISOR")) {
      print("inside if");
      _hourcontroller = TextEditingController(text: this.hour.toString());
      _taskcontroller = TextEditingController(text: this.task);
      _learningOutcomeController =
          TextEditingController(text: this.learningOutcome);
      _feedbackController = TextEditingController(text: this.feedback);

      final hourField = TextFormField(
          controller: _hourcontroller,
          readOnly: true,
          inputFormatters: [WhitelistingTextInputFormatter(RegExp("[0-9.]"))],
          maxLines: 1,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 15.0),
            hintText: "${this.hour.toString()}",
            hintStyle: TextStyle(
              fontSize: 15.0,
              color: Color(ProjectEnv.projectColor),
              fontWeight: FontWeight.bold,
            ),
          ));

      final taskfield = TextFormField(
        controller: _taskcontroller,
        readOnly: true,
        maxLines: 5,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 1.0),
          hintText: "${this.task.toString()}",
          hintStyle: TextStyle(
            fontSize: 15.0,
            color: Color(ProjectEnv.projectColor),
            fontWeight: FontWeight.bold,
          ),
        ),
      );

      final learningoutcomeField = TextFormField(
          controller: _learningOutcomeController,
          readOnly: true,
          maxLines: 5,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 15.0),
            hintText: "${this.learningOutcome.toString()}",
            alignLabelWithHint: false,
            hintStyle: TextStyle(
                fontSize: 15.0,
                color: Color(ProjectEnv.projectColor),
                fontWeight: FontWeight.bold),
          ));

      final feedbackTextField = TextFormField(
          controller: _feedbackController,
          readOnly: true,
          maxLines: 2,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 15.0),
            hintText: "${this.feedback.toString()}",
            alignLabelWithHint: false,
            hintStyle: TextStyle(
                fontSize: 15.0,
                color: Color(ProjectEnv.projectColor),
                fontWeight: FontWeight.bold),
          ));

      return new Container(
        child: Container(
          child: ListView(
            children: <Widget>[
              Center(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 10.0),
                  child: Text("${widget._title}".toString(),
                      style: TextStyle(
                          color: Color(ProjectEnv.projectColor),
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 12.0),
                child: Text("Date",
                    style: TextStyle(
                        color: Color(ProjectEnv.projectColor),
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold)),
              ),
              FlatButton(
                onPressed: () {},
                child: dateWidget(widget, this.date),
                color: Colors.white,
              ),
              SizedBox(),
              SizedBox(height: 20.0),
              Padding(
                padding: const EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 12.0),
                child: Text("Hours Worked",
                    style: TextStyle(
                        color: Color(ProjectEnv.projectColor),
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold)),
              ),
              hourField,
              SizedBox(
                height: 20.0,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 12.0),
                child: Text("Roles and Responsibilities",
                    style: TextStyle(
                        color: Color(ProjectEnv.projectColor),
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold)),
              ),
              taskfield,
              SizedBox(
                height: 20.0,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 12.0),
                child: Text("Learning Outcomes",
                    style: TextStyle(
                        color: Color(ProjectEnv.projectColor),
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold)),
              ),
              learningoutcomeField,
              SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 12.0),
                child: Text("Feedback",
                    style: TextStyle(
                        color: Color(ProjectEnv.projectColor),
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold)),
              ),
              feedbackTextField,
              SizedBox(
                height: 20,
              )
            ],
          ),
        ),
      );
    }
    if (widget._user.hasRole("INTERN")) {
      _hourcontroller = TextEditingController(text: this.hour.toString());
      _taskcontroller = TextEditingController(text: this.task);
      _learningOutcomeController =
          TextEditingController(text: this.learningOutcome);
      _feedbackController = TextEditingController(text: this.feedback);

      return Form(
        key: _formKey,
        autovalidate: _autoValidate,
        child: new Container(
            padding: const EdgeInsets.all(10.0),
            child: Container(
                margin: EdgeInsets.only(top: 10.0),
                child: ListView(children: <Widget>[
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 12.0),
                      child: Text("${widget._title}".toString(),
                          style: TextStyle(
                              color: Color(ProjectEnv.projectColor),
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0.0, 10.0, 10.0, 5.0),
                    child: Text(
                      "Date",
                      style: TextStyle(
                          color: Color(ProjectEnv.projectColor),
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        readOnly: true,
                        decoration: InputDecoration(
                          // suffixIcon: IconButton(
                          //   icon: Icon(Icons.edit),
                          // onPressed: () {
                          //   dateWidget(widget, this.date);
                          // },
                          // ),
                          hintText: BaseEntityUtils.getDateString(date),
                          hintStyle: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      )),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 5.0),
                    child: Text("Hours Worked",
                        style: TextStyle(
                            color: Color(ProjectEnv.projectColor),
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      readOnly: false,
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      focusNode: hourFocus,
                      controller: _hourcontroller,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter some text';
                        }
                        return null;
                      },
                      onChanged: (String newhour) {
                        this.hour = double.parse(_hourcontroller.text);
                      },
                      inputFormatters: [
                        WhitelistingTextInputFormatter(RegExp("[0-9.]"))
                      ],
                      decoration: InputDecoration(
                          suffixIcon: IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () =>
                            FocusScope.of(context).requestFocus(hourFocus),
                      )),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 5.0),
                    child: Text("Roles and Responsibilities",
                        style: TextStyle(
                            color: Color(ProjectEnv.projectColor),
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      maxLines: 4,
                      focusNode: taskFocus,
                      controller: _taskcontroller,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter some text';
                        } else if (value.length < 100) {
                          return 'Please enter at least 100 characters';
                        }
                        return null;
                      },
                      onChanged: (task) {
                        this.task = _taskcontroller.text;
                      },
                      autocorrect: true,
                      enableSuggestions: true,
                      decoration: InputDecoration(
                          suffixIcon: IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () =>
                            FocusScope.of(context).requestFocus(taskFocus),
                      )),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 5.0),
                    child: Text("Learning Outcomes",
                        style: TextStyle(
                            color: Color(ProjectEnv.projectColor),
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold)),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
                    child: TextFormField(
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter some text';
                        } else if (value.length < 100) {
                          return 'Please enter at least 100 characters';
                        }
                        return null;
                      },
                      onChanged: (String newlo) {
                        this.learningOutcome = _learningOutcomeController.text;
                      },
                      maxLines: 4,
                      focusNode: learningOutcomeFocus,
                      controller: _learningOutcomeController,
                      decoration: InputDecoration(
                          suffixIcon: IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => FocusScope.of(context)
                            .requestFocus(learningOutcomeFocus),
                      )),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 5.0),
                    child: Text("Feedback",
                        style: TextStyle(
                            color: Color(ProjectEnv.projectColor),
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold)),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 5.0),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
                    child: TextFormField(
                      controller: _feedbackController,
                      maxLines: 1,
                      readOnly: true,
                    ),
                  ),
                ]))),
      );
    }
  }
}

Future<void> _updateButton(
  widget,
  context,
  date,
  learningOutcome,
  task,
  hour,
  status,
  feedback,
) async {
  widget._baseEntityItem
      .addString("PRI_JOURNAL_LEARNING_OUTCOMES", learningOutcome.toString());
  widget._baseEntityItem.addString("PRI_JOURNAL_TASKS", task.toString());
  widget._baseEntityItem.addDouble("PRI_JOURNAL_HOURS", hour);
  widget._baseEntityItem.addString("PRI_STATUS", "UNAPPROVED");
  widget._baseEntityItem.addString("PRI_FEEDBACK", feedback.toString());
  widget._baseEntityItem.addString("PRI_SYNC", "FALSE");
  print("Persisting the new journal data");
  await widget._baseEntityItem.persist("View Journal");
  Sync.performSync();
  //final scaffold = Scaffold.of(context);
  _scaffoldKey.currentState.showSnackBar(
    SnackBar(
      content: Container(
        height: 30,
        child: Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              height: 30,
              width: 30,
              child: CircularProgressIndicator(),
            )),
      ),
      duration: Duration(seconds: 5),
    ),
  );

  _scaffoldKey.currentState..hideCurrentSnackBar();
  _scaffoldKey.currentState
      .showSnackBar(SnackBar(
        content: Text("Well done on completing your internship logbook!"),
        duration: Duration(seconds: 2),
      ))
      .closed
      .whenComplete(() async {
    await widget._callback();
    Navigator.of(context).pop();
  });
}

Widget dateWidget(widget, _date) {
  String date;
  String change;
  if (widget._enabled == true) {
    date = _date;
    change = 'Change Date';
  } else {
    date = BaseEntityUtils.getDateString(_date);
    change = '';
  }
  return (Container(
    alignment: Alignment.center,
    height: 50.0,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Row(
          children: <Widget>[
            Container(
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.date_range,
                    size: 18.0,
                    color: Color(ProjectEnv.projectColor),
                  ),
                  Text(
                    "$date",
                    style: TextStyle(
                        color: Color(ProjectEnv.projectColor),
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            )
          ],
        ),
        Text(
          change,
          style: TextStyle(
              color: Color(ProjectEnv.projectColor),
              fontSize: 18.0,
              fontWeight: FontWeight.bold),
        ),
      ],
    ),
  ));
}

Route _dashboardRoute(_eventhelper) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) =>
        Dashboard(_eventhelper),
    transitionsBuilder: (
      context,
      animation,
      secondaryAnimation,
      child,
    ) {
      var begin = Offset(1.0, 0.0);
      var end = Offset.zero;
      var curve = Curves.easeOutSine;
      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      var offsetAnimation = animation.drive(tween);
      return SlideTransition(
        position: offsetAnimation,
        child: child,
      );
    },
  );
}

Widget button(context, widget, triggerAutoValidate) {
  String message = "Please provide feedback for the interns.";
  if (widget._user.hasRole("SUPERVISOR")) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 50),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Tooltip(
              message: "Reject",
              child: RaisedButton(
                  shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(200.0),
                  ),
                  color: Colors.redAccent,
                  child: Text("Reject",
                      style: TextStyle(color: Colors.white, fontSize: 15)),
                  onPressed: () async {
                    showAlertMessage(message, context);
                    _scaffoldKey.currentState.showBottomSheet(
                        (feedbackContext) => feedbackField("REJECTED", context,
                            widget, feedbackContext, triggerAutoValidate),
                        elevation: 50.0);
                  }),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Tooltip(
              message: "Approve",
              child: RaisedButton(
                  shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(200.0),
                  ),
                  color: Colors.green,
                  child: Padding(
                      padding: EdgeInsets.all(0),
                      child: Text("Approve",
                          style: TextStyle(color: Colors.white, fontSize: 15))),
                  onPressed: () async {
                    showAlertMessage(message, _scaffoldKey.currentContext);
                    _scaffoldKey.currentState.showBottomSheet(
                        (feedbackContext) => Padding(
                          padding: const EdgeInsets.only(bottom:  0.0 ),
                          child: feedbackField("APPROVED", context,
                              widget, feedbackContext, triggerAutoValidate),
                        ),
                        elevation: 10.0);
                  }),
            ),
          )
        ],
      ),
    );
  } else {
    return null;
  }
}

Widget feedbackField(
    status, context, widget, feedbackContext, triggerAutoValidate) {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  String feedback;
  Color feedbackColor =
      status == "APPROVED" ? Colors.green[100] : Colors.red[300];
  return Form(
    key: _formKey,
    child: (Container(
        height: 200,
        color: feedbackColor,
        child: Container(
          padding: EdgeInsets.all(10),
          child: Column(children: <Widget>[
            status == "REJECTED"
                ? TextFormField(
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter some text';
                      }
                      return null;
                    },
                    onChanged: (val) {
                      feedback = val;
                      print(feedback);
                    },
                    maxLines: 4,
                    decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Color(ProjectEnv.projectColor),
                              width: 2.0),
                        ),
                        contentPadding:
                            EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                        hintText: "Feedback",
                        hintStyle: TextStyle(
                            fontSize: 15.0,
                            color: Color(ProjectEnv.projectColor),
                            fontWeight: FontWeight.bold),
                        prefixIcon: new Icon(
                          Icons.message,
                          color: Color(ProjectEnv.projectColor),
                        )))
                : TextFormField(
                    onChanged: (val) {
                      feedback = val;
                      print(feedback);
                    },
                    maxLines: 4,
                    decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Color(ProjectEnv.projectColor),
                              width: 2.0),
                        ),
                        contentPadding:
                            EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                        hintText: "Feedback",
                        hintStyle: TextStyle(
                            fontSize: 15.0,
                            color: Color(ProjectEnv.projectColor),
                            fontWeight: FontWeight.bold),
                        prefixIcon: new Icon(
                          Icons.message,
                          color: Color(ProjectEnv.projectColor),
                        ))),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  FlatButton(
                    child: Text("Cancel"),
                    onPressed: () {
                      Navigator.of(feedbackContext).pop();
                    },
                  ),
                  FlatButton(
                    child: Text("Submit"),
                    onPressed: () async {
                      if (_formKey.currentState.validate()) {
                        widget._baseEntityItem
                            .addString("PRI_FEEDBACK", feedback.toString());
                        widget._baseEntityItem.addString("PRI_SYNC", "FALSE");
                        widget._baseEntityItem.addString("PRI_STATUS", status);
                        await widget._baseEntityItem
                            .persist("Supervisor Feedback");
                        Sync.performSync();
                        await widget._callback();
                        Navigator.of(feedbackContext).pop();
                        Navigator.of(context).pop();
                      } else {
                        triggerAutoValidate();
                      }
                    },
                  )
                ])
          ]),
        ))),
  );
}