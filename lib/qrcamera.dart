import 'package:flutter/material.dart';
import 'package:qr_mobile_vision/qr_camera.dart';
import 'package:qr_mobile_vision/qr_mobile_vision.dart';

class QrCameraPage extends StatefulWidget {
  QrCameraPage({Key key, this.callback}) : super(key: key);

  final Function callback;

  @override
  QrCameraState createState() => QrCameraState();
}

class QrCameraState extends State<QrCameraPage> {
  List<BarcodeFormats> formats;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  bool isScanned = false;

  @override
  void initState() {
    super.initState();
    formats = [BarcodeFormats.QR_CODE];

    /*
    formats = [
      BarcodeFormats.CODE_128,
      BarcodeFormats.CODE_39,
      BarcodeFormats.CODE_93,
      BarcodeFormats.CODABAR,
      BarcodeFormats.EAN_13,
      BarcodeFormats.EAN_8,
      BarcodeFormats.ITF,
      BarcodeFormats.UPC_A,
      BarcodeFormats.UPC_E,
    ];*/
  }

  BuildContext context;

  @override
  Widget build(BuildContext context) {
    this.context = context;
    return Scaffold(
      key: _scaffoldKey,
      body: Stack(
        children: <Widget>[
          Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height/1.40,
              child: QrCamera(
                fit: BoxFit.cover,
                formats: formats,
                qrCodeCallback: (code) {
                  if (!isScanned) {
                    widget.callback(code);
                    setState(() {
                      isScanned = true;
                    });
                    Navigator.of(context).pop();
                  }
                },
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset(
                  'assets/images/cross-hair.png',
                  width: 200.0,
                  height: 200.0,
                ),
                Padding(
                  padding: EdgeInsets.only(top: 30.0),
                  child: Text('Start scanning QR code', style: TextStyle(color: Colors.white),),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void futureDelay() {
    Future.delayed(const Duration(milliseconds: 1000), (){
      setState(() {
        isScanned = false;
      });
    });
  }
}