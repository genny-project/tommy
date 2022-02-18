import 'package:flutter/material.dart';
import '../../ProjectEnv.dart';
import '../../utils/internmatch/DatabaseHelper.dart';


class SqlConsole extends StatefulWidget {
  SqlConsole();

  @override
  _SqlConsoleState createState() => _SqlConsoleState();
}

class _SqlConsoleState extends State<SqlConsole> {
  final myController = TextEditingController();
  List data = [];
  @override
  void initState() {
    super.initState();
    super.setState(() {});
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          appBar: new AppBar(
            centerTitle: true,
            title: Text("Profile"),
            backgroundColor: Color(ProjectEnv.projectColor),
            leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context)),
          ),
          body: new Container(
            child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  children: <Widget>[
                    new Expanded(
                        child: new ListView.builder(
                            itemCount: data.length,
                            itemBuilder: (BuildContext ctxt, int Index) {
                              return new Text(data[Index].toString());
                            })),
                    TextField(
                      controller: myController,
                      //smartQuotesType: SmartQuotesType.disabled,
                    ),
                    TextButton(
                      child: Text("Submit"),
                      onPressed: () async {
                        myController.text = myController.text.replaceAll(" be ", " 'baseentity' ");
                        myController.text = myController.text.replaceAll(" bc ", " 'baseentityCode' ");
                        myController.text = myController.text.replaceAll(" ea ", " 'baseentity_attribute' ");
                        myController.text = myController.text.replaceAll(" ac ", " attributeCode ");
                        myController.text = myController.text.replaceAll(" vs ", "  valueString ");
                        myController.text = myController.text.replaceAll(" d ", "  valueDouble ");
                        myController.text = myController.text.replaceAll(" w ", " WHERE ");
                        myController.text = myController.text.replaceAll(" s ", " SELECT ");
                        myController.text = myController.text.replaceAll(" f ", " FROM ");
                        myController.text = myController.text.replaceAll("‘", "'");
                        print("SQL:"+myController.text);
                        var dbData  = await DatabaseHelper.internal()
                            .debugFunction(myController.text);
                        setState(() {
                          data = dbData;
                        });
                      },
                    ),
                    TextButton(
                      child: Text("Clear"),
                      onPressed: () async {
                      
                        myController.text = "";
                      },
                    )
                  ],
                )),
          ),
        ));
  }
}
