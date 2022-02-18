// library multi_page_form;

import 'package:flutter/material.dart';

import '../utils/internmatch/UserEventHelper.dart';

class MultiPageForm extends StatefulWidget {
  UserEventHelper eventHelper;
  final VoidCallback onFormSubmitted;
  final VoidCallback triggerAutoValidate;
  final int totalPage;
  final Widget nextButtonStyle;
  final Widget previousButtonStyle;
  final Widget submitButtonStyle;
  final List<Widget> pageList;
  final GlobalKey<FormState> formKey;
  final bool autoVal;

  MultiPageForm({
    @required this.totalPage,
    @required this.pageList,
    @required this.onFormSubmitted,
    this.triggerAutoValidate,
    this.nextButtonStyle,
    this.eventHelper,
    this.previousButtonStyle,
    this.submitButtonStyle,
    this.formKey,
    this.autoVal = false,
  });
  _MultiPageFormState createState() => _MultiPageFormState();
}

class _MultiPageFormState extends State<MultiPageForm> {
  int totalPage;
  int currentPage = 1;
  bool _firstPress = true;
  int val;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    totalPage = widget.totalPage;
  }

  Widget getNextButtonWrapper(Widget child) {
    if (widget.nextButtonStyle != null) {
      return child;
    } else {
      return Text("Next >",
          style: TextStyle(color: Colors.white, fontSize: 15));
    }
  }

  Widget getPreviousButtonWrapper(Widget child) {
    if (widget.previousButtonStyle != null) {
      return child;
    } else {
      return Text("< Back",
          style: TextStyle(color: Colors.white, fontSize: 15));
    }
  }

  Widget getSubmitButtonWrapper(Widget child) {
    if (widget.previousButtonStyle != null) {
      return child;
    } else {
      return Text("Submit",
          style: TextStyle(color: Colors.white, fontSize: 15));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Container(
            height: 50.0,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  currentPage == 1
                      ? Container()
                      : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(200.0),
                          ),),
                          child: getPreviousButtonWrapper(
                              widget.previousButtonStyle),
                          onPressed: () {
                            setState(() {
                              currentPage = currentPage - 1;
                            });
                          },
                        ),
                  currentPage == totalPage
                      ? ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(200.0),
                          ),),
                          child:
                              getSubmitButtonWrapper(widget.submitButtonStyle),
                          onPressed: () {
                            if (_firstPress) {
                              _firstPress = false;
                              if (widget.formKey.currentState.validate()) {
                                setState(() {
                                  widget.onFormSubmitted();
                                });
                              }
                              widget.triggerAutoValidate();
                            }
                          })
                      : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(200.0),
                          ),),
                          child: getNextButtonWrapper(widget.nextButtonStyle),
                          onPressed: () async {
                            //int val = await EntityAttribute.getDateCount("PRI_DATE", widget.date);
                            // if (val == 0) {
                              if (widget.formKey.currentState.validate()) {
                                setState(() {
                                  currentPage = currentPage + 1;
                                });
                              }
                              widget.triggerAutoValidate();
                            //} else {
                            //   showAlertMessage("A journal with this date already exists\nPlease try again with another date. ", context);
                            // }
                          })
                ]),
          ),
        ),
        Expanded(
          child: pageHolder(),
        ),
      ],
    );
  }

  Widget pageHolder() {
    for (int i = 1; i <= totalPage; i++) {
      if (currentPage == i) {
        return widget.pageList[i - 1];
      }
    }
    return Container();
  }
}
