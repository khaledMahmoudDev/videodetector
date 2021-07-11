import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:videodetector/constant/Constant.dart';
import 'package:videodetector/ui/auth_screen/auth_screen.dart';
import 'package:videodetector/ui/component/input_widget.dart';
import 'package:videodetector/ui/record_video/record_video.dart';

class SignUpScreen extends StatefulWidget {
  SignUpScreen();

  @override
  State<StatefulWidget> createState() {
    return _SignUpScreenState();
  }
}

class _SignUpScreenState extends State<SignUpScreen> {
  String? _videoPath = null;
  double _headerHeight = 320.0;
  final String _assetPlayImagePath = 'assets/images/ic_play.png';
  final String _assetImagePath = 'assets/images/ic_no_video.png';

  var _thumbPath;

  var _videoName;

  _SignUpScreenState();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
          children: <Widget>[
            _videoPath != null ? _getVideoContainer() : _getImageFromAsset(),
            _getCameraFab(),
            _getLogo(),
          ],
        ));
  }

  Widget _getImageFromAsset() {
    return ClipPath(
      child: Padding(
        padding: EdgeInsets.only(bottom: 30.0),
        child: Container(
            width: double.infinity,
            height: _headerHeight,
            color: Colors.grey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset(
                  _assetImagePath,
                  fit: BoxFit.fill,
                  width: 48.0,
                  height: 32.0,
                ),
                Container(
                  margin: EdgeInsets.only(top: 8.0),
                  child: Text(
                    'No Video Available',
                    style: TextStyle(
                      color: Colors.grey[350],
                      //fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                  ),
                ),
              ],
            )),
      ),
    );
  }

  Widget _getVideoContainer() {
    return Container(
      padding: EdgeInsets.only(bottom: 30.0),
      child: new Container(
          width: double.infinity,
          height: _headerHeight,
          color: Colors.grey,
          child: Stack(
            children: <Widget>[
              _thumbPath != null
                  ? new Opacity(
                opacity: 0.5,
                child: new Image.file(
                  File(
                    _thumbPath,
                  ),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: _headerHeight,
                ),
              )
                  : new Container(),
              new Align(
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(new MaterialPageRoute(
                            builder: (BuildContext context) =>
                            new VideoPlayerScreen(_videoPath!)));
                      },
                      child: new Image.asset(
                        _assetPlayImagePath,
                        width: 72.0,
                        height: 72.0,
                      ),
                    ),
                    new Container(
                      margin: EdgeInsets.only(top: 2.0),
                      child: Text(
                        _videoName != null ? _videoName : "",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _buildPathWidget()
            ],
          )),
    );
  }

  Widget _buildPathWidget() {
    return _videoPath != null
        ? new Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: double.infinity,
        height: 100.0,
        padding: EdgeInsets.only(
            left: 10.0, right: 10.0, top: 5.0, bottom: 5.0),
        color: Color.fromRGBO(00, 00, 00, 0.7),
        child: Center(
          child: Text(
            _videoPath!,
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    )
        : new Container();
  }

  Widget _getCameraFab() {
    return Positioned(
      top: _headerHeight - 30.0,
      right: 16.0,
      child: FloatingActionButton(
        onPressed: _recordVideo,
        child: Icon(
          Icons.videocam,
          color: Colors.white,
        ),
        backgroundColor: Colors.red,
      ),
    );
  }

  Widget _getLogo() {
    return Container(
      margin: EdgeInsets.only(top: 400.0),
      alignment: Alignment.center,
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              InputWidget(30.0, 0.0, "email@example.com"),
              InputWidget(30.0, 0.0, '01010101000'),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushNamed(HOME_SCREEN);
                    },
                    child: roundedRectButton(
                        "Sign Up", signInGradients, false)),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future _recordVideo() async {
    final videoPath = await Navigator.of(context).pushNamed(CAMERA_SCREEN);
    print('path vid $_videoPath');
    setState(() {
      _videoPath = videoPath.toString();
    });
  }
}
