import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:intl/intl.dart';

class McdPage extends StatefulWidget {
  McdPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _McdPageState createState() => _McdPageState();
}

class _McdPageState extends State<McdPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _sending = false;

  //  10007
  String wuhu_boring_start = 'start';
  String wuhu_boring_end = 'end';

  //  100061
  String sunnen_honing_start = 'start';
  String sunnen_honing_end = 'end';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('MCD RESTER'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.send),
            onPressed: () {
              get_wuhu_boring({'mId': '100061', 'uId': '2', 'h': '3', 'fw': '4', 'timestamp': '5'});
            },
          ),
        ],
      ),
      body: ModalProgressHUD(
        inAsyncCall: _sending,
        child: ListView(
          children: <Widget>[
            ListTile(
              title: Text('10007'),
              subtitle: Text(wuhu_boring_start+' - '+wuhu_boring_end),
            ),
            ListTile(
              title: Text('100061'),
              subtitle: Text(sunnen_honing_start+' - '+sunnen_honing_end),
            ),
          ],
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

  Future<void> get_wuhu_boring(var params) async {
    try {
      setState(() { _sending = true; });
      
      final uri = new Uri.http('192.168.1.150:8080',
          '/joborder/IoTCheckWorkQueue', params);
      
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

          String startTime = result['startTime'].toString();
          String dTime = result['dTime'].toString();

          final df = new DateFormat('dd-MM-yyyy hh:mm a');

          if (startTime != 'null') {
            wuhu_boring_start = DateTime.fromMillisecondsSinceEpoch(
                int.parse(startTime) * 1000, isUtc: true).toString();
          } else {
            wuhu_boring_start = 'null';
          }

          if (dTime != 'null') {
            wuhu_boring_end = DateTime.fromMillisecondsSinceEpoch(
                int.parse(dTime) * 1000, isUtc: true).toString();
          } else {
            wuhu_boring_end = 'null';
          }
          
          /*
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
          }*/
        });
      } else {
        setState(() { _sending = false; });
        showSnackbar('Request unsuccessful.', 'OK', false);
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