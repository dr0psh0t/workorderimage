import 'package:flutter/material.dart';
import 'package:splashscreen/splashscreen.dart';
import 'login_screen.dart';
//import 'package:flutter/services.dart';

void main() {
  /*
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(new MaterialApp(home: new MyApp(),));
  });*/

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
    return new SplashScreen(
      seconds: 2,
      navigateAfterSeconds: LoginScreen(),
      title: new Text(
        'Wellmade Motors',
        style: new TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20.0,
          color: Color(0xFF4aa0d5),
        ),
      ),
      image: Image.asset('assets/images/wmdc_logo.jpg'),
      backgroundColor: Colors.white,
      styleTextUnderTheLoader: new TextStyle(),
      photoSize: 100.0,
      onClick: () {
        print('Flutter Egypt');
      },
      loaderColor: Colors.transparent,
    );
  }
}

class AfterSplash extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: Text('Welcome In Wellmade Package'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Text(
          'Done!',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 30.0,
          ),
        ),
      ),
    );
  }
}