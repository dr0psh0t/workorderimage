import 'package:flutter/material.dart';
import 'slide_right_route.dart';
import 'photo_widget.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:async/async.dart';
import 'package:http_parser/http_parser.dart';
import 'utils.dart';

class PartsPage extends StatefulWidget {
  bool notviewable;
  String description;
  int quantity;
  int joId;
  int woId;
  int partId;

  PartsPage(bool notviewable, String description, int quantity, int joId, int woId, int partId) {
    this.notviewable = notviewable;
    this.description = description;
    this.quantity = quantity;
    this.joId = joId;
    this.woId = woId;
    this.partId = partId;
  }

  @override
  PartsState createState() => new PartsState();
}

class PartsState extends State<PartsPage> {
  File file;
  bool _loading =false;
  final _scaffoldKey =GlobalKey<ScaffoldState>();
  var unescape;

  @override
  void initState() {
    super.initState();
    unescape = new HtmlUnescape();
  }

  void _choose() async {
    file = await ImagePicker.pickImage(source: ImageSource.camera,);

    if (file != null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Upload'),
            content: Text(file.lengthSync().toString()+' Bytes. '+'Upload Image?'),
            actions: <Widget>[
              FlatButton(
                child: Text('No'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: Text('Yes'),
                onPressed: () {
                  Navigator.of(context).pop();
                  uploadMultipart(file);
                },
              ),
            ],
          );
        }
      );
    }
  }

  void uploadMultipart(File imageFile) async {
    setState(() {
      _loading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String domain = prefs.getString('domain');
    String path = prefs.getString('path');
    String sessionId = prefs.getString('sessionId');

    var stream = new http.ByteStream(DelegatingStream.typed(imageFile.openRead()));
    var length = await imageFile.length();
    var uri = Uri.parse('http://'+domain+path+'ReceiveWorkOrderParts');

    var request = new http.MultipartRequest("POST", uri);
    request.fields['wId'] = this.widget.woId.toString();
    request.fields['pId'] = this.widget.partId.toString();

    Map<String, String> headers = {'Cookie':'JSESSIONID='+sessionId,};
    request.headers.addAll(headers);

    var now = DateTime.now();

    var multipartFile = new http.MultipartFile('image', stream, length,
      filename: this.widget.woId.toString()+'_'+this.widget.partId.toString()+'('+now.toString().substring(0, now.toString().indexOf("."))+').jpg',
      contentType: MediaType.parse('image/jpeg'),
    );
    request.files.add(multipartFile);

    var response = await request.send();
    response.stream.transform(utf8.decoder).listen((value) {
      closeModalHUD();
      if (response.statusCode == 200) {
        String wrongFormat = value.substring(value.indexOf('{'), value.indexOf('}')+1);
        String correctJson;

        if (wrongFormat.contains('true')) {
          correctJson = Utils.correctSuccess(wrongFormat);
        } else {
          correctJson = Utils.correctSuccess(wrongFormat);
          correctJson = Utils.correctReason(correctJson);
        }

        var result = json.decode(correctJson);

        if (result['success']) {
          showSnackbar('Photo Uploaded!', 'OK', 5);
        } else {
          showSnackbar(result['reason'], 'OK', 30);
        }
      } else {
        showSnackbar('Request is not ok.', 'OK', 30);
      }
    });
  }

  void showSnackbar(String msg, String label, int seconds) {
    _scaffoldKey.currentState.showSnackBar(
      SnackBar(
        duration: Duration(seconds: seconds),
        content: Text(msg),
        action: SnackBarAction(
          label: label,
          onPressed: () {
            if (!true) {
              Navigator.of(context).pop();
            }
          },
        ),
      ),
    );
  }

  void closeModalHUD() {
    setState(() {
      _loading = false;
    });
  }

  Widget buildWidget() {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(title: Text('Photos'),),
      body: ListView(
        children: <Widget>[
          ListTile(
            leading: Icon(Icons.description),
            title: Text('Parts Description'),
            subtitle: Text(unescape.convert(this.widget.description).toString()),
          ),
          ListTile(
            leading: Icon(Icons.assignment),
            title: Text('Quantity'),
            subtitle: Text(this.widget.quantity.toString()),
          ),
        ],
      ),
      floatingActionButton: this.widget.notviewable ? getSpeedDial() : getFloatingActionBar(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      child: buildWidget(),
      inAsyncCall: _loading,
    );
  }

  Widget getFloatingActionBar() {
    return FloatingActionButton.extended(
      onPressed: () {
        getPhoto(this.widget.joId.toString(), this.widget.woId.toString(), this.widget.partId.toString());
      },
      icon: Icon(Icons.view_agenda),
      label: Text("View"),
    );
  }

  Future<String> getPhoto(String jid, String wid, String pid) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String domain = prefs.getString('domain');
    String path = prefs.getString('path');
    String sessionId = prefs.getString('sessionId');
    String link = 'http://'+domain+path+'ViewWorkOrderPartsImage?jid='+jid+'&wid='+wid+'&pid='+pid;
    Navigator.push(context, SlideRightRoute(page: PhotoWidget(link, sessionId)));
    return '';
  }

  Widget getSpeedDial() {
    return FloatingActionButton.extended(
      onPressed: _choose,
      icon: Icon(Icons.file_download),
      label: Text("Receive"),
    );
  }
}