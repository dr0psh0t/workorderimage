import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'photo_widget.dart';
import 'slide_right_route.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'photo.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:async/async.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:http_parser/http_parser.dart';
import 'utils.dart';

class PhotoListPage extends StatefulWidget {
  List<Photo> photos;
  int joId;
  int len;
  String joNum;

  PhotoListPage(List<Photo> photos, int joId, String joNum) {
    this.photos = photos;
    this.joId = joId;
    this.len = photos.length;
    this.joNum = joNum;
  }

  @override
  PhotoListState createState() => new PhotoListState(this.photos, this.len);
}

class PhotoListState extends State<PhotoListPage> {
  File file;
  int contentSize;
  List<Photo> photos;
  int len;

  bool toLocal = true;
  bool _loading =false;
  final _scaffoldKey =GlobalKey<ScaffoldState>();
  String _selectedId;

  void _onValueChange(String value) {
    setState(() {
      _selectedId = value;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  PhotoListState(List<Photo> photos, int len) {
    this.photos = photos;
    this.len = len;
  }
  
  Future _choose() async {
    file = await ImagePicker.pickImage(source: ImageSource.camera);

    if (file != null) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return ChoiceDialog(
              uploadMultipart: uploadMultipart,
              fileImage: file,
            );
          }
      );
    }
  }

  /*
  void _choose() async {
    try {
      file = await ImagePicker.pickImage(source: ImageSource.camera,);

      if (file != null) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return ChoiceDialog(
                uploadMultipart: uploadMultipart, fileImage: file,);
            }
        );
      }
    } catch (e) {
      showSnackbar(e.toString(), 'Photo Error', 30);
      print(e.toString());
    }
  }*/

  void uploadMultipart(File imageFile, int isMain) async {
    setState(() {
      _loading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String domain = prefs.getString('domain');
    String path = prefs.getString('path');
    String sessionId = prefs.getString('sessionId');

    var stream = new http.ByteStream(DelegatingStream.typed(imageFile.openRead()));
    var length = await imageFile.length();
    var uri = Uri.parse('http://'+domain+path+'UploadJoImage');

    var request = new http.MultipartRequest("POST", uri);
    request.fields['jid'] = this.widget.joId.toString();
    request.fields['isMain'] = isMain.toString();

    Map<String, String> headers = {'Cookie':'JSESSIONID='+sessionId,};

    request.headers.addAll(headers);

    var now = DateTime.now();

    var multipartFile = new http.MultipartFile('image', stream, length,
      filename: this.widget.joNum+'('+now.toString().substring(0, now.toString().indexOf("."))+').jpg',
      contentType: MediaType.parse('image/jpeg'),
    );
    request.files.add(multipartFile);

    var response = await request.send();
    response.stream.transform(utf8.decoder).listen((value) {
      closeModalHUD();
      if (response.statusCode == 200) {
        reloadPhotos({'jid':this.widget.joId.toString(),});

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

  Widget buildWidget() {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Photos'),
        /*
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              Navigator.of(context).pop();
              //Navigator.push(context, SlideRightRoute(page: SearchPage()));

              Navigator.pushReplacement(context, SlideRightRoute(page: SearchPage()));
            },
          ),
        ],*/
      ),
      body: ListView.separated(
        itemCount: len,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            leading: Icon(Icons.photo),
            title: Text(photos[index].filename),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              getPhoto(this.widget.joId.toString(), photos[index].imageId);
            },
          );
        },
        padding: EdgeInsets.only(top: 10.0),
        separatorBuilder: (context, index) => Divider(color: Colors.black26,),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: Icon(Icons.file_upload),
        label: Text('Upload'),
        onPressed: _choose,
      ),
    );
  }

  void closeModalHUD() {
    setState(() {
      _loading = false;
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

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      child: buildWidget(),
      inAsyncCall: _loading,
    );
  }

  Future<String> getPhoto(String jid, String iid) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String domain = prefs.getString('domain');
    String path = prefs.getString('path');
    String sessionId = prefs.getString('sessionId');
    String link = 'http://'+domain+path+'GetJoImage?jid='+jid+'&iid='+iid;
    Navigator.push(context, SlideRightRoute(page: PhotoWidget(link, sessionId)));
    return '';
  }

  Future<void> reloadPhotos(var params) async {
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
        showSnackbar('Unable to create response object. Cause: null.', 'OK', 30);
        closeModalHUD();
      } else if (response.statusCode == 200) {
        closeModalHUD();

        List<dynamic> list = result['images'];
        List<Photo> locPhotos = new List();

        for (int x = 0; x < list.length; x++) {
          locPhotos.add(Photo(
            result['images'][x]['imageId'],
            (result['images'][x]['filename'].toString().isEmpty ? 'No filename' : result['images'][x]['filename']),
            result['images'][x]['isMfImage'],
          ));
        }

        setState(() {
          photos.clear();
          photos.addAll(locPhotos);
          len = photos.length;
        });

      } else {
        showSnackbar('Status code is not ok.', 'OK', 30);
        closeModalHUD();
      }
      //return "about to fix the return in menu.dart";
    } catch (e) {
      closeModalHUD();
      if (e.runtimeType.toString() == 'SocketException') {
        showSnackbar('Unable to create connection to the server.', 'OK', 30);
      } else {
        print(e.toString());
        showSnackbar(e.toString(), 'OK', 30);
      }
      //return "about to fix the return in login_screen.dart";
    }
  }
}

