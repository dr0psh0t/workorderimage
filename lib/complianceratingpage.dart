import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:workorderimage/photo_list.dart';

class ComplianceRatingPage extends StatefulWidget {
  @override
  ComplianceRatingPageState createState() {
    return ComplianceRatingPageState();
  }
}

class ComplianceRatingPageState extends State<ComplianceRatingPage> {

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _loading = false;
  File file;

  List _elements = [
    {'name': 'Proper labeled lockers, tables & Cabinets', 'group': 'SORTING(Clear up unnecessary items)'},
    {'name': 'Desk or Machinery', 'group': 'SORTING(Clear up unnecessary items)'},
    {'name': 'Orderly storage of docs, tools & jiggs', 'group': 'SORTING(Clear up unnecessary items)'},
    {'name': 'Completed works wrap & labeled', 'group': 'SORTING(Clear up unnecessary items)'},
    {'name': 'Work Materials & Useable Items are organized', 'group': 'SORTING(Clear up unnecessary items)'},
    {'name': 'Machines are washed & lubricated', 'group': 'SYSTEMIZING(Arranged in Good Order)'},
    {'name': 'Strict P.M. Checklist Compliance', 'group': 'SYSTEMIZING(Arranged in Good Order)'},
    {'name': 'Ease & Efficient Use of Resources', 'group': 'SYSTEMIZING(Arranged in Good Order)'},
    {'name': 'Any Type of defects reported ASAP', 'group': 'SYSTEMIZING(Arranged in Good Order)'},
    {'name': 'Continuous to Improve', 'group': 'SYSTEMIZING(Arranged in Good Order)'},
    {'name': 'Allies and working areas are not restricted', 'group': 'SWEEP & CLEAN - Preventive Maintenance'},
    {'name': 'Cleaning before & after use', 'group': 'SWEEP & CLEAN - Preventive Maintenance'},
    {'name': 'Standard process for disposal', 'group': 'SWEEP & CLEAN - Preventive Maintenance'},
    {'name': 'Hazardous waste are separately stored', 'group': 'SWEEP & CLEAN - Preventive Maintenance'},
    {'name': 'Waste are properly stored & disposed', 'group': 'SWEEP & CLEAN - Preventive Maintenance'},
    {'name': 'Ventilation - Quality of Air', 'group': 'STANDARDIZATION - Safety & Productivity'},
    {'name': 'Proper Lighting system', 'group': 'STANDARDIZATION - Safety & Productivity'},
    {'name': 'Uniform, haircut, & safety shoes', 'group': 'STANDARDIZATION - Safety & Productivity'},
    {'name': 'Strict Compliance to the 3rd S', 'group': 'STANDARDIZATION - Safety & Productivity'},
    {'name': 'Machines are in Perfect Condition', 'group': 'STANDARDIZATION - Safety & Productivity'},
    {'name': 'Continuous to Improvement', 'group': 'SELF DISCIPLINE - Company Interest above Self'},
    {'name': 'Audit findings favorably acted', 'group': 'SELF DISCIPLINE - Company Interest above Self'},
    {'name': 'WM Policies are strictly followed', 'group': 'SELF DISCIPLINE - Company Interest above Self'},
    {'name': 'Influences others to comply', 'group': 'SELF DISCIPLINE - Company Interest above Self'},
    {'name': '"I love my job & Machine" Attitude', 'group': 'SELF DISCIPLINE - Company Interest above Self'},
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Compliance and Rating Sheet'),
      ),
      /*body: ModalProgressHUD(
        inAsyncCall: _loading,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),*/
      body: GroupedListView<dynamic, String>(
        groupBy: (element) => element['group'],
        elements: _elements,
        order: GroupedListOrder.DESC,
        useStickyGroupSeparators: true,
        groupSeparatorBuilder: (String value) => Padding(
          padding: const EdgeInsets.all(3.0),
          child: Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black54),
          ),
        ),
        itemBuilder: (c, element) {
          return Card(
            elevation: 8.0,
            margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
            child: Container(
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                title: Text(element['name']),
                trailing: Icon(Icons.camera),
                onTap: _choose,
              ),
            ),
          );
        },
      ),
    );
  }

  Future _choose() async {

    file = await ImagePicker.pickImage(
      source: ImageSource.camera,
      //maxHeight: 800 - (800 * 0.25),
      //maxWidth: 600 - (600 * 0.25),
      maxHeight: 600,
      maxWidth: 600,
    );

    //file = await ImagePicker.pickImage(source: ImageSource.camera);

    if (file != null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return ChoiceDialog(fileImage: file,);
        }
      );
    }
  }
}

class ChoiceDialog extends StatefulWidget {
  //const ChoiceDialog({this.uploadMultipart, this.fileImage});
  const ChoiceDialog({this.fileImage});

  //final void Function(File, int) uploadMultipart;
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
      title: const Text('Status'),
      children: <Widget>[
        SimpleDialogOption(
          child: ListTile(
            dense: true,
            leading: Icon(Icons.check_circle),
            title: Text('Yes'),
            contentPadding: EdgeInsets.all(1.0),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        SimpleDialogOption(
          child: ListTile(
            dense: true,
            leading: Icon(Icons.cancel),
            title: Text('No'),
            contentPadding: EdgeInsets.all(1.0),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}