import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import 'package:intl/intl.dart';

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
              ListTile(title: Text('Reason', style: TextStyle(fontSize: 13.0),), subtitle: Text(reason),),
              ListTile(title: Text('MId', style: TextStyle(fontSize: 13.0),), subtitle: Text(mId),),
              ListTile(title: Text('Start Time', style: TextStyle(fontSize: 13.0),), subtitle: Text(readableStartTime),),
              ListTile(title: Text('Dead Time', style: TextStyle(fontSize: 13.0),), subtitle: Text(readableDTime),),
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
                          'h': '3', 'fw': '4', 'timestamp': '5'});
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

  String success;
  String reason;
  String hash;
  String mId;
  String startTime;
  String dTime;
  String readableStartTime;
  String readableDTime;

  Future<void> getStartEnd(var params) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String domain = prefs.getString('domain');
    String path = prefs.getString('path');

    try {
      setState(() { _sending = true; });

      //final uri = new Uri.http('192.168.1.150:8080',
          //'/joborder/IoTCheckWorkQueue', params);

      final uri = new Uri.http(domain, path+'IoTCheckWorkQueue', params,);

      var response = await http.post(uri, headers: {'Acc'
          'ept': 'application/json'});

      if (response == null) {
        setState(() { _sending = false; });

        showSnackbar('Unable to create response object. Cause: null.', 'OK',
            false);
      } else if (response.statusCode == 200) {
        var result = json.decode(response.body);

        setState(() {
          _sending = false;

          success = result['success'].toString();
          reason = result['reason'].toString();
          hash = result['hash'].toString();
          mId = result['mId'].toString();
          startTime = result['startTime'].toString();
          dTime = result['dTime'].toString();

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
      }
    } catch (e) {
      setState(() { _sending = false; });

      if (e.runtimeType.toString() == 'SocketException') {
        showSnackbar('Unable to create connection to the server.', 'OK', false);
      } else {
        print(e.toString());
        showSnackbar(e.toString(), 'OK', false);
      }
    }
  }
}