import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workorderimage/utils.dart';
import 'slide_right_route.dart';
import 'settings_page.dart';
import 'mainpage.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login',
      home: LoginPage(),
      routes: {
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
  bool _obscureText = true;
  bool _remember = false;

  final _scaffoldKey =GlobalKey<ScaffoldState>();

  final controllerUsername =TextEditingController();
  final controllerPassword =TextEditingController();
  final _settingsController = TextEditingController();

  void showPrefs() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    controllerUsername.text =prefs.getString('username');
    controllerPassword.text =prefs.getString('password');
  }

  @override
  void initState() {
    super.initState();
    showPrefs();
  }

  void _toggle() {
    setState(() { _obscureText = !_obscureText; });
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

  Widget buildWidget() {

    var bImgHeight = MediaQuery.of(context).size.height * 0.33;
    var imgPos = (bImgHeight / 2) - (bImgHeight * 0.4);

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
                height: bImgHeight,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.fill,
                    image: AssetImage('assets/images/wmdc_cover_image.jpg'),
                  ),
                ),
              ),
              Positioned(
                top: imgPos,
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
            padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 30.0),
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
            //margin: const EdgeInsets.only(top: 30.0),
            padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0),
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
                      if (controllerPassword.text.isEmpty) {
                        Utils.getDialog('Password is required.', context);
                      }

                      return login({
                        'username': controllerUsername.text,
                        'password': controllerPassword.text,
                      }).then((result) {
                        var map = json.decode(result);

                        if (map['body']['success']) {
                          var cookie = map['cookie'];

                          int start = cookie.indexOf('=')+1;
                          int end = cookie.indexOf(';');

                          if (_remember) {
                            saveCredentials(controllerUsername.text, controllerPassword.text,);
                          }

                          saveSession(cookie.substring(start, end));
                          Navigator.of(context).pushReplacementNamed('/mainpage');

                        } else {
                          Utils.showSnackbar(map['reason'], 'OK', _scaffoldKey);
                        }
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.only(left: 1.0, right: 1.0, top: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Expanded(
                  child: CheckboxListTile(
                    title: Text("Save", style: TextStyle(color: Colors.black54),),
                    value: _remember,
                    onChanged: (newValue) {
                      setState(() {
                        _remember = newValue;
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,  //  <-- leading Checkbox
                  ),
                ),
                Expanded(
                  child: FlatButton(
                    child: Text("Settings", style: TextStyle(color: Colors.black54,),),
                    onPressed: () {
                      displayDialog(context);
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

  displayDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Settings'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: _settingsController,
                decoration: InputDecoration(hintText: "Password"),
                obscureText: true,
              ),
              ListTile(
                title: Text('Unsave Account'),
                leading: Icon(Icons.delete),
                onTap: () {
                  //  remove account here
                  setState(() {
                    controllerPassword.text = '';
                  });
                  unsaveAccount();
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          actions: <Widget>[
            FlatButton(
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

  Future<String> login(var params) async {

    setState(() { _saving = true; });
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String domain = prefs.getString('domain');
    String path = prefs.getString('path');

    if (domain == null || path == null) {
      setState(() { _saving = false; });
      return '{"success": false, "reason": "Server address error."}';
    }

    if (domain.isEmpty || path.isEmpty) {
      setState(() { _saving = false; });
      return '{"success": false, "reason": "Server address error."}';
    }

    try {

      final uri = new Uri.http(domain, path+'Authenticate', params,);
      var response = await http.post(uri, headers: {'Accept':'application/json'})
          .timeout(const Duration(seconds: 10),);

      String cookie = response.headers['set-cookie'];

      if (response == null) {
        return '{"success": false, "reason": "The server took long to respond."}';
      } else if (response.statusCode == 200) {
        return '{"body":${response.body.replaceAll("\n", "").trim()}, "cookie":\"$cookie\"}';
      } else {
        return '{"success": false, "reason": "Login failed."}';
      }
    } on SocketException {
      return '{"success": false, "reason": "Failed to connect to the server."}';
    } on TimeoutException {
      return '{"success": false, "reason": "The server took long to respond."}';
    } catch (e) {
      return '{"success": false, "reason": "Cannot login at this time."}';
    } finally {
      setState(() { _saving = false; });
    }
  }

  unsaveAccount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('password', '');
  }

  saveCredentials(String username, String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("username", username);
    await prefs.setString("password", password);
  }

  saveSession(String sessionId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("sessionId", sessionId);
    //print(sessionId);
  }
}