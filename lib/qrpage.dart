import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:workorderimage/utils.dart';
import 'slide_right_route.dart';
import 'qrcamera.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:barcode_scan/barcode_scan.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:permission_handler/permission_handler.dart';

class QrPage extends StatefulWidget {
  @override
  QrState createState() => QrState();
}

class QrState extends State<QrPage> {
  final qrControl =TextEditingController();
  final typeControl =TextEditingController();
  final joControl =TextEditingController();

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _sending = false;

  @override
  void initState() {
    super.initState();

    //  comment this assignment if you're going to deploy to ER or MF
    typeControl.text = 'MF';
  }

  void setQrCode(code) {
    qrControl.text = code;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('QR Scan'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.send),
            onPressed: () {
              if (qrControl.text.isNotEmpty
                  && typeControl.text.isNotEmpty
                  && joControl.text.isNotEmpty) {

                sendQr({
                  'qr': qrControl.text,
                  'akey': 'vQiC8BkrspwPKMhsKdlIwtytU5ca1LoHs3e05x4nAzEFPCAwYJtWCobMqUiC0NP',
                  'source': 'mcsa',
                  'type': typeControl.text,
                  'joNum': joControl.text,
                });
              } else {
                showSnackbar('Some fields are empty.', 'Required', false);
              }
            },
          ),
        ],
      ),
      body: ModalProgressHUD(
        child: buildWidget(),
        inAsyncCall: _sending,
      ),
    );
  }

  Widget buildWidget() {
    return Container(
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(color: Colors.white,),
      child: ListView(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 40.0),
            child: TextField(
              onChanged: (value) {
                qrControl.text = '';
              },
              controller: qrControl,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                labelText: 'QR',
                hintText: 'QR',
                prefixIcon: Icon(Icons.code),
                suffixIcon: IconButton(icon: Icon(Icons.scanner),
                  onPressed: () {
                    askCameraPermission().then((granted){
                      if (granted) {
                        scanQr().then((result) {
                          var map = json.decode(result);

                          if (map['success']) {
                            qrControl.text = map['data'];
                          } else {
                            Utils.toast(map['reason']);
                          }
                        });
                      } else {
                        Utils.toast('Allow application to access camera');
                      }
                    });
                  },
                ),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15.0))
                ),
              ),
              style: TextStyle(color: Colors.black54),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 10.0),
            child: TextField(

              //  uncomment onTap if you're going deploy to ER or MF
              /*onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return SimpleDialog(
                      children: <Widget>[
                        SimpleDialogOption(
                          //child: Text('ER'),
                          child: ListTile(
                            dense: true,
                            title: Text('ER', style: TextStyle(
                              fontFamily: 'Sansation-Regular',
                              color: Colors.black54,
                              fontSize: 20.0),
                            ),
                          ),
                          onPressed: () {
                            setState(() { typeControl.text = 'er'; });
                            Navigator.of(context).pop();
                          },
                        ),
                        SimpleDialogOption(
                          //child: Text('MF'),
                          child: ListTile(
                            dense: true,
                            title: Text('MF', style: TextStyle(
                              fontFamily: 'Sansation-Regular',
                              color: Colors.black54,
                              fontSize: 20.0),
                            ),
                          ),
                          onPressed: () {
                            setState(() { typeControl.text = 'mf'; });
                            Navigator.of(context).pop();
                          },
                        ),
                        SimpleDialogOption(
                          //child: Text('GM'),
                          child: ListTile(
                            dense: true,
                            title: Text('GM', style: TextStyle(
                              fontFamily: 'Sansation-Regular',
                              color: Colors.black54,
                              fontSize: 20.0),
                            ),
                          ),
                          onPressed: () {
                            setState(() { typeControl.text = 'gm'; });
                            Navigator.of(context).pop();
                          },
                        ),
                        SimpleDialogOption(
                          child: ListTile(
                            dense: true,
                            title: Text('CALIB', style: TextStyle(
                              fontFamily: 'Sansation-Regular',
                              color: Colors.black54,
                              fontSize: 20.0),
                            ),
                          ),
                          onPressed: () {
                            setState(() { typeControl.text = 'calib'; });
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  }
                );
              },*/
              onChanged: (value) {},
              controller: typeControl,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                labelText: 'Type',
                hintText: 'Type',
                prefixIcon: Icon(Icons.merge_type),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15.0))
                ),
              ),
              style: TextStyle(color: Colors.black54),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 10.0),
            child: TextField(
              onChanged: (value) {},
              controller: joControl,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                labelText: 'JO #',
                hintText: 'JO #',
                prefixIcon: Icon(Icons.format_list_numbered),
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
                      child: Text('Submit', style: TextStyle(color: Colors.white),),
                    ),
                    onPressed: () {

                      if (qrControl.text.isNotEmpty
                          && typeControl.text.isNotEmpty
                          && joControl.text.isNotEmpty) {

                        sendQr({
                          'qr': qrControl.text,
                          'akey': 'vQiC8BkrspwPKMhsKdlIwtytU5ca1LoHs3e05x4nAzEFPCAwYJtWCobMqUiC0NP',
                          'source': 'mcsa',
                          'type': typeControl.text,
                          'joNum': joControl.text,
                        });
                      } else {
                        showSnackbar('Some fields are empty.', 'Required', false);
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

  void sendQr(var params) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String domain = prefs.getString('domain');
    String path = prefs.getString('path');
    String sessionId = prefs.getString('sessionId');

    try {
      final uri = new Uri.http(domain, path+'InitScanWorkOrderQr', params,);
      print(uri.toString());
      print(params);

      var response = await http.post(uri, headers: {
        'Accept': 'application/json',
        'Cookie':'JSESSIONID='+sessionId,
      });

      if (response == null) {
        showSnackbar('Unable to create response object. Cause: null.', 'OK', false);
      } else if (response.statusCode == 200) {

        print(response.body);
        var result = json.decode(response.body);
        String msg = result['reason'];

        if (msg == null || msg == '') {
          msg = 'Workorder QR has scanned.';
        }

        showSnackbar(msg, 'OK', false);

        qrControl.clear();
      } else {
        showSnackbar('Status code is not ok.', 'OK', false);
      }
    } catch (e) {
      if (e.runtimeType.toString() == 'SocketException') {
        showSnackbar('Unable to create connection to the server.', 'OK', false);
      } else {
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

  Future<String> scanQr() async {
    try {
      String barcode = await BarcodeScanner.scan();
      return '{"success": true, "reason": "OK", "data": "$barcode"}';

    } on PlatformException {
      return '{"success": false, "reason": "Allow application to access camera."}';
    } catch (e) {
      return '{"success": false, "reason": "An error occurred in scan."}';
    }
  }

  Future<bool> askCameraPermission() async {
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