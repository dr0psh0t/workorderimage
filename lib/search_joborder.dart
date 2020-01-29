import 'package:flutter/material.dart';
import 'slide_right_route.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20.0,
                  top: 100.0),
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
                          search({'q': searchController.text, 'type': 'joid',});
                        } else {
                          Fluttertoast.showToast(
                            msg: 'Minimum of 3 characters in length in search.',
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.CENTER,
                            timeInSecForIos: 1,
                            backgroundColor: Colors.black38,
                            textColor: Colors.white,
                            fontSize: 16.0,
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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

  Future<String> search(var params) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String domain = prefs.getString('domain');
    String path = prefs.getString('path');
    String sessionId = prefs.getString('sessionId');

    try {
      setState(() { _loading = true; });

      final uri = new Uri.http(domain, path+'GetJobOrderList', params,);

      var response = await http.post(uri, headers: {
        'Accept':'application/json',
        'Cookie':'JSESSIONID='+sessionId,
      });

      if (response == null) {
        showSnackbar('Unable to create response object. Cause: null.', 'OK',
            false);
        setState(() { _loading = false; });
      } else if (response.statusCode == 200) {
        setState(() { _loading = false; });
        var result = json.decode(response.body);

        if (result['totalCount'] != null) {
          if (result['totalCount'] < 1) {
            showSnackbar('0 Joborder/s found.', 'OK', false);
          } else if (result['totalCount'] > 0) {
            List<dynamic> list = result['jobOrders'];
            List<Joborder> joborders = new List();

            for (int x = 0; x < list.length; x++) {
              joborders.add(Joborder(
                result['jobOrders'][x]['customer'],
                result['jobOrders'][x]['joNum'],
                result['jobOrders'][x]['joId'],
              ));
            }
            Navigator.push(context, SlideRightRoute(
                page: JobordersPage(joborders)));
          }
        } else if (result['success'] != null) {
          showSnackbar(result['reason'], 'OK', false);
        } else {
          showSnackbar(response.body, 'OK', false);
        }
      } else {
        showSnackbar('Status code is not ok.', 'OK', false);
        setState(() { _loading = false; });
      }
      return "about to fix the return in search_joborder.dart";
    } catch (e) {
      setState(() { _loading = false; });
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