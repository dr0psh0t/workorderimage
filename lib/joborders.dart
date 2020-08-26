import 'package:flutter/material.dart';
import 'joborder.dart';
import 'dart:convert';
import 'slide_right_route.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'photo.dart';
import 'photo_list.dart';
import 'workorder.dart';
import 'jobtype.dart';

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
      body: ModalProgressHUD(
        inAsyncCall: _loading,
        child: Container(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: TextField(
                  onChanged: (value) {},
                  onSubmitted: (value) {
                    searchJo(value);
                  },
                  controller: searchController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Search JO',
                    hintText: 'Search JO',
                    suffixIcon: IconButton(
                      icon: Icon(Icons.search),
                      onPressed: () {
                        searchJo(searchController.text);
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
                      subtitle: Text(unescape.convert(
                          this.widget.joborders[index].customer).toString()),
                      title: Text(this.widget.joborders[index].joNum),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          IconButton(
                            icon: Icon(Icons.photo),
                            onPressed: () {
                              getPhotos({
                                'jid': this.widget.joborders[index].joId.toString(),
                                'joNum': this.widget.joborders[index].joNum,
                              });
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.work),
                            onPressed: () {
                              getWorkorders({
                                'joId': this.widget.joborders[index].joId.toString()
                              }).then((map) {
                                gotoWorkorders(map, index);
                              });
                            },
                          ),
                        ],
                      ),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return SimpleDialog(
                              title: const Text('Choose'),
                              children: <Widget>[
                                SimpleDialogOption(
                                  child: ListTile(
                                    dense: true,
                                    leading: Icon(Icons.photo),
                                    title: Text('Photo'),
                                    contentPadding: EdgeInsets.all(1.0),
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    getPhotos({
                                      'jid': this.widget.joborders[index].joId.toString(),
                                      'joNum': this.widget.joborders[index].joNum,
                                    });
                                  },
                                ),
                                SimpleDialogOption(
                                  child: ListTile(
                                    dense: true,
                                    leading: Icon(Icons.work),
                                    title: Text('Workorders'),
                                    contentPadding: EdgeInsets.all(1.0),
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    getWorkorders({
                                      'joId': this.widget.joborders[index].joId.toString()
                                    }).then((map) {
                                      gotoWorkorders(map, index);
                                    });
                                  },
                                ),
                              ],
                            );
                          }
                        );
                      },
                    );
                  },
                  padding: EdgeInsets.fromLTRB(5, 1, 1, 5),
                  separatorBuilder: (context, index) => Divider(
                    color: Colors.black26,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void gotoWorkorders(var map, int index) {

    if (map['success']) {
      var result = json.decode(map['jsonData']);

      List<dynamic> list = result['jobOrderWorks'];
      List<Workorder> workordersEr = new List();
      List<Workorder> workordersMf = new List();
      List<Workorder> workordersCalib = new List();
      List<Workorder> workordersGm = new List();

      for (int x = 0; x < list.length; x++) {

        var wo = Workorder(
          result['jobOrderWorks'][x]['joWorkId'],
          result['jobOrderWorks'][x]['scopeOfWork'],
          result['jobOrderWorks'][x]['scopeGroup'],
          result['jobOrderWorks'][x]['isPartsReq'],
        );

        switch (result['jobOrderWorks'][x]['jobType']) {
          case 'er':
            workordersEr.add(wo);
            break;
          case 'mf':
            workordersMf.add(wo);
            break;
          case 'calib':
            workordersCalib.add(wo);
            break;
          default:
            workordersGm.add(wo);
        }
      }

      Navigator.push(context, SlideRightRoute(
          page: JobtypePage(workordersEr, workordersMf, workordersCalib,
            workordersGm, this.widget.joborders[index].joId,)));

    } else {
      showSnackbar(map['reason'], 'label', false);
    }
  }

  void searchJo(String searchText) {
    if (searchText.length > 2) {

      search({'q': searchText, 'type': 'joid',}).then((map) {
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

  Future<String> getPhotos(var params) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String domain = prefs.getString('domain');
    String path = prefs.getString('path');
    String sessionId = prefs.getString('sessionId');

    try {
      setState(() { _loading = true; });

      final uri = Uri.http(domain, path+'GetJoImageList', params);

      var response = await http.post(uri, headers: {
        'Accept':'application/json',
        'Cookie':'JSESSIONID='+sessionId,
      });

      var result = json.decode(response.body);

      if (response == null) {
        showSnackbar('Unable to create response object. Cause: null.', 'OK', false);
        setState(() { _loading = false; });
      } else if (response.statusCode == 200) {
        setState(() { _loading = false; });

        List<dynamic> list = result['images'];
        List<Photo> photos = new List();

        for (int x = 0; x < list.length; x++) {
          photos.add(Photo(
            result['images'][x]['imageId'],
            (result['images'][x]['filename'].toString().isEmpty ? 'No filename' : result['images'][x]['filename']),
            result['images'][x]['isMfImage'],
          ));
        }

        Navigator.push(context, SlideRightRoute(page: PhotoListPage(
            photos, int.parse(params['jid']), params['joNum'])));

      } else {
        showSnackbar('Status code is not ok.', 'OK', false);
        setState(() { _loading = false; });
      }
      return "about to fix the return in menu.dart";
    } catch (e) {
      setState(() { _loading = false; });
      if (e.runtimeType.toString() == 'SocketException') {
        showSnackbar('Unable to create connection to the server.', 'OK', false);
      } else {
        showSnackbar(e.toString(), 'OK', false);
      }
      return "about to fix the return in login_screen.dart";
    }
  }

  Future<Map> getWorkorders(var params) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String domain = prefs.getString('domain');
    String path = prefs.getString('path');
    String sessionId = prefs.getString('sessionId');

    var returnMap = new Map();
    returnMap['success'] = false;

    try {
      setState(() { _loading = true; });

      final uri = Uri.http(domain, path+'GetJobOrderWorkList', params);

      var response = await http.post(uri, headers: {
        'Accept':'application/json',
        'Cookie':'JSESSIONID='+sessionId,
      });

      if (response == null) {
        setState(() { _loading = false; });
        returnMap['reason'] = 'No response received. Cause: null.';

      } else if (response.statusCode == 200) {
        setState(() { _loading = false; });

        returnMap['success'] = true;
        returnMap['jsonData'] = response.body;

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