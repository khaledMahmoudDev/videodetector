import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:videodetector/constant/Constant.dart';
import 'package:videodetector/network/network_service.dart';
import 'package:videodetector/ui/auth_screen/auth_screen.dart';
import 'package:videodetector/ui/component/input_widget.dart';
import 'package:videodetector/ui/record_video/record_video.dart';

class HomeScreen extends StatefulWidget {
  final String mainUrl;

  HomeScreen(this.mainUrl);

  @override
  State<StatefulWidget> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends State<HomeScreen> {
  String? _videoPath = null;
  XFile? _videoFile = null;
  final ImagePicker _picker = ImagePicker();
  double _headerHeight = 320.0;
  final String _assetPlayImagePath = 'assets/images/ic_play.png';
  final String _assetImagePath = 'assets/images/ic_no_video.png';

  var _thumbPath;

  var _videoName;

  _HomeScreenState();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: <Widget>[
        _videoPath != null ? _getVideoContainer() : _getImageFromAsset(),
        _getCameraFab(),
        _getLoginButton(),
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
      child: Row(
        children: [
          FloatingActionButton(
            onPressed: _recordVideo,
            child: Icon(
              Icons.videocam,
              color: Colors.white,
            ),
            backgroundColor: Colors.red,
          ),
          SizedBox(
            width: 8,
          ),
          FloatingActionButton(
            onPressed: _pickVideo,
            child: Icon(
              Icons.video_call,
              color: Colors.white,
            ),
            backgroundColor: Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _getLoginButton() {
    return LoginButtonWidget(
        videoPath: _videoPath,
        widget: widget,
        videoFile: _videoFile,
        context: context);
  }

  Future _recordVideo() async {
    final videoPath = await Navigator.of(context).pushNamed(CAMERA_SCREEN);
    print('path vid $_videoPath');
    setState(() {
      _videoFile = videoPath as XFile;
      _videoPath = _videoFile!.path;
    });
  }

  Future _pickVideo() async {
    PickedFile? videoFile = await _picker.getVideo(source: ImageSource.gallery);
    // final videoPath = await Navigator.of(context).pushNamed(CAMERA_SCREEN);
    print('path vid ${videoFile!.path}');
    setState(() {
      _videoPath = videoFile.path;
    });
  }
}

class LoginButtonWidget extends StatefulWidget {
  var loading = false;

  LoginButtonWidget({
    Key? key,
    required String? videoPath,
    required this.widget,
    required XFile? videoFile,
    required this.context,
  })  : _videoPath = videoPath,
        _videoFile = videoFile,
        super(key: key);

  final String? _videoPath;
  final HomeScreen widget;
  final XFile? _videoFile;
  final BuildContext context;

  @override
  State<LoginButtonWidget> createState() => _LoginButtonWidgetState();
}

class _LoginButtonWidgetState extends State<LoginButtonWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 400.0),
      alignment: Alignment.center,
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: widget.loading == false
                    ? GestureDetector(
                        onTap: () async {
                          if (widget._videoPath != '' &&
                              widget._videoPath != null) {
                            setState(() {
                              widget.loading = true;
                            });
                            print("Video loading");
                            var response = await NetworkService().sendVideoDio(
                                widget.widget.mainUrl, widget._videoPath!);
                            setState(() {
                              widget.loading = false;
                            });
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text('Result'),
                                  content: Text(response!),
                                  actions: <Widget>[
                                    FlatButton(
                                      child: Text('OK'),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ],
                                );
                              },
                            );

                            print("Video loading done");
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text("Please record video first"),
                            ));
                          }
                        },
                        child: roundedRectButton(
                            "Check Now", signInGradients, false))
                    : CircularProgressIndicator(),
              )
            ],
          ),
        ),
      ),
    );
  }
}
