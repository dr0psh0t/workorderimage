import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Utils {
  static String correctSuccess(String jsonStr) {
    int start = jsonStr.indexOf('success');
    int end = jsonStr.lastIndexOf('s:')+1;
    String correctJson;

    correctJson = jsonStr.substring(0, start) + '"'
        + jsonStr.substring(start, end) + '"'
        + jsonStr.substring(end, jsonStr.length);
    return correctJson;
  }

  static String correctReason(String jsonStr) {
    int start = jsonStr.indexOf('reason');
    int end = jsonStr.lastIndexOf('n:')+1;
    String correctJson;

    correctJson = jsonStr.substring(0, start) + '"'
        + jsonStr.substring(start, end) + '"'
        + jsonStr.substring(end, jsonStr.length);
    return correctJson;
  }

  static void toast(String msg) {
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

  static void showSnackbar(String msg, String label, var _scaffoldKey) {
    _scaffoldKey.currentState.showSnackBar(
      SnackBar(
        content: Text(msg),
        action: SnackBarAction(
          label: label,
          onPressed: () {
          },
        ),
      ),
    );
  }

  static void getDialog(String message, var context) {
    showDialog(
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

  /*
  displayDialog(BuildContext context, var _settingsController) async {
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
  }*/
}