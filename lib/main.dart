import 'package:flutter/material.dart';
import 'login_screen.dart';

void main() {

  WidgetsFlutterBinding.ensureInitialized();
  runApp(new MaterialApp(home: new MyApp(),));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return LoginScreen();
  }
}