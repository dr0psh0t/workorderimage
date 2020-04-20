import 'package:flutter/material.dart';
import 'slide_right_route.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'joborder.dart';
import 'joborders.dart';

class SearchPage extends StatefulWidget {
  @override
  SearchPageState createState() => new SearchPageState();
}

class SearchPageState extends State<SearchPage> {
  TextEditingController searchController = TextEditingController();

  bool _loading =false;
  final _scaffoldKey =GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
  }

  Widget buildWidget() {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(title: Text('Search'),),
      body: getWidgetBody(),
    );
  }

  Widget getWidgetBody() {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 100.0),
            child: TextField(
              onChanged: (value) {},
              controller: searchController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Search Joborder',
                hintText: 'Search Joborder',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15.0))
                ),
              ),
              style: TextStyle(color: Colors.black54),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 20.0),
            padding: const EdgeInsets.only(left: 20.0, right: 20.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: FlatButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0)
                    ),
                    splashColor: Colors.blue,
                    color: Colors.blue,
                    child: Padding(
                      padding: const EdgeInsets.all(17.0),
                      child: Text('Search',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    onPressed: () {
                      if (searchController.text.length > 2) {

                        search({'q': searchController.text, 'type': 'joid',
                        }).then((map) {

                          if (map['success']) {

                            List<dynamic> list = map['jobOrders'];
                            List<Joborder> joborders = new List();
                            var result = map['jobOrders'];

                            for (int x = 0; x < list.length; x++) {
                              joborders.add(Joborder(result[x]['customer'],
                                result[x]['joNum'], result[x]['joId'],));
                            }

                            Navigator.push(context, SlideRightRoute(
                            page: JobordersPage(joborders)));
                          } else {
                            showSnackbar(map['reason'], 'OK', false);
                          }

                        });

                      } else {
                        showSnackbar('Minimum of 3 characters to search', 'OK',
                            false);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(child: buildWidget(), inAsyncCall: _loading,);
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