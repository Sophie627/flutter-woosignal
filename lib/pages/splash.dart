import 'package:flutter/material.dart';
import 'package:splashscreen/splashscreen.dart';

import 'ciudad.dart';

class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => new _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  Widget build(BuildContext context) {
    return new SplashScreen(
        seconds: 5,
        navigateAfterSeconds: new Ciudad(),
//        title: new Text('Welcome In SplashScreen',
//          style: new TextStyle(
//              fontWeight: FontWeight.bold,
//              fontSize: 20.0
//          ),),
        image: new Image.asset('assets/images/splash.gif'),
        backgroundColor: Colors.white,
        styleTextUnderTheLoader: new TextStyle(),
        photoSize: 100.0,
        onClick: ()=>print("Flutter Egypt"),
        loaderColor: Colors.red
    );
  }
}