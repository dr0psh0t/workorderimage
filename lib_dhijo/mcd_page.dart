import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:shared_preferences/shared_preferences.dart';

class McdPage extends StatefulWidget {
  McdPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _McdPageState createState() => _McdPageState();
}

class _McdPageState extends State<McdPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _sending = false;

  TextEditingController controllerMid = TextEditingController();

  @override
  void initState() {
    super.initState();
    controllerMid.text = '1000';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(title: Text('MCD RESTER'),),
      body: ModalProgressHUD(
        inAsyncCall: _sending,
        child: ListView(
          children: ListTile.divideTiles(
            context: context,
            tiles: [
              ListTile(title: Text('JoInfo', style: TextStyle(fontSize: 13.0),), subtitle: Text(joInfo??''),),
              ListTile(title: Text('MId', style: TextStyle(fontSize: 13.0),), subtitle: Text(mId??''),),
              ListTile(title: Text('Start Time', style: TextStyle(fontSize: 13.0),), subtitle: Text(readableStartTime??''),),
              ListTile(title: Text('Dead Time', style: TextStyle(fontSize: 13.0),), subtitle: Text(readableDTime??''),),
              ListTile(title: Text('Reason', style: TextStyle(fontSize: 13.0),), subtitle: Text(reason??''),),
              ListTile(
                subtitle: TextField(
                  onChanged: (value) {},
                  controller: controllerMid,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    labelText: 'Mid',
                    hintText: 'Mid',
                    prefixIcon: Icon(Icons.device_hub),
                    suffixIcon: IconButton(icon: Icon(Icons.send),
                      onPressed: () {

                        getStartEnd({'mId': controllerMid.text, 'uId': '2',
                          'h': '3', 'fw': '4', 'timestamp': '5'}).then((map) {

                            if (map['requestSuccess']) {
                              if (map['reason']['success'] == 1) {
                                setState(() {
                                  reason = 'Workorder is running';
                                  mId = map['reason']['mId'].toString();
                                  joInfo = map['reason']['joInfo'];
                                  startTime = map['reason']['startTime'].toString();
                                  dTime = map['reason']['dTime'].toString();

                                  if (startTime != 'null') {
                                    readableStartTime = DateTime.fromMillisecondsSinceEpoch(
                                        int.parse(startTime) * 1000, isUtc: true).toString();
                                  } else {
                                    readableStartTime = 'null';
                                  }
                                  if (dTime != 'null') {
                                    readableDTime = DateTime.fromMillisecondsSinceEpoch(
                                        int.parse(dTime) * 1000, isUtc: true).toString();
                                  } else {
                                    readableDTime = 'null';
                                  }
                                });
                              } else {
                                setState(() {
                                  reason = map['reason']['reason'];
                                  mId = '';
                                  joInfo = '';
                                  readableDTime = '';
                                  readableStartTime = '';
                                });
                              }
                            } else {
                              showSnackbar(map['reason'], 'OK', false);
                            }
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(15.0))
                    ),
                  ),
                  style: TextStyle(color: Colors.black54),
                ),
              ),
            ]
          ).toList(),
        ),
      ),
    );
  }

  void showSnackbar(String msg, String label, bool popable) {
    _scaffoldKey.currentState.showSnackBar(
      SnackBar(
        content: Text(msg),
        action: SnackBarAction(
          label: label,
          onPressed: () {
            if (popable) {
              Navigator.of(context).pop();
            }
          },
        ),
      ),
    );
  }

  String joInfo;
  String success;
  String reason;
  String hash;
  String mId;
  String startTime;
  String dTime;
  String readableStartTime;
  String readableDTime;

  Future<Map> getStartEnd(var params) async {

    setState(() { _sending = true; });
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String domain = prefs.getString('domain');
    String path = prefs.getString('path');

    var returnMap = new Map();
    returnMap['requestSuccess'] = false;

    try {

      final uri = new Uri.http(domain, path+'IoTCheckWorkQueue', params,);
      var response = await http.post(uri, headers: {'Accept': 'application/json'});

      if (response == null) {
        returnMap['reason'] = 'No response received. Cause: null.';
      } else if (response.statusCode == 200) {
        var result = json.decode(response.body);

        returnMap['requestSuccess'] = true;
        returnMap['reason'] = result;

      } else {
        returnMap['reason'] = 'Status code is not OK.';
      }

      setState(() { _sending = false; });
      return returnMap;

    } on SocketException {

      setState(() { _sending = false; });
      returnMap['reason'] = 'Unable to create connection to the server.';

    } catch (e) {

      setState(() { _sending = false; });
      returnMap['reason'] = e.toString();
      return returnMap;
    }
  }
}