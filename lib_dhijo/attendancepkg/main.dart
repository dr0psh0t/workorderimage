import 'attendance.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'utils.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/widgets.dart';
import 'logs.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  
}

class AttendanceApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Attendance',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Attendance'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _rotating = false;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  TextEditingController domainController = TextEditingController();
  TextEditingController pathController = TextEditingController();

  SharedPreferences prefs;
  Future<Database> database;

  @override
  void initState() {
    super.initState();

    initUrl();
    openDb();
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      key: _scaffoldKey,
      inAsyncCall: _rotating,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          actions: <Widget>[
            IconButton(icon: Icon(Icons.print), onPressed: () async {
              print(await attendanceList());
            }),
          ],
        ),
        body: Container(
          child: ListView(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.domain),
                title: Text('Domain'),
                subtitle: Text(domainController.text),
                dense: true,
                onTap: () {
                  domainDialog(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.directions),
                title: Text('Path'),
                subtitle: Text(pathController.text),
                dense: true,
                onTap: () {
                  pathDialog(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.verified_user, color: Colors.black54,),
                trailing: Icon(Icons.send, color: Colors.black54,),
                title: Text('Attendance'),
                subtitle: Text('Press for attendance'),
                dense: true,
                onTap: () {

                  showDialog<void>(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        content: Text('Confirm badge in or out'),
                        actions: <Widget>[
                          IconButton(
                            icon: Icon(Icons.check_circle),
                            onPressed: () {
                              Navigator.of(context).pop();

                              if (domainController.text.isNotEmpty && pathController.text.isNotEmpty) {
                                sendAttendance({'emp_badge': '4208589316'}).then((result) {

                                  insertLog(Attendance(
                                    log_text: result,
                                    date_time: DateTime.now().toString(),
                                  ));

                                  showDialog<void>(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        content: Text(result, style: TextStyle(color: Colors.black54),),
                                        actions: <Widget>[
                                          IconButton(
                                            icon: Icon(Icons.close, color: Colors.black54,),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                });

                              } else {
                                Utils.toast('Attendance address is empty');
                              }
                            },
                          ),
                        ],
                      );
                    }
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.list),
                title: Text('Logs'),
                subtitle: Text('Click to view logs'),
                dense: true,
                onTap: () async {
                  List<Attendance> list = await attendanceList();

                  if (list.isNotEmpty) {
                    Navigator.push(context, MaterialPageRoute(
                        builder: (context) => LogsPage(attendanceList: list,)));
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  domainDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Set domain'),
          content: TextField(
            controller: domainController,
            keyboardType: TextInputType.text,
            inputFormatters: [
              WhitelistingTextInputFormatter(RegExp("[^\\s+]")),
            ],
            decoration: InputDecoration(hintText: "Enter domain here"),
          ),
          actions: <Widget>[
            new FlatButton(
              child: new Text('OK'),
              onPressed: () {
                if (domainController.text.isEmpty) {
                  Utils.toast('Domain is required');
                } else {
                  storeDomain(domainController.text);
                  Navigator.of(context).pop();
                }
              },
            )
          ],
        );
      }
    );
  }

  pathDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Set path'),
          content: TextField(
            controller: pathController,
            keyboardType: TextInputType.text,
            inputFormatters: [
              WhitelistingTextInputFormatter(RegExp("[^\\s+]")),
            ],
            decoration: InputDecoration(hintText: "Enter path here"),
          ),
          actions: <Widget>[
            new FlatButton(
              child: new Text('OK'),
              onPressed: () {
                if (pathController.text.isEmpty) {
                  Utils.toast('Path is required');
                } else {
                  storePath(pathController.text);
                  Navigator.of(context).pop();
                }
              },
            )
          ],
        );
      }
    );
  }

  initUrl() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      //this.domainController.text = prefs.getString('domain');
      //this.pathController.text = prefs.getString('path');

      this.domainController.text = '122.3.176.235:1959';
      this.pathController.text = '/attendance/api/Attendance';
    });
  }

  storeDomain(String domain) async {
    await prefs.setString("domain", domain);
    setState(() {
      this.domainController.text = domain;
    });
  }

  storePath(String thisPath) async {
    await prefs.setString("path", thisPath);
    setState(() {
      this.pathController.text = thisPath;
    });
  }

  Future<String> sendAttendance(var params) async {
    setState(() { _rotating = true; });

    try {

      final uri = new Uri.http(domainController.text, pathController.text, params,);
      var response = await http.post(uri, headers: {'Accept':'application/json'})
          .timeout(const Duration(seconds: 30),);

      if (response == null) {
        return '{"success": false, "reason": "The server took long to respond."}';
      } else if (response.statusCode == 200) {
        return response.body;
      } else {
        return '{"success": false, "reason": "Cannot resolve response."}';
      }

    } on SocketException {
      return '{"success": false, "reason": "Failed to connect to the server."}';
    } on TimeoutException {
      return '{"success": false, "reason": "The server took long to respond."}';
    } catch (e) {
      return '{"success": false, "reason": "Cannot login at this time."}';
    } finally {
      setState(() { _rotating = false; });
    }
  }

  void openDb() async {
    database = openDatabase(
      join(await getDatabasesPath(), 'logs_database.db'),
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE logs_table(log_id INTEGER PRIMARY KEY AUTOINCREMENT, log_text TEXT, date_time TEXT)",
        );
      },
      version: 1,
    );
  }

  Future<void> insertLog(Attendance attendance) async {
    final Database db = await database;

    await db.insert(
      'logs_table',
      attendance.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    Utils.toast('Attendance saved');
  }

  Future<List<Attendance>> attendanceList() async {
    final Database db = await database;

    final List<Map<String, dynamic>> maps = await db.query('logs_table');

    return List.generate(maps.length, (i) {
      return Attendance(
        log_text: maps[i]['log_text'],
        date_time: maps[i]['date_time'],
      );
    });
  }
}