import 'dart:async';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:async/async.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';
import 'photo_widget.dart';
import 'slide_right_route.dart';
import 'photo.dart';
import 'utils.dart';

class PhotoListPage extends StatefulWidget {

  List<Photo> photos;
  int joId;
  int len;
  String joNum;

  PhotoListPage({this.photos, this.joId, this.joNum});

  @override
  PhotoListState createState() => new PhotoListState();
}

class PhotoListState extends State<PhotoListPage> {
  File file;
  int contentSize;

  bool toLocal = true;
  bool _loading =false;
  final _scaffoldKey =GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    widget.len = widget.photos.length;
  }
  
  Future _choose() async {

    file = await ImagePicker.pickImage(
      source: ImageSource.camera,
      maxHeight: 600,
      maxWidth: 600,
    );

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

  void uploadMultipart(File imageFile, int isMain) async {
    setState(() { _loading = true; });

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
    var response = await request.send().timeout(const Duration(seconds: 10,));

    response.stream.transform(utf8.decoder).listen((value) {
      setState(() { _loading = false; });

      if (response.statusCode == 200) {
        reloadPhotos({'jid':this.widget.joId.toString(),});

        /*
        <html><body>{success: false,reason:"Image File to large! Reduce file
        size to a max of 256kb!"}</body></html>

        ^
        sample server response above has a bad json format when uploading a
        jo picture. so we have to check a pattern if it contains "success" string.
        if true, show your own success message. if false, display the json. */

        var results = [
          value.contains('{success:true}'),
          value.contains('{success: true}'),
          value.contains('{"success": true}'),
          value.contains('{"success":true}')
        ];

        if (results[0] || results[1] || results[2] || results[3]) {
          Utils.showSnackbar('Joborder picture uploaded.', 'OK', _scaffoldKey);
          file.delete();

        } else {
          Utils.showSnackbar(value, 'OK', _scaffoldKey);
        }

      } else {
        Utils.showSnackbar('Failed to upload parts. Request is not OK.', 'OK', _scaffoldKey);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return ModalProgressHUD(
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text('Photos'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.home),
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
          ],
        ),
        body: ListView.separated(
          itemCount: widget.len,
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              leading: Icon(Icons.photo),
              title: Text(widget.photos[index].filename),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {
                getPhoto(this.widget.joId.toString(), widget.photos[index].imageId);
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
      ),
      inAsyncCall: _loading,
    );
  }

  Future<String> getPhoto(String jid, String iid) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String domain = prefs.getString('domain');
    String path = prefs.getString('path');
    String sessionId = prefs.getString('sessionId');
    String link = 'http://'+domain+path+'GetJoImage?jid='+jid+'&iid='+iid;
    Navigator.push(context, SlideRightRoute(page: PhotoWidget(link: link, sessionId: sessionId)));
    return '';
  }

  Future<void> reloadPhotos(var params) async {

    setState(() { _loading = true; });
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String domain = prefs.getString('domain');
    String path = prefs.getString('path');
    String sessionId = prefs.getString('sessionId');

    try {

      final uri = Uri.http(domain, path+'GetJoImageList', params);
      var response = await http.post(uri, headers: {
        'Accept':'application/json',
        'Cookie':'JSESSIONID='+sessionId,
      }).timeout(const Duration(seconds: 10));

      setState(() { _loading = false; });

      if (response == null) {
        Utils.showSnackbar('Unable to create response object. Cause: null.', 'OK', _scaffoldKey);
      } else if (response.statusCode == 200) {
        var result = json.decode(response.body);

        List<dynamic> list = result['images'];
        List<Photo> locPhotos = new List();

        for (int x = 0; x < list.length; x++) {
          locPhotos.add(Photo(
            imageId: result['images'][x]['imageId'],
            filename: (result['images'][x]['filename'].toString().isEmpty ? 'No filename' : result['images'][x]['filename']),
            isMfImage: result['images'][x]['isMfImage'],
          ));
        }

        setState(() {
          widget.photos.clear();
          widget.photos.addAll(locPhotos);
          widget.len = widget.photos.length;
        });

      } else {
        Utils.showSnackbar('Status code is not ok.', 'OK', _scaffoldKey);
      }

    } on SocketException {
      Utils.showSnackbar('Failed to connect to the server.', 'OK', _scaffoldKey);
    } on TimeoutException {
      Utils.showSnackbar('The server took long to respond.', 'OK', _scaffoldKey);
    } catch (e) {
      Utils.showSnackbar(e.toString(), 'OK', _scaffoldKey);
    } finally {
      setState(() { _loading = false; });
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

  @override
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
  }
}