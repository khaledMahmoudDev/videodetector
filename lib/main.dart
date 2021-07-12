import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:videodetector/ui/sign_up/sign_up_screen.dart';

import 'constant/Constant.dart';
import 'ui/auth_screen/auth_screen.dart';
import 'ui/auth_screen/background.dart';
import 'ui/login/CameraHomeScreen.dart';
import 'ui/login/login_screen.dart';
class CameraApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(title: 'hello',),
    );
  }
}

List<CameraDescription>? cameras;

Future<Null> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    cameras = await availableCameras();
  } on CameraException catch (e) {
    //logError(e.code, e.description);
  }

  runApp(
    MaterialApp(
      title: "Video Recorder App",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home:  MyHomePage(title: 'hello',),
      routes: <String, WidgetBuilder>{
        CAMERA_SCREEN: (BuildContext context) => CameraHomeScreen(cameras!),//camera record
        SIGNUP_SCREEN: (BuildContext context) => SignUpScreen(),
      },
    ),
  );
}


class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        body: Stack(
          children: <Widget>[
            Background(),
            AuthScreen(),
          ],
        ));
  }
}

