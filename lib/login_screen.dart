import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'slide_right_route.dart';
import 'settings_page.dart';
import 'mainpage.dart';
/*
import 'search_joborder.dart';

 */

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login',
      home: LoginPage(),
      routes: {
        //'/searchpage': (_) => SearchPage(),
        '/mainpage': (_) => MainPage(),
      },
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  LoginPageState createState() => new LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  bool _saving = false;
  final _scaffoldKey =GlobalKey<ScaffoldState>();

  final controllerUsername =TextEditingController();
  final controllerPassword =TextEditingController();

  void showPrefs() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    controllerUsername.text =prefs.getString('username');
    controllerPassword.text =prefs.getString('password');
  }

  void toast(String msg) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIos: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  @override
  void initState() {
    super.initState();
    showPrefs();
  }

  bool _obscureText = true;

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  Widget buildWidget() {
    return Container(
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(color: Colors.white,),
      child: ListView(
        children: <Widget>[
          Stack(
            alignment: Alignment.topCenter,
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width,
                height: 220.0,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.fill,
                    image: AssetImage('assets/images/wmdc_cover_image.jpg'),
                  ),
                ),
              ),
              Positioned(
                top: 30.0,
                child: Container(
                  height: 159.0,
                  width: 129.0,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/wmdc_logo.jpg'),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 40.0),
            child: TextField(
              onChanged: (value) {},
              controller: controllerUsername,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                labelText: 'Username',
                hintText: 'Username',
                prefixIcon: Icon(Icons.perm_contact_calendar),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15.0))
                ),
              ),
              style: TextStyle(color: Colors.black54),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0),
            child: TextField(
              onChanged: (value) {},
              controller: controllerPassword,
              keyboardType: TextInputType.text,
              obscureText: _obscureText,
              decoration: InputDecoration(
                labelText: 'Password',
                hintText: 'Password',
                prefixIcon: Icon(Icons.assignment_ind),
                suffixIcon: IconButton(
                  icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility),
                  onPressed: _toggle,
                ),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15.0))
                ),
              ),
              style: TextStyle(color: Colors.black54),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 30.0),
            padding: const EdgeInsets.only(left: 20.0, right: 20.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: FlatButton(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
                    splashColor: Colors.blue,
                    color: Colors.blue,
                    child: Padding(
                      padding: const EdgeInsets.all(17.0),
                      child: Text('Login', style: TextStyle(color: Colors.white),),
                    ),
                    onPressed: () {
                      String username =controllerUsername.text;
                      String password =controllerPassword.text;

                      if (password.isEmpty) {
                        return getDialog('Password is required.');
                      }

                      var params = {
                        'username':username,
                        'password':password,
                      };

                      login(params);
                    },
                  ),
                ),
              ],
            ),
          ),
          FlatButton(
            onPressed: () {
              displayDialog(context);
            },
            child: Text("Settings", style: TextStyle(color: Colors.black54,),),
          ),
        ],
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
                  Navigator.push(context, SlideRightRoute(page: SettingsScreen()));
                }
              },
            )
          ],
        );
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: ModalProgressHUD(
        child: buildWidget(),
        inAsyncCall: _saving,
      ),
    );
  }

  saveCredentials(String username, String password, String sessionId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("username", username);
    await prefs.setString("password", password);
    await prefs.setString("sessionId", sessionId);
  }

  Future<void> login(var params) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String domain = prefs.getString('domain');
    String path = prefs.getString('path');

    try {
      setState(() { _saving = true; });

      final uri = new Uri.http(domain, path+'Authenticate', params,);

      var response = await http.post(uri, headers: {
        'Accept':'application/json'
      });

      String cookie = response.headers['set-cookie'];

      if (response == null) {
        showSnackbar('Unable to create response object. Cause: null.', 'OK', false);
        setState(() { _saving = false; });
      } else if (response.statusCode == 200) {
        setState(() { _saving = false; });

        var result = json.decode(response.body);

        if (result['success']) {
          int start = cookie.indexOf('=')+1;
          int end = cookie.indexOf(';');

          saveCredentials(
            controllerUsername.text,
            controllerPassword.text,
            cookie.substring(start, end),
          );
          Navigator.of(context).pushReplacementNamed('/mainpage');
        } else {
          showSnackbar(result['reason'], 'OK', false);
        }
      } else {
        showSnackbar('Status code is not ok.', 'OK', false);
        setState(() { _saving = false; });
      }
    } catch (e) {
      setState(() { _saving = false; });
      if (e.runtimeType.toString() == 'SocketException') {
        showSnackbar('Unable to create connection to the server.', 'OK', false);
      } else {
        print(e.toString());
        showSnackbar(e.toString(), 'OK', false);
      }
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

  Future getDialog(String message) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Text(message),
            actions: <Widget>[
              FlatButton(
                child: Text('Close'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        }
    );
  }
}

class ScaleRoute extends PageRouteBuilder {
  final Widget page;
  ScaleRoute({this.page}) : super(
    pageBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
        ) => page,
    transitionsBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
        Widget child,
        ) =>
        ScaleTransition(
          scale: Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).animate(
            CurvedAnimation(parent: animation, curve: Curves.fastOutSlowIn,),
          ),
          child: child,
        ),
  );
}