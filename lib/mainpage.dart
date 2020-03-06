import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'slide_right_route.dart';
import 'search_joborder.dart';
import 'qrpage.dart';
import 'settings_page.dart';
import 'login_screen.dart';
import 'mcd_page.dart';

class MainPage extends StatefulWidget {
  @override
  MainPageState createState() => new MainPageState();
}

class MainPageState extends State<MainPage> {
  bool _loading = false;
  final _scaffoldKey =GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
  }

  Widget buildWidget() {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.http),
            onPressed: () {
              //Navigator.of(context).pop();
              //Navigator.push(context, SlideRightRoute(page: McdPage()));
              Navigator.push(context, MaterialPageRoute(builder: (context) => McdPage()));
            },
          ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              displayDialog(context);
            },
          ),
          IconButton(
            icon: Icon(Icons.archive),
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pushReplacement(
                  MaterialPageRoute(builder: (context) => new LoginScreen()));
            },
          ),
        ],
      ),
      key: _scaffoldKey,
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RaisedButton(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(padding: EdgeInsets.only(bottom: 10.0),),
                  Icon(Icons.work, color: Colors.white,),
                  Padding(padding: EdgeInsets.only(bottom: 10.0),),
                  Text('Joborder Parts', style: TextStyle(color: Colors.white),),
                  Padding(padding: EdgeInsets.only(bottom: 10.0),),
                ],
              ),
              color: Colors.blue,
              shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(20.0)),
               onPressed: () {
                Navigator.push(context, SlideRightRoute(page: SearchPage()));
              },
            ),
            Padding(padding: EdgeInsets.only(left: 10.0, right: 10.0),),
            RaisedButton(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(padding: EdgeInsets.only(bottom: 10.0),),
                  Icon(Icons.scanner, color: Colors.white,),
                  Padding(padding: EdgeInsets.only(bottom: 10.0),),
                  Text('  QR Scanner  ', style: TextStyle(color: Colors.white),),
                  Padding(padding: EdgeInsets.only(bottom: 10.0),),
                ],
              ),
              color: Colors.blue,
              shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(20.0)),
              onPressed: () {
                //Navigator.pushReplacement(context, SlideRightRoute(page: QrPage()));
                Navigator.push(context, SlideRightRoute(page: QrPage()));
              },
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

  TextEditingController _settingsController = TextEditingController();
  
  displayDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Settings'),
          content: TextField(
            controller: _settingsController,
            decoration: InputDecoration(hintText: "Password"),
            obscureText: true,
          ),
          actions: <Widget>[
            new FlatButton(
              child: new Text('OK'),
              onPressed: () {
                if (_settingsController.text == 'wmdcdev') {
                  _settingsController.text = '';
                  Navigator.of(context).pop();
                  //Navigator.push(context, SlideRightRoute(page: SettingsScreen()));
                  Navigator.push(context, MaterialPageRoute(
                      builder: (context) => SettingsScreen()));
                }
              },
            )
          ],
        );
      });
  }
}