import 'package:workorderimage/model//employee.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'slide_right_route.dart';
import 'complianceratingpage.dart';

class EmployeePage extends StatefulWidget {
  @override
  EmployeePageState createState() {
    return EmployeePageState();
  }
}

class EmployeePageState extends State<EmployeePage> {

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _loading = false;
  Future<List<Employee>> employeeFuture;

  @override
  void initState() {
    super.initState();

    employeeFuture = fetchEmployees();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Employees'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                employeeFuture = fetchEmployees();
              });
            },
          ),
        ],
      ),
      body: ModalProgressHUD(
        inAsyncCall: _loading,
        child: FutureBuilder<List<Employee>>(
          future: employeeFuture,
          builder: (context, snapshot) {

            if (snapshot.hasError) {
              print(snapshot.error);
            }

            List<Employee> employeeList = snapshot.data;

            if (snapshot.hasData) {
              return ListView.separated(
                itemCount: employeeList.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    title: Text(employeeList[index].employee, style: TextStyle(color: Colors.black54),),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(Icons.check_circle),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(context, SlideRightRoute(page: ComplianceRatingPage()));
                    },
                  );
                },
                padding: EdgeInsets.all(1.0),
                separatorBuilder: (context, index) => Divider(color: Colors.black26,),
              );
            } else {
              return Center(child: CircularProgressIndicator(),);
            }
          },
        ),
      ),
    );
  }

  Future<List<Employee>> fetchEmployees() async {

    setState(() {
      _loading = true;
    });

    final uri = Uri.http('192.168.1.30:8080', '/5saudit/getemployees',
        {'asdasd': 'asdasd'});

    var response = await http.post(uri, headers: {
      'Accept':'application/json',
    });

    setState(() {
      _loading = false;
    });

    if (response == null) {
      return null;
    } else if (response.statusCode == 200) {
      return compute(parseData, response.body);
    } else {
      return null;
    }
  }
}

List<Employee> parseData(String responseBody) {
  final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
  return parsed.map<Employee>((json) => Employee.fromJson(json)).toList();
}