class ChoiceDialog extends StatefulWidget {
  const ChoiceDialog({this.uploadMultipart, this.fileImage});

  final void Function(File, int) uploadMultipart;
  final File fileImage;

  @override
  State createState() => new ChoiceDialogState();
}

class ChoiceDialogState extends State<ChoiceDialog> {
  int selectedRadioTile;

  @override
  void initState() {
    super.initState();
    selectedRadioTile = 0;
  }

  setSelectedRadio(int val) {
    setState(() {
      selectedRadioTile = val;
    });
  }

  Widget build(BuildContext context) {

    return SimpleDialog(
      title: const Text('What to upload'),
      children: <Widget>[
        SimpleDialogOption(
          child: ListTile(
            dense: true,
            leading: Icon(Icons.photo),
            title: Text('Main Photo'),
            contentPadding: EdgeInsets.all(1.0),
          ),
          onPressed: () {
            Navigator.of(context).pop();
            widget.uploadMultipart(widget.fileImage, 1);
          },
        ),
        SimpleDialogOption(
          child: ListTile(
            dense: true,
            leading: Icon(Icons.work),
            title: Text('Additional Photo'),
            contentPadding: EdgeInsets.all(1.0),
          ),
          onPressed: () {
            Navigator.of(context).pop();
            widget.uploadMultipart(widget.fileImage, 0);
          },
        ),
      ],
    );

    /*
    return SimpleDialog(
      title: Text('Upload'),
      children: <Widget>[
        RadioListTile(
          value: 1,
          groupValue: selectedRadioTile,
          title: Text('Main Image'),
          activeColor: Colors.green,
          onChanged: (val) {
            setSelectedRadio(val);
          },
        ),
        RadioListTile(
          value: 2,
          groupValue: selectedRadioTile,
          title: Text('Additional Image'),
          activeColor: Colors.green,
          onChanged: (val) {
            setSelectedRadio(val);
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            FlatButton(
              child: Text('Upload', style: TextStyle(color: Colors.blue),),
              onPressed: () {
                if (selectedRadioTile == 1) { //  main image
                  widget.uploadMultipart(widget.fileImage, 1);
                  Navigator.of(context).pop();
                } else if (selectedRadioTile == 2) { //  extra image
                  widget.uploadMultipart(widget.fileImage, 0);
                  Navigator.of(context).pop();
                }
              },
            ),
            FlatButton(
              child: Text('Close', style: TextStyle(color: Colors.blue),),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ],
    );*/
  }
}