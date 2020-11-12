import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/BaseEntity.dart';
import '../utils/internmatch/Sync.dart';
import '../utils/internmatch/UserEventHelper.dart';
import '../widgets/AlertMessage.dart';
import 'package:intl/intl.dart';
import '../ProjectEnv.dart';
import '../utils/internmatch/BaseEntityUtils.dart';
import '../pages/Dashboard.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import '../packages/MultiPageForm.dart';

//This file contains the functions for adding a journal and submitting a journal to the DB

class AddJournal extends StatefulWidget {
  UserEventHelper _eventHelper;
  bool _enabled;
  int _data;
  var _callback;

  AddJournal(
      UserEventHelper eventHelper, bool enabled, void updateJournalList()) {
    _eventHelper = eventHelper;
    _enabled = enabled;
    _callback = updateJournalList;
  }

  _AddJournalState createState() => _AddJournalState();
}

TextEditingController _hourcontroller;
TextEditingController _taskcontroller;
TextEditingController _learningOutcomecontroller;

final _formKey = GlobalKey<FormState>();

class _AddJournalState extends State<AddJournal> {
  DateTime date;
  BaseEntity baseEntity;
  double hour = 8.0;
  String task;
  String status;
  String feedback;
  DateFormat dateFormat;
  String learningOutcome;
  bool _autoValidate = false;
  var now = new DateTime.now();

  FocusNode hourFocus;
  FocusNode taskFocus;
  FocusNode learningOutcomeFocus;

  @override
  void initState() {
    print('iniside initState');
    super.initState();
    date = DateTime.now();
    setValues(date);
    dateFormat = new DateFormat().addPattern("EEEE, MMMM d y");

    hourFocus = FocusNode();
    taskFocus = FocusNode();
    learningOutcomeFocus = FocusNode();
  }

  @override
  void dispose() {
    // Clean up the focus node when the Form is disposed.
    hourFocus.dispose();
    taskFocus.dispose();
    learningOutcomeFocus.dispose();
    super.dispose();
  }

  void setValues(DateTime date) async {
    this.date = date;
    String journalCode = BaseEntityUtils.getUniqueDatecode("JNL", date);
    BaseEntityUtils.getUniqueDateName(date).then((name) async {
    this.baseEntity = await BaseEntityUtils.createBaseEntity(journalCode, name);
       // this.baseEntity = baseEntity;
        this.hour = baseEntity.getValueDouble("PRI_JOURNAL_HOURS", this.hour);
        this.task = baseEntity.getValue("PRI_JOURNAL_TASKS", "");
        this.learningOutcome =
            baseEntity.getValue("PRI_JOURNAL_LEARNING_OUTCOMES", "");
        this.status = baseEntity.getValue("PRI_STATUS", "UNAPPROVED");
        this.feedback = baseEntity.getValue("PRI_FEEDBACK", "");
      });
    
  }

