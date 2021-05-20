import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';

class Utils {

  /*static String north = '192.168.1.150:8080';
  static String central = '122.52.48.202:3316';
  static String south = '122.52.155.109:1116';
  static String bohol = '58.69.126.27:3316';*/

  static Map<String, String> domainMaps = {
    'North': '192.168.1.150:8080',
    //'North': '122.3.176.235:1959',
    'Central': '122.52.48.202:3316',
    'South': '122.52.155.109:1116',
    'Bohol': '58.69.126.27:3316',
  };

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
      gravity: ToastGravity.BOTTOM,
      timeInSecForIos: 1,
      backgroundColor: Colors.blue,
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

  static Future<bool> askCameraPermission() async {
    var status = await Permission.camera.status;

    // The user opted to never again see the permission request dialog for this
    // app. The only way to change the permission's status now is to let the
    // user manually enable it in the system settings.
    if (status.isPermanentlyDenied) {


      openAppSettings();
      return false;
    }

    if (status.isGranted) {
      return status.isGranted;
    } else {
      if (await Permission.camera.request().isGranted) {
        status = await Permission.camera.status;
        return status.isGranted;
      } else {
        return false;
      }
    }
  }
}