import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class PhotoWidget extends StatelessWidget {

  String link;
  String sessionId;

  PhotoWidget({this.link, this.sessionId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Photo'),
      ),
      body: Container(
        color: Colors.white30,
        child: PhotoView(
          imageProvider: NetworkImage(
            link,
            headers: {
              'Cookie':'JSESSIONID='+sessionId,
            }
          ),
          minScale: PhotoViewComputedScale.contained * 0.8,
          maxScale: 4.0,
        ),
      ),
    );
  }
}