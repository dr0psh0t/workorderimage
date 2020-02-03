import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'slide_right_route.dart';
import 'qrcamera.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:barcode_scan/barcode_scan.dart';

class QrPage extends StatefulWidget {
  @override
  QrState createState() => QrState();
}

class QrState extends State<QrPage> {
  final qrControl =TextEditingController();
  final typeControl =TextEditingController();
  final joControl =TextEditingController();

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
  }

  void setQrCode(code) {
    qrControl.text = code;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(title: Text('QR Scan'),),
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(color: Colors.white,),
        child: ListView(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 40.0),
              child: TextField(
                onChanged: (value) {
                  //print(value);
                  qrControl.text = '';
                },
                controller: qrControl,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  labelText: 'QR',
                  hintText: 'QR',
                  prefixIcon: Icon(Icons.code),
                  suffixIcon: IconButton(icon: Icon(Icons.scanner),
                    onPressed: barcodeScan,
                    /*onPressed: () {
                      Navigator.push(context, SlideRightRoute(
                          page: QrCameraPage(callback: setQrCode,)));
                    },*/
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
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return SimpleDialog(
                        children: <Widget>[
                          SimpleDialogOption(
                            child: Text('ER'),
                            onPressed: () {
                              setState(() { typeControl.text = 'er'; });
                              Navigator.of(context).pop();
                            },
                          ),
                          SimpleDialogOption(
                            child: Text('MF'),
                            onPressed: () {
                              setState(() { typeControl.text = 'mf'; });
                              Navigator.of(context).pop();
                            },
                          ),
                          SimpleDialogOption(
                            child: Text('GM'),
                            onPressed: () {
                              setState(() { typeControl.text = 'gm'; });
                              Navigator.of(context).pop();
                            },
                          ),
                          SimpleDialogOption(
                            child: Text('CALIB'),
                            onPressed: () {
                              setState(() { typeControl.text = 'calib'; });
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    }
                  );
                },
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
                        sendQr({
                          'qr': qrControl.text,
                          'akey': 'vQiC8BkrspwPKMhsKdlIwtytU5ca1LoHs3e05x4nAzEFPCAwYJtWCobMqUiC0NP',
                          'source': 'mcsa',
                          'type': typeControl.text,
                          'joNum': joControl.text,});
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      /*
      floatingActionButton: FloatingActionButton.extended(
        label: Text('QR Scan'),
        icon: Icon(Icons.scanner),
        onPressed: barcodeScan,
        //  use this if the phone has a clear camera enough to scan small qr images.
        //  using the qr_mobile_vision plugin. otherwise, use barcodeScan method for
        //  lower-end phones.
        //onPressed: () { Navigator.push(context,
            //SlideRightRoute(page: QrCameraPage(callback: setQrCode, ))); },
      ),*/
    );
  }

  void sendQr(var params) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String domain = prefs.getString('domain');
    String path = prefs.getString('path');
    String sessionId = prefs.getString('sessionId');

    try {
      final uri = new Uri.http(domain, path+'InitScanWorkOrderQr', params,);

      var response = await http.post(uri, headers: {
        'Accept': 'application/json',
        'Cookie':'JSESSIONID='+sessionId,
      });

      if (response == null) {
        showSnackbar('Unable to create response object. Cause: null.', 'OK', false);
      } else if (response.statusCode == 200) {
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

  void barcodeScan() async {
    try {
      String barcode = await BarcodeScanner.scan();
      setState(() {
        qrControl.text = barcode.toString();
      });
    } catch (e) {
      showSnackbar(e.toString(), 'Scanning Error', false);
    }
  }
}