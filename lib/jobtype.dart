import 'package:flutter/material.dart';
import 'workorder.dart';
import 'slide_right_route.dart';
import 'workorders.dart';
import 'mainpage.dart';

class JobtypePage extends StatefulWidget {
  List<Workorder> workordersEr = new List();
  List<Workorder> workordersMf = new List();
  List<Workorder> workordersCalib = new List();
  List<Workorder> workordersGm = new List();
  int joId;

  JobtypePage(List<Workorder> woEr, List<Workorder> woMf,
      List<Workorder> woCalib, List<Workorder> woGm, int joId) {
    workordersEr = woEr;
    workordersMf = woMf;
    workordersCalib = woCalib;
    workordersGm = woGm;
    this.joId = joId;
  }

  @override
  JobtypeState createState() => new JobtypeState();
}

class JobtypeState extends State<JobtypePage> {
  List<String> jobtypes;

  @override
  void initState() {
    super.initState();
    jobtypes = new List();

    if (this.widget.workordersEr.length > 0) {
      jobtypes.add('ER');
    }

    if (this.widget.workordersMf.length > 0) {
      jobtypes.add('MF');
    }

    if (this.widget.workordersCalib.length > 0) {
      jobtypes.add('CAL');
    }

    if (this.widget.workordersGm.length > 0) {
      jobtypes.add('GM');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Jobtype'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.home),
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pushReplacement(
                  MaterialPageRoute(builder: (context) => new MainPage()));
            },
          ),
        ],
      ),
      body: ListView.separated(
        itemCount: jobtypes.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            leading: Icon(Icons.build),
            title: Text(jobtypes[index]),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              switch (jobtypes[index]) {
                case 'ER':
                  push(this.widget.workordersEr);
                  break;
                case 'MF':
                  push(this.widget.workordersMf);
                  break;
                case 'CAL':
                  push(this.widget.workordersCalib);
                  break;
                case 'GM':
                  push(this.widget.workordersGm);
                  break;
              }
            },
          );
        },
        padding: EdgeInsets.only(top: 10.0),
        separatorBuilder: (context, index) => Divider(
          color: Colors.black26,
        ),
      ),
    );
  }

  void push(List<Workorder> workorders) {
    Navigator.push(context, SlideRightRoute(page: WorkordersPage(workorders,
        this.widget.joId)));
  }
}