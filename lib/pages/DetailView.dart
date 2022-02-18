import 'package:flutter/material.dart';

class DetailView extends StatelessWidget {
  var _baseEntity;

  DetailView(final baseEntity) {
    _baseEntity = baseEntity;
    print("detail View Scafold Building with baseEntity = $_baseEntity");
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(title: new Text('Weekly Journals')),
      body: new Container(
        child: new Column(
          children: <Widget>[
            Padding(padding: new EdgeInsets.all(20.5)),
            new Text("InternShip Name : $_baseEntity",
                style: new TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Colors.lightBlue[600],
                    fontSize: 22.5)),
            new Padding(
              padding: const EdgeInsets.all(12.8),
            ),
            new TextButton(
              onPressed: () {
                print("Trying to connect with Backend!");
              },
              child: Text("Connect with Backend!"),
            )
          ],
        ),
      ),
    );
  }
}