  void setstates(DateTime date) {
    print('calling changeDate');
    setState(() {
      setValues(date);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: new AppBar(
        leading: IconButton(
            icon: Icon(Icons.cancel), onPressed: () => Navigator.pop(context)),
        centerTitle: true,
        title: Text(ProjectEnv.projectName),
        backgroundColor: Color(ProjectEnv.projectColor),
      ),
      body: Form(
        key: _formKey,
        autovalidate: _autoValidate,
        child: MultiPageForm(
          totalPage: 4,
          pageList: <Widget>[dateField(), taskField(), loField(), summary()],
          onFormSubmitted: () async {
            await this._submitButton(context);
          },
          formKey: _formKey,
          triggerAutoValidate: () {
            setState(() => this._autoValidate = true);
          },
        ),
      ),
    );
  }

  Future<void> _submitButton(BuildContext context) async {
    final scaffold = Scaffold.of(context);
    scaffold.showSnackBar(
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

    this.baseEntity.addDate("PRI_JOURNAL_DATE", this.date);
    this.baseEntity.addString(
        "PRI_JOURNAL_LEARNING_OUTCOMES", this.learningOutcome.toString());
    this.baseEntity.addString("PRI_JOURNAL_TASKS", this.task.toString());
    this.baseEntity.addDouble("PRI_JOURNAL_HOURS", this.hour);
    this.baseEntity.addString("PRI_STATUS", this.status.toString());
    this.baseEntity.addString("PRI_FEEDBACK", this.feedback.toString());
    this.baseEntity.addString("PRI_SYNC", "FALSE");
    this.baseEntity.addString("PRI_NAME", baseEntity.name);
    print("Persisting the new journal data");
    await this.baseEntity.persist("Add Journal");
    Sync.performSync();
    
    scaffold.hideCurrentSnackBar();
    scaffold
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

  Widget dateField() {
    _hourcontroller = TextEditingController(text: this.hour.toString());
    final hourField = TextFormField(
        validator: (value) {
          if (value.isEmpty) {
            return 'Please enter some text';
          } else
            return null;
        },
        controller: _hourcontroller,
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        enabled: widget._enabled,
        focusNode: hourFocus,
        onChanged: (String newhour) {
          this.hour = double.parse(_hourcontroller.text);
        },
        inputFormatters: [WhitelistingTextInputFormatter(RegExp("[0-9.]"))],
        maxLines: 1,
        decoration: InputDecoration(
            suffixIcon: IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  FocusScope.of(context).requestFocus(hourFocus);
                }),
            border: new OutlineInputBorder(
              borderRadius: new BorderRadius.circular(25.0),
              borderSide: new BorderSide(
                color: Color(ProjectEnv.projectColor),
                width: 50.0,
              ),
            ),
            contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 15.0),
            hintText: "Hours Worked",
            hintStyle: TextStyle(
              fontSize: 15.0,
              color: Color(ProjectEnv.projectColor),
              fontWeight: FontWeight.bold,
            ),
            prefixIcon: new Icon(
              Icons.access_time,
              color: Color(ProjectEnv.projectColor),
            )));

    return Container(
        padding: const EdgeInsets.all(10.0),
        child: Container(
            margin: EdgeInsets.only(top: 10.0),
            child: ListView(children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 0.0),
                child: RaisedButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(200.0),
                  ),
                  onPressed: () {
                    if (widget._enabled == true) {
                      DatePicker.showDatePicker(context,
                          theme: DatePickerTheme(
                            containerHeight: 210.0,
                          ),
                          showTitleActions: true,
                          minTime:
                              DateTime(date.year - 1, date.month, date.day),
                          maxTime: now, onConfirm: (returnedDatePickerDate) {
                        print('confirm $returnedDatePickerDate');
                        setstates(returnedDatePickerDate);
                      }, locale: LocaleType.en);
                    }
                  },
                  child: Container(
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
                                    " " + BaseEntityUtils.getDateString(this.date),
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
                          "Change Date",
                          style: TextStyle(
                              color: Color(ProjectEnv.projectColor),
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  color: Colors.white,
                ),
              ),
              SizedBox(),
              SizedBox(height: 20.0),
              Padding(
                padding: const EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 12.0),
                child: Text("Hours  Worked",
                    style: TextStyle(
                        color: Color(ProjectEnv.projectColor),
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold)),
              ),
              hourField,
            ])));
  }

  Widget taskField() {
    String message =
        "In order to submit a satisfactory logbook, you are required to provide a detailed account of things you completed through out your day and all of the things you learnt"
        "\n\nThis may include meetings you attended, tasks you completed and professional conversations and interactions you had throughout the day. \n \nHere is an example of an acceptable daily logbook entry: \n\n\n1. Morning meeting discussing clients and open projects."
        "\n\n2. I spent 2 hours generating accounts receivable invoices for the month of December for 39 accounts."
        "\n\n3. After lunch, I was making advanced payments for August and September sundry expenses."
        "\n\n4. Performed bank reconciliation within Xero for the month of June."
        "\n\n5. I learnt how to call debtors from the month of May to remind them of overdue accounts and update Xero accordingly."
        "\n\n6. Provided a report on this at the end of the day to my supervisor.";

    _taskcontroller = TextEditingController(text: this.task);
    final taskfield = TextFormField(
      textCapitalization: TextCapitalization.sentences,
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
        controller: _taskcontroller,
        enabled: widget._enabled,
        maxLines: 10,
        decoration: InputDecoration(
          suffixIcon: IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () => showAlertMessage(message, context),
          ),
          border: new OutlineInputBorder(
            borderRadius: new BorderRadius.circular(25.0),
            borderSide: new BorderSide(
              color: Color(ProjectEnv.projectColor),
              width: 50.0,
            ),
          ),
          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 15.0),
          hintText: "What did you do today?",
          hintStyle: TextStyle(
            fontSize: 15.0,
            color: Color(ProjectEnv.projectColor),
            fontWeight: FontWeight.bold,
          ),
          prefixIcon: new Icon(
            Icons.work,
            color: Color(ProjectEnv.projectColor),
          ),
        ));
    return Container(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
        child: ListView(
          children: [
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
          ],
        ),
      ),
    );
  }

  Widget loField() {
    String message =
        "In order to submit a satisfactory logbook, you are required to provide a detailed account of things you have learnt"
        "\n\nThis may include presentation skills along with professional conversations and interactions you had throughout the day. \n \nHere is an example of an acceptable daily logbook entry: \n\n"
        "\n\n1. Learnt how to generate accounts recievable"
        "\n\n2. Learnt to make advance payments."
        "\n\n3. Bank reconciliation within Xero for the month of June."
        "\n\n4. I learnt how to call debtors from the month of May to remind them of overdue accounts and update Xero accordingly.";

    _learningOutcomecontroller =
        TextEditingController(text: this.learningOutcome);
    final learningoutcomeField = TextFormField(
        controller: _learningOutcomecontroller,
        textCapitalization: TextCapitalization.sentences,
        enabled: widget._enabled,
        maxLines: 10,
        validator: (value) {
          if (value.isEmpty) {
            return 'Please enter some text';
          } else if (value.length < 100) {
            return 'Please enter at least 100 characters';
          }
          return null;
        },
        onChanged: (String newlo) {
          this.learningOutcome = _learningOutcomecontroller.text;
        },
        decoration: InputDecoration(
            suffixIcon: IconButton(
              icon: Icon(Icons.info_outline),
              onPressed: () => showAlertMessage(message, context),
            ),
            border: new OutlineInputBorder(
              borderRadius: new BorderRadius.circular(25.0),
              borderSide: new BorderSide(
                color: Color(ProjectEnv.projectColor),
                width: 50.0,
              ),
            ),
            contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 15.0),
            hintText: "What did you learn today?",
            alignLabelWithHint: false,
            hintStyle: TextStyle(
                fontSize: 15.0,
                color: Color(ProjectEnv.projectColor),
                fontWeight: FontWeight.bold),
            prefixIcon: new Icon(
              Icons.school,
              color: Color(ProjectEnv.projectColor),
            )));

    return Container(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
        child: ListView(
          children: [
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
          ],
        ),
      ),
    );
  }

  Widget summary() {
    return Container(
        child: Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
            child: ListView(children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 5.0),
                child: Text("Date",
                    style: TextStyle(
                        color: Color(ProjectEnv.projectColor),
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold)),
              ),
              Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    readOnly: true,
                    decoration: InputDecoration(
                      suffixIcon: IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          DatePicker.showDatePicker(context,
                              theme: DatePickerTheme(
                                containerHeight: 210.0,
                              ),
                              showTitleActions: true,
                              minTime: DateTime(2000, 1, 1),
                              maxTime: now, onConfirm: (date) {
                            print('confirm $date');
                            setstates(date);
                          }, locale: LocaleType.en);
                        },
                      ),
                      hintText: dateFormat.format(this.date),
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
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  focusNode: hourFocus,
                  controller: _hourcontroller,
                  onChanged: (task) {
                    this.hour = double.parse(_hourcontroller.text);
                  },
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
                  textCapitalization: TextCapitalization.sentences,
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
                  maxLines: 4,
                  focusNode: taskFocus,
                  controller: _taskcontroller,
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
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  textCapitalization: TextCapitalization.sentences,
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter some text';
                    } else if (value.length < 100) {
                      return 'Please enter at least 100 characters';
                    }
                    return null;
                  },
                  onChanged: (task) {
                    this.learningOutcome = _learningOutcomecontroller.text;
                  },
                  maxLines: 4,
                  focusNode: learningOutcomeFocus,
                  controller: _learningOutcomecontroller,
                  decoration: InputDecoration(
                      suffixIcon: IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () => FocusScope.of(context)
                        .requestFocus(learningOutcomeFocus),
                  )),
                ),
              ),
            ])));
  }
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
      var curve = Curves.ease;
      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      var offsetAnimation = animation.drive(tween);
      return SlideTransition(
        position: offsetAnimation,
        child: child,
      );
    },
  );
}
