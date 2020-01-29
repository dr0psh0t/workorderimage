import 'package:flutter/material.dart';
import 'parts_list.dart';
import 'part.dart';
import 'slide_right_route.dart';
import 'workorder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:html_unescape/html_unescape.dart';

class WorkordersPage extends StatefulWidget {
  List<Workorder> workorders;
  int joId;
  int len;

  WorkordersPage(List<Workorder> workorders, int joId) {
    this.workorders = workorders;
    this.joId = joId;
    this.len = workorders.length;
  }

  @override
  WorkordersPageState createState() => new WorkordersPageState();
}

class WorkordersPageState extends State<WorkordersPage> {
  bool _loading = false;
  final _scaffoldKey =GlobalKey<ScaffoldState>();
  var unescape;

  @override
  void initState() {
    super.initState();
    unescape = new HtmlUnescape();
  }

  Widget buildWidget() {
    return Scaffold(
      appBar: AppBar(title: Text('Workorders'),),
      key: _scaffoldKey,
      body: ListView.separated(
        itemCount: this.widget.len,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            leading: Icon(Icons.work),
            title: Text(unescape.convert(this.widget.workorders[index].scopeGroup).toString()),
            subtitle: Text(unescape.convert(this.widget.workorders[index].scopeOfWork).toString()),
            trailing: this.widget.workorders[index].isPartsReq == 1 ? Icon(Icons.arrow_forward_ios) : null,
            onTap: () {
              getParts({'woId': this.widget.workorders[index].joWorkId.toString()},
                  this.widget.joId, this.widget.workorders[index].joWorkId, index);
            },
          );
        },
        padding: EdgeInsets.only(top: 10.0),
        separatorBuilder: (context, index) => Divider(color: Colors.black26,),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      child: buildWidget(),
      inAsyncCall: _loading,
    );
  }

  void closeModalHUD() {
    setState(() {
      _loading = false;
    });
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

  Future<String> getParts(var params, int joId, int woId, int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String domain = prefs.getString('domain');
    String path = prefs.getString('path');
    String sessionId = prefs.getString('sessionId');

    try {
      setState(() {
        _loading =true;
      });

      final uri = Uri.http(domain, path+'GetWoPartsList', params);

      var response = await http.post(uri, headers: {
        'Accept':'application/json',
        'Cookie':'JSESSIONID='+sessionId,
      });

      var result = json.decode(response.body);

      if (response == null) {
        showSnackbar('Unable to create response object. Cause: null.', 'OK', false);
        closeModalHUD();
      } else if (response.statusCode == 200) {
        closeModalHUD();

        List<dynamic> list = result['woParts'];
        List<Part> parts = new List();

        for (int x = 0; x < list.length; x++) {
          parts.add(Part(
            result['woParts'][x]['partId'],
            result['woParts'][x]['qty'],
            result['woParts'][x]['isImage'],
            result['woParts'][x]['description'],
          ));
        }

        Navigator.push(context, SlideRightRoute(page: PartsListPage(parts,
            joId, woId, unescape.convert(
                this.widget.workorders[index].scopeGroup).toString())));
      } else {
        showSnackbar('Status code is not ok.', 'OK', false);
        closeModalHUD();
      }
      return "about to fix the return in menu.dart";
    } catch (e) {
      print(e.toString());
      closeModalHUD();
      if (e.runtimeType.toString() == 'SocketException') {
        showSnackbar('Unable to create connection to the server.', 'OK', false);
      } else {
        print(e.toString());
        showSnackbar(e.toString(), 'OK', false);
      }
      return "about to fix the return in login_screen.dart";
    }
  }
}