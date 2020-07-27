import 'package:flutter/material.dart';
import 'part.dart';
import 'parts.dart';
import 'slide_right_route.dart';
import 'package:html_unescape/html_unescape.dart';
import 'mainpage.dart';

class PartsListPage extends StatefulWidget {
  List<Part> parts;
  int len;
  int joId;
  int woId;
  String title;

  PartsListPage(List<Part> parts, int joId, int woId, String title) {
    this.parts = parts;
    this.len = parts.length;
    this.joId = joId;
    this.woId = woId;
    this.title = title;
  }

  @override
  PartsListState createState() => new PartsListState();
}

class PartsListState extends State<PartsListPage> {
  var unescape;

  @override
  void initState() {
    super.initState();
    unescape = new HtmlUnescape();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Parts'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.home),
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pushReplacement(
                  MaterialPageRoute(builder: (context) => new MainPage()));
            },
          ),
        ],
      ),
      body: ListView.separated(
        itemCount: this.widget.len,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            leading: Icon(Icons.build),
            title: Text('Description'),
            subtitle: Text(unescape.convert(this.widget.parts[index].description).toString()),
            trailing: Icon(this.widget.parts[index].isImage == 1 ? Icons.check_circle : Icons.block),
            onTap: () {
              Navigator.push(context, SlideRightRoute(page: PartsPage(
                this.widget.parts[index].isImage==0,
                this.widget.parts[index].description,
                this.widget.parts[index].quantity,
                this.widget.joId,
                this.widget.woId,
                this.widget.parts[index].partId,
              )));
            },
          );
        },
        padding: EdgeInsets.only(top: 10.0),
        separatorBuilder: (context, index) => Divider(
          color: Colors.black26,
        ),
      ),
    );
  }
}