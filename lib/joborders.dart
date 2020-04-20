import 'package:flutter/material.dart';
import 'joborder.dart';
import 'dart:convert';
import 'slide_right_route.dart';
import 'menu.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class JobordersPage extends StatefulWidget {
  List<Joborder> joborders;
  int len;

  JobordersPage(this.joborders) {
    len = joborders.length;
  }

  @override
  JobordersState createState() => new JobordersState();
}

class JobordersState extends State<JobordersPage> {
  var unescape;

  TextEditingController searchController = TextEditingController();

  bool _loading =false;
  final _scaffoldKey =GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    unescape = new HtmlUnescape();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(title: Text('Joborders'),),
      body: Container(
        child: Column(
          children: <Widget>[
            Padding(
                padding: const EdgeInsets.all(5.0),
                child: TextField(
                  onChanged: (value) {

                  },
                  controller: searchController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Search JO',
                    hintText: 'Search JO',
                    prefixIcon: Icon(Icons.format_list_numbered),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.search),
                      onPressed: () {
                        if (searchController.text.length > 2) {
                          search({'q': searchController.text, 'type': 'joid',}).then((map) {
                            if (map['success']) {

                              List<dynamic> list = map['jobOrders'];
                              var result = map['jobOrders'];

                              setState(() {
                                this.widget.joborders = List();
                                this.widget.len = list.length;

                                for (int x = 0; x < this.widget.len; x++) {
                                  this.widget.joborders.add(Joborder(
                                      result[x]['customer'],
                                      result[x]['joNum'],
                                      result[x]['joId']
                                  ));
                                }

                              });
                            }
                          });
                        }
                      },
                    ),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0))
                    ),
                  ),
                ),
              ),
            Expanded(
              child: ListView.separated(
                itemCount: this.widget.len,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    leading: Icon(Icons.assignment),
                    subtitle: Text(unescape.convert(
                        this.widget.joborders[index].customer).toString()),
                    title: Text(this.widget.joborders[index].joNum),
                    trailing: Icon(Icons.arrow_forward_ios),
                    onTap: () {

                      /*
                      Navigator.push(context, SlideRightRoute(page: MenuPage(
                        this.widget.joborders[index].customer,
                        this.widget.joborders[index].joNum,
                        this.widget.joborders[index].joId,
                      )));*/
                    },
                  );
                },
                padding: EdgeInsets.all(5.0),
                separatorBuilder: (context, index) => Divider(
                  color: Colors.black26,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<Map> search(var params) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String domain = prefs.getString('domain');
    String path = prefs.getString('path');
    String sessionId = prefs.getString('sessionId');

    var returnMap = new Map();
    returnMap['success'] = false;

    try {
      setState(() { _loading = true; });

      final uri = new Uri.http(domain, path+'GetJobOrderList', params,);

      var response = await http.post(uri, headers: {
        'Accept':'application/json',
        'Cookie':'JSESSIONID='+sessionId,
      });

      if (response == null) {
        setState(() { _loading = false; });

        returnMap['reason'] = 'No response received. Cause: null.';

      } else if (response.statusCode == 200) {
        setState(() { _loading = false; });

        var result = json.decode(response.body);

        if (result['totalCount'] != null) {

          if (result['totalCount'] < 1) {
            returnMap['reason'] = 'No joborder found.';

          } else if (result['totalCount'] > 0) {

            returnMap['success'] = true;
            returnMap['jobOrders'] = result['jobOrders'];
          }
        } else if (result['success'] != null) {
          returnMap['reason'] = result['reason'];
        } else {
          returnMap['reason'] = response.body;
        }
      } else {
        setState(() { _loading = false; });
        returnMap['reason'] = 'Status code is not ok.';
      }

      return returnMap;
    } catch (e) {
      setState(() { _loading = false; });

      if (e.runtimeType.toString() == 'SocketException') {
        returnMap['reason'] = 'Unable to create connection to the server.';
      } else {
        returnMap['reason'] = e.toString();
      }

      return returnMap;
    }
  }
}