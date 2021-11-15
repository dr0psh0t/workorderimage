import 'dart:async';
import 'dart:io';
import 'utils.dart';
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
import 'mainpage.dart';

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

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      child: buildWidget(),
      inAsyncCall: _loading,
    );
  }

  Widget buildWidget() {
    return Scaffold(
      appBar: AppBar(
        title: Text('Workorders'),
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
              var joId = this.widget.joId;
              var woId = this.widget.workorders[index].joWorkId;

              getParts({'woId': woId.toString()}, joId, woId, index).then((result) {
                var map = json.decode(result);

                if (map['success']) {
                  var totalCount = map['data']['totalCount'];

                  if (totalCount > 0) {
                    var map2 = map['data']['woParts'];

                    List<dynamic> list = map['data']['woParts'];
                    List<Part> parts = List();

                    for (int x = 0; x < list.length; x++) {
                      parts.add(Part(
                        partId: map2[x]['partId'],
                        quantity: map2[x]['qty'],
                        isImage: map2[x]['isImage'],
                        description: map2[x]['description'],
                      ));
                    }

                    Navigator.push(context, SlideRightRoute(page: PartsListPage(
                      parts: parts,
                      joId: joId,
                      woId: woId,
                      title: unescape.convert(this.widget.workorders[index].scopeGroup).toString(),
                    )));

                  } else {
                    Utils.showSnackbar('No Parts', 'Empty', _scaffoldKey);
                  }
                } else {
                  Utils.showSnackbar(map['reason'], 'Fail', _scaffoldKey);
                }
              });
            },
          );
        },
        padding: EdgeInsets.only(top: 10.0),
        separatorBuilder: (context, index) => Divider(color: Colors.black26,),
      ),
    );
  }

  Future<String> getParts(var params, int joId, int woId, int index) async {

    setState(() { _loading = true; });
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String domain = prefs.getString('domain');
    String path = prefs.getString('path');
    String sessionId = prefs.getString('sessionId');

    if (domain == null || path == null || sessionId == null) {
      setState(() { _loading = false; });
      return '{"success": false, "reason": "Server address error."}';
    }

    if (domain.isEmpty || path.isEmpty || sessionId.isEmpty) {
      setState(() { _loading = false; });
      return '{"success": false, "reason": "Server address error."}';
    }

    try {

      final uri = Uri.http(domain, path + 'GetWoPartsList', params);
      var response = await http.post(uri, headers: {
        'Accept': 'application/json',
        'Cookie': 'JSESSIONID=' + sessionId,
      }).timeout(const Duration(seconds: 10),);

      if (response == null) {
        return '{"success": false, "reason": "The server took long to respond."}';
      } else if (response.statusCode == 200) {
        return '{"success": true, "data": ${response.body.replaceAll("\n", "").trim()}}';
      } else {
        return '{"success": false, "reason": "Failed to get workorders."}';
      }
    } on SocketException {
      return '{"success": false, "reason": "Failed to connect to the server."}';
    } on TimeoutException {
      return '{"success": false, "reason": "The server took long to respond."}';
    } catch (e) {
      return '{"success": false, "reason": "Cannot search at this time."}';
    } finally {
      setState(() { _loading = false; });
    }
  }
}