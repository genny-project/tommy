import 'package:flutter/material.dart';
import 'package:internmatch/models/BaseEntity.dart';
import 'package:internmatch/pages/CustomState.dart';
import 'package:internmatch/utils/internmatch/BaseEntityUtils.dart';
import 'package:internmatch/utils/internmatch/Sync.dart';
import 'package:internmatch/utils/internmatch/UserEventHelper.dart';
import '../ProjectEnv.dart';
import '../pages/FetchJournals.dart';
import '../pages/ViewJournal.dart';

class ListBuilder extends StatefulWidget {
  UserEventHelper _eventHelper;
  String _valueFilter;
  var _user;
  var _color;

  List _list = [];

  ListBuilder(
      UserEventHelper eventHelper, String valueFilter, var user, Color color) {
    _eventHelper = eventHelper;
    _valueFilter = valueFilter;
    _user = user;
    _color = color;
  }

  @override
  _ListBuilderState createState() => _ListBuilderState();
}

final GlobalKey<RefreshIndicatorState> _refreshkey =
    new GlobalKey<RefreshIndicatorState>();

class _ListBuilderState extends CustomState<ListBuilder> {
  void updateJournalList() async {
    _refreshkey.currentState?.show(atTop: true);
    await Future.delayed(Duration(seconds: 2));
    await fetchBaseEntity(widget._valueFilter);
    await setState(() {});
  }

  @override
  Future<bool> loadWidget(BuildContext context, isInit) async {
    return getFilteredList(widget._valueFilter).then((item) {
      widget._list = item;
      return true;
    });
  }

  Future<List> getFilteredList(String valueFilter) async {
    var beList = fetchBaseEntity(valueFilter);
    return beList;
  }

  @override
  Widget customBuild(BuildContext context) {
    List listItem = [];
    listItem = widget._list;

    print("List Data is ::  [$listItem]".length.toString());

    if (listItem.length >= 0) {
      return RefreshIndicator(
        key: _refreshkey,
        onRefresh: () async {
          Sync.performSync();
        },
        child: (ListView.builder(
          itemCount: listItem.length,
          itemBuilder: (BuildContext context, int index) {
            var date = listItem[index]
                .getValueDate("PRI_JOURNAL_DATE", DateTime.now());
            var name = BaseEntityUtils.getUniqueDateName(date);
            return Ink(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
                child: Card(
                  color: widget._color,
                  child: ListTile(
                      leading: Container(
                        padding: EdgeInsets.only(right: 12.0),
                        decoration: new BoxDecoration(
                            border: new Border(
                                right: new BorderSide(
                                    width: 1.0, color: Colors.white24))),
                        child: Icon(Icons.book, color: Colors.white),
                      ),
                      title: Text(
                        "${listItem[index].name}",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      onTap: (() => Navigator.of(context, rootNavigator: true)
                          .push(_viewJournalRoute(
                              context,
                              widget._eventHelper,
                              index,
                              listItem[index],
                              widget._user,
                              listItem[index].name,
                              updateJournalList)))),
                ),
              ),
            );
          },
        )),
      );
    } else{
      return Center(
        child: (Text(
          "No Journal Entries",
          textAlign: TextAlign.center,
        )),
      );
  }
  }
}

Route _viewJournalRoute(
    context, _eventhelper, index, baseEntityItem, user, name, updateCallback) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => ViewJournal(
        _eventhelper, index, baseEntityItem, user, name, updateCallback),
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
