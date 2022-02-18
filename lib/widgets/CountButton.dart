import 'package:flutter/material.dart';

import '../models/BaseEntity.dart';
import '../pages/CustomState.dart';
import '../pages/DashboardScreen.dart';
import '../pages/InternList.dart';
import '../utils/internmatch/UserEventHelper.dart';

class CountButton extends StatefulWidget {
  Color _color;
  String _text;
  String _codeFilterString;
  String _attributeCodeFilter;
  String _valueFilter;
  bool _isIntern;
  var _callback;
  var _setIndex;
  var _tabIndex;

  List<BaseEntity> itemList = [];
  List<BaseEntity> _internList = [];

  CountButton(
      Color color,
      String text,
      String codeFilterString,
      String attributeCodeFilter,
      String valueFilter,
      updateJournalList(),
      setIndex,
      int tabIndex,
      bool isIntern) {
    _color = color;
    _text = text;
    _codeFilterString = codeFilterString;
    _attributeCodeFilter = attributeCodeFilter;
    _valueFilter = valueFilter;
    _callback = updateJournalList;
    _setIndex = setIndex;
    _tabIndex = tabIndex;
    _isIntern = isIntern;
  }
  @override
  _CountButtonState createState() => _CountButtonState();
}

class _CountButtonState extends CustomState<CountButton> {
  UserEventHelper _eventHelper;

  @override
  Future<bool> loadWidget(BuildContext context, isInit) async {
    return BaseEntity.fetchBaseEntitys(widget._codeFilterString,
            widget._attributeCodeFilter, widget._valueFilter)
        .then((items) {
      return getFilteredList(true).then((intern) {
        widget._internList = intern;
        widget.itemList = items;
        if (items.length > 0) {
          for (BaseEntity be in items) {
            String status = be.getValue("PRI_STATUS", "UNKNOWN");
          }
        }
        return true;
      });
    });
  }


  Future<List> getFilteredList(bool valueFilter) async {
    var beList = BaseEntity.fetchBaseEntitysByBoolean(
        "PER_", "PRI_IS_INTERN", valueFilter);
    return beList;
  }

  @override
  Widget customBuild(BuildContext context) {
    var count;

    if (widget.itemList == null) {
      count = 0;
    } else if (widget._isIntern == true) {
      count = widget._internList.length.toString();
    } else if (widget._isIntern == false) {
      count = widget.itemList.length.toString();
    }

    return (Row(children: <Widget>[
      //view journals
      Column(children: <Widget>[
        flatButton(
            widget._color,
            count.toString(),
            widget._callback,
            widget._setIndex,
            widget._tabIndex,
            widget._isIntern,
            _eventHelper,
            context),
        Padding(padding: new EdgeInsets.all(10.0)),
        Text(
          widget._text,
          style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey),
        )
      ])
    ]));
  }
}

Widget flatButton(color, String text, _callback, _setIndex, _tabIndex, isIntern,
    _eventHelper, context) {
  return TextButton(
    style: TextButton.styleFrom(
      shape: new CircleBorder(),
      backgroundColor: color,),
      onPressed: () {
        if (isIntern == true) {
          Navigator.of(context).push(_internRoute(_eventHelper));
        } else {
          _callback();
          tabIndex = _tabIndex;
          _setIndex(1);
        }
      },
      child: Padding(
        padding: EdgeInsets.all(30),
        child: Text(
          "$text".toString(),
          style: TextStyle(color: Colors.white, fontSize: 25),
        ),
      ));
}

Route _internRoute(_eventhelper) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) =>
        InternList(_eventhelper),
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
