import 'package:flutter/material.dart';
import 'slide_right_route.dart';
import 'workorder.dart';
import 'photo_list.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'photo.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'jobtype.dart';
//import 'search_joborder.dart';

class MenuPage extends StatefulWidget {
  String customer;
  String joNum;
  int joId;

  MenuPage(String customer, String joNum, int joId) {
    this.customer = customer;
    this.joNum = joNum;
    this.joId = joId;
  }

  @override
  MenuPageState createState() => new MenuPageState();
}

class MenuPageState extends State<MenuPage> {
  bool _loading = false;
  final _scaffoldKey =GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
  }

  Widget buildWidget() {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(this.widget.customer),
        /*
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              //Navigator.push(context, SlideRightRoute(page: SearchPage()));
              //Navigator.pushReplacement(context, SlideRightRoute(page: SearchPage()));
            },
          ),
        ]*/
      ),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ButtonTheme(
              minWidth: 110.0,
              height: 70.0,
              child: RaisedButton(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(padding: EdgeInsets.only(bottom: 10.0),),
                    Icon(Icons.photo, color: Colors.white,),
                    Padding(padding: EdgeInsets.only(bottom: 10.0),),
                    Text("  Photos  ", style: TextStyle(color: Colors.white),),
                    Padding(padding: EdgeInsets.only(bottom: 10.0),),
                  ],
                ),
                color: Colors.blue,
                shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(20.0)),
                onPressed: () {
                  getPhotos({'jid':this.widget.joId.toString(),});
                },
              ),
            ),
            Padding(padding: EdgeInsets.only(left: 10.0, right: 10.0),),
            ButtonTheme(
              minWidth: 110.0,
              height: 70.0,
              child: RaisedButton(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(padding: EdgeInsets.only(bottom: 10.0),),
                    Icon(Icons.scanner, color: Colors.white,),
                    Padding(padding: EdgeInsets.only(bottom: 10.0),),
                    Text('Workorders', style: TextStyle(color: Colors.white),),
                    Padding(padding: EdgeInsets.only(bottom: 10.0),),
                  ],
                ),
                color: Colors.blue,
                shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(20.0)),
                onPressed: () {
                  getWorkorders({'joId':this.widget.joId.toString()});
                },
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

  Future<String> getPhotos(var params) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String domain = prefs.getString('domain');
    String path = prefs.getString('path');
    String sessionId = prefs.getString('sessionId');

    try {
      setState(() {
        _loading =true;
      });

      final uri = Uri.http(domain, path+'GetJoImageList', params);

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

        List<dynamic> list = result['images'];
        List<Photo> photos = new List();

        for (int x = 0; x < list.length; x++) {
          photos.add(Photo(
            result['images'][x]['imageId'],
            (result['images'][x]['filename'].toString().isEmpty ? 'No filename' : result['images'][x]['filename']),
            result['images'][x]['isMfImage'],
          ));
        }
        
        Navigator.push(context, SlideRightRoute(page: PhotoListPage(photos, this.widget.joId, this.widget.joNum)));
      } else {
        showSnackbar('Status code is not ok.', 'OK', false);
        closeModalHUD();
      }
      return "about to fix the return in menu.dart";
    } catch (e) {
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

  Future<String> getWorkorders(var params) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String domain = prefs.getString('domain');
    String path = prefs.getString('path');
    String sessionId = prefs.getString('sessionId');

    try {
      setState(() {
        _loading =true;
      });

      final uri = Uri.http(domain, path+'GetJobOrderWorkList', params);

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

        List<dynamic> list = result['jobOrderWorks'];
        List<Workorder> workordersEr = new List();
        List<Workorder> workordersMf = new List();
        List<Workorder> workordersCalib = new List();
        List<Workorder> workordersGm = new List();

        for (int x = 0; x < list.length; x++) {
          if (result['jobOrderWorks'][x]['jobType'] == 'er') {
            workordersEr.add(Workorder(
              result['jobOrderWorks'][x]['joWorkId'],
              result['jobOrderWorks'][x]['scopeOfWork'],
              result['jobOrderWorks'][x]['scopeGroup'],
              result['jobOrderWorks'][x]['isPartsReq'],
            ));
          } else if (result['jobOrderWorks'][x]['jobType'] == 'mf') {
            workordersMf.add(Workorder(
              result['jobOrderWorks'][x]['joWorkId'],
              result['jobOrderWorks'][x]['scopeOfWork'],
              result['jobOrderWorks'][x]['scopeGroup'],
              result['jobOrderWorks'][x]['isPartsReq'],
            ));
          } else if (result['jobOrderWorks'][x]['jobType'] == 'calib') {
            workordersCalib.add(Workorder(
              result['jobOrderWorks'][x]['joWorkId'],
              result['jobOrderWorks'][x]['scopeOfWork'],
              result['jobOrderWorks'][x]['scopeGroup'],
              result['jobOrderWorks'][x]['isPartsReq'],
            ));
          } else {
            workordersGm.add(Workorder(
              result['jobOrderWorks'][x]['joWorkId'],
              result['jobOrderWorks'][x]['scopeOfWork'],
              result['jobOrderWorks'][x]['scopeGroup'],
              result['jobOrderWorks'][x]['isPartsReq'],
            ));
          }
        }

        Navigator.push(context, SlideRightRoute(
          page: JobtypePage(workordersEr, workordersMf, workordersCalib, workordersGm, this.widget.joId)
        ));
      } else {
        showSnackbar('Status code is not ok.', 'OK', false);
        closeModalHUD();
      }
      return "about to fix the return in menu.dart";
    } catch (e) {
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