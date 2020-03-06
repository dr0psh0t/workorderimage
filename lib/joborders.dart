import 'package:flutter/material.dart';
import 'joborder.dart';
import 'slide_right_route.dart';
import 'menu.dart';
import 'package:html_unescape/html_unescape.dart';

class JobordersPage extends StatefulWidget {
  List<Joborder> joborders;
  int len;

  JobordersPage(List<Joborder> joborders) {
    this.joborders = joborders;
    this.len = joborders.length;
  }

  @override
  JobordersState createState() => new JobordersState();
}

class JobordersState extends State<JobordersPage> {
  var unescape;

  @override
  void initState() {
    super.initState();
    unescape = new HtmlUnescape();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Joborders'),),
      body: ListView.separated(
        itemCount: this.widget.len,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            leading: Icon(Icons.assignment),
            subtitle: Text(unescape.convert(
                this.widget.joborders[index].customer).toString()),
            title: Text(this.widget.joborders[index].joNum),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {

              Navigator.push(context, SlideRightRoute(page: MenuPage(
                this.widget.joborders[index].customer,
                this.widget.joborders[index].joNum,
                this.widget.joborders[index].joId,
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