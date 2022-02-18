import 'package:flutter/material.dart';

import '../models/BaseEntity.dart';
import '../pages/CustomState.dart';
import '../utils/internmatch/UserEventHelper.dart';

class InternListBuilder extends StatefulWidget {
  UserEventHelper _eventHelper;
  bool _valueFilter;
  var _name;

  List _list = [];

  InternListBuilder(UserEventHelper eventHelper, bool valueFilter, var name) {
    _eventHelper = eventHelper;
    _valueFilter = valueFilter;
    _name = name;
  }

  @override
  _InternListBuilderState createState() => _InternListBuilderState();
}

class _InternListBuilderState extends CustomState<InternListBuilder> {
  List listItem = [];
  @override
  Future<bool> loadWidget(BuildContext context, isInit) async {
    return getFilteredList(widget._valueFilter).then((item) {
      widget._list = item;
      return true;
    });
  }

  Future<List> getFilteredList(bool valueFilter) async {
    var beList = BaseEntity.fetchBaseEntitysByBoolean(
        "PER_", "PRI_IS_INTERN", valueFilter);
    return beList;
  }

  @override
  Widget customBuild(BuildContext context) {
    listItem = widget._list;

    if (listItem.length != 0) {
      return (ListView.builder(
        itemCount: listItem.length,
        itemBuilder: (BuildContext context, int index) {
          return Ink(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
              child: Card(
                color: Colors.green,
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
                      listItem[index].name,
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    onTap: () => {
                      }),
              ),
            ),
          );
        },
      ));
    } else {
      return Center(
        child: (Text(
          "No Interns availaible",
          textAlign: TextAlign.center,
        )),
      );
    }
  }
}
