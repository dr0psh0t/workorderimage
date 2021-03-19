import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:workorderimage/utils.dart';

class SettingsScreen extends StatefulWidget {
  @override
  State createState() => new SettingsState();
}

class SettingsState extends State<SettingsScreen> {
  bool _rotating = false;
  final _scaffoldKey =GlobalKey<ScaffoldState>();

  TextEditingController domainController = TextEditingController();
  TextEditingController pathController = TextEditingController();
  TextEditingController attendDomain = TextEditingController();
  TextEditingController attendPath = TextEditingController();

  SharedPreferences prefs;

  @override
  void initState() async {
    super.initState();
    initUrl();
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      key: _scaffoldKey,
      inAsyncCall: _rotating,
      child: Scaffold(
        appBar: AppBar(title: Text('Settings'),),
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
                leading: Icon(Icons.drafts),
                title: Text('Set Defaults'),
                subtitle: Text('Set Defaults'),
                dense: true,
                onTap: () {
                  saveDomain('192.168.1.150:8080');
                  savePath('/joborder/');
                },
              ),

              //  uncomment if released to production
              ListTile(
                leading: Icon(Icons.verified_user, color: Colors.black54,),
                trailing: IconButton(
                  icon: Icon(Icons.send, color: Colors.black54,),
                  onPressed: () {
                    if (attendDomain.text.isNotEmpty && attendPath.text.isNotEmpty) {
                      sendAttendance({'emp_badge': '4208589316'}).then((result) {
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
                title: Text('Attendance'),
                subtitle: Text(attendDomain.text+attendPath.text),
                dense: true,
                onTap: () {

                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('Attendance Address'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            TextField(
                              controller: attendDomain,
                              keyboardType: TextInputType.text,
                              inputFormatters: [WhitelistingTextInputFormatter(RegExp("[^\\s+]")),],
                              decoration: InputDecoration(hintText: "Attend Domain here"),
                            ),
                            TextField(
                              controller: attendPath,
                              keyboardType: TextInputType.text,
                              inputFormatters: [WhitelistingTextInputFormatter(RegExp("[^\\s+]")),],
                              decoration: InputDecoration(hintText: "Attend Path here"),
                            ),
                          ],
                        ),
                        actions: <Widget>[
                          IconButton(
                            icon: Icon(Icons.check_circle, color: Colors.black54,),
                            onPressed: () {

                              if (attendDomain.text.isNotEmpty && attendPath.text.isNotEmpty) {
                                saveAttendDomain(attendDomain.text, attendPath.text);
                                Navigator.of(context).pop();
                              } else {
                                Utils.toast('Fill all fields');
                              }
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.close, color: Colors.black54,),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    }
                  );

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
                  final snackBar = SnackBar(
                    content: Text('Domain is required.'),
                    action: SnackBarAction(
                      label: 'OK',
                      onPressed: () {
                        // Some code to undo the change!
                      },
                    ),
                  );
                  // Find the Scaffold in the Widget tree and use it to show a SnackBar!
                  Scaffold.of(context).showSnackBar(snackBar);
                } else {
                  saveDomain(domainController.text);
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
                if (domainController.text.isEmpty) {
                  final snackBar = SnackBar(
                    content: Text('Path is required.'),
                    action: SnackBarAction(
                      label: 'OK',
                      onPressed: () {
                        // Some code to undo the change!
                      },
                    ),
                  );
                  // Find the Scaffold in the Widget tree and use it to show a SnackBar!
                  Scaffold.of(context).showSnackBar(snackBar);
                } else {
                  savePath(pathController.text);
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
      this.domainController.text = prefs.getString('domain');
      this.pathController.text = prefs.getString('path');
      this.attendDomain.text = prefs.getString('attendanceDomain');
      this.attendPath.text = prefs.getString('attendancePath');
    });
  }

  saveAttendDomain(String domain, String path) async {
    await prefs.setString("attendanceDomain", domain);
    await prefs.setString("attendancePath", path);

    setState(() {
      this.attendDomain.text = domain;
      this.attendPath.text = path;
    });
  }

  saveDomain(String domain) async {
    await prefs.setString("domain", domain);
    setState(() {
      this.domainController.text = domain;
    });
  }

  savePath(String thisPath) async {
    await prefs.setString("path", thisPath);
    setState(() {
      this.pathController.text = thisPath;
    });
  }

  Future<String> sendAttendance(var params) async {
    setState(() { _rotating = true; });

    try {

      final uri = new Uri.http(attendDomain.text, attendPath.text, params,);
      var response = await http.post(uri, headers: {'Accept':'application/json'})
          .timeout(const Duration(seconds: 30),);

      if (response == null) {
        return '{"success": false, "reason": "The server took long to respond."}';
      } else if (response.statusCode == 200) {
        return response.body;
      } else {
        return '{"success": false, "reason": "Login failed."}';
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
}