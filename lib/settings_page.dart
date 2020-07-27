import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  @override
  State createState() => new SettingsState();
}

class SettingsState extends State<SettingsScreen> {

  @override
  void initState() {
    super.initState();
    initUrl();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings'),),
      body: Container(
        child: ListView(
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.domain),
              title: Text('Domain'),
              subtitle: Text(domainController.text),
              dense: true,
              onTap: () {
                domainDialog(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.directions),
              title: Text('Path'),
              subtitle: Text(pathController.text),
              dense: true,
              onTap: () {
                pathDialog(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.drafts),
              title: Text('Set Defaults'),
              subtitle: Text('Set Defaults'),
              dense: true,
              onTap: () {
                saveDomain('192.168.1.150:8080');
                savePath('/joborder/');
              },
            ),
          ],
        ),
      ),
    );
  }

  TextEditingController domainController = TextEditingController();
  TextEditingController pathController = TextEditingController();

  domainDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Set domain'),
          content: TextField(
            controller: domainController,
            keyboardType: TextInputType.text,
            inputFormatters: [
              WhitelistingTextInputFormatter(RegExp("[^\\s+]")),
            ],
            decoration: InputDecoration(hintText: "Enter domain here"),
          ),
          actions: <Widget>[
            new FlatButton(
              child: new Text('OK'),
              onPressed: () {
                if (domainController.text.isEmpty) {
                  final snackBar = SnackBar(
                    content: Text('Domain is required.'),
                    action: SnackBarAction(
                      label: 'OK',
                      onPressed: () {
                        // Some code to undo the change!
                      },
                    ),
                  );
                  // Find the Scaffold in the Widget tree and use it to show a SnackBar!
                  Scaffold.of(context).showSnackBar(snackBar);
                } else {
                  saveDomain(domainController.text);
                  Navigator.of(context).pop();
                }
              },
            )
          ],
        );
      }
    );
  }

  pathDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Set path'),
            content: TextField(
              controller: pathController,
              keyboardType: TextInputType.text,
              inputFormatters: [
                WhitelistingTextInputFormatter(RegExp("[^\\s+]")),
              ],
              decoration: InputDecoration(hintText: "Enter path here"),
            ),
            actions: <Widget>[
              new FlatButton(
                child: new Text('OK'),
                onPressed: () {
                  if (domainController.text.isEmpty) {
                    final snackBar = SnackBar(
                      content: Text('Path is required.'),
                      action: SnackBarAction(
                        label: 'OK',
                        onPressed: () {
                          // Some code to undo the change!
                        },
                      ),
                    );
                    // Find the Scaffold in the Widget tree and use it to show a SnackBar!
                    Scaffold.of(context).showSnackBar(snackBar);
                  } else {
                    savePath(pathController.text);
                    Navigator.of(context).pop();
                  }
                },
              )
            ],
          );
        }
    );
  }

  initUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      this.domainController.text = prefs.getString('domain');
      this.pathController.text = prefs.getString('path');
    });
  }

  saveDomain(String domain) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("domain", domain);
    setState(() {
      this.domainController.text = domain;
    });
  }

  savePath(String thisPath) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("path", thisPath);
    setState(() {
      this.pathController.text = thisPath;
    });
  }
}