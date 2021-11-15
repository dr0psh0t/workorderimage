import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'attendance.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'utils.dart';

class LogsPage extends StatefulWidget {
  LogsPage({Key key, this.attendanceList}) : super(key: key);

  List<Attendance> attendanceList;

  @override
  _LogsPageState createState() => _LogsPageState();
}

class _LogsPageState extends State<LogsPage> {
  Future<Database> database;

  List<Attendance> list;

  @override
  void initState() {
    super.initState();

    openDb();
    list = widget.attendanceList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('logs'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.delete_forever),
            onPressed: () {
              if (list.isNotEmpty) {
                deleteAll();
              }
            },
          )
        ],
      ),
      body: ListView.builder(
        itemCount: list.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Text(list[index].date_time),
            subtitle: Text(list[index].log_text),
            dense: true,
          );
        },
      ),
    );
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

  Future<void> deleteAll() async {
    // Get a reference to the database.
    final db = await database;

    await db.delete('logs_table', where: "1",);

    setState(() {
      list.clear();
    });

    Utils.toast('Logs deleted.');
  }
}