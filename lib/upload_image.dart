import 'package:flutter/material.dart';

class UploadPage extends StatefulWidget {
  @override
  UploadPageState createState() => new UploadPageState();
}

class UploadPageState extends State<UploadPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Upload photo for this part'),),
      body: Container(child: Text('UI here'),),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton.extended(
        elevation: 4.0,
        icon: const Icon(Icons.add_a_photo),
        label: const Text('Add a photo'),
        onPressed: () {},
      ),
    );
  }
}