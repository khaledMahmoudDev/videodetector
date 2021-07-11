import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class CameraHomeScreen extends StatefulWidget {
  List<CameraDescription> cameras;

  CameraHomeScreen(this.cameras);

  @override
  State<StatefulWidget> createState() {
    return _CameraHomeScreenState();
  }
}

class _CameraHomeScreenState extends State<CameraHomeScreen> {

  bool _toggleCamera = false;
  bool _startRecording = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  CameraController? controller;
  XFile? videoFile;
  late String videoPath;

  final String _assetVideoRecorder = 'assets/images/ic_video_shutter.png';
  final String _assetStopVideoRecorder = 'assets/images/ic_stop_video.png';


  VideoPlayerController? videoController;
  VoidCallback? videoPlayerListener;


  @override
  void initState() {
    try {
      onCameraSelected(widget.cameras[0]);
    } catch (e) {
      print(e.toString());
    }
    super.initState();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.cameras.isEmpty) {
      return Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(16.0),
        child: Text(
          'No Camera Found!',
          style: TextStyle(
            fontSize: 16.0,
            color: Colors.white,
          ),
        ),
      );
    }

    if (!controller!.value.isInitialized) {
      return Container();
    }

    return AspectRatio(
      key: _scaffoldKey,
      aspectRatio: controller!.value.aspectRatio,
      child: Container(
        child: Stack(
          children: <Widget>[
            CameraPreview(controller!),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                height: 120.0,
                padding: EdgeInsets.all(20.0),
                color: Color.fromRGBO(00, 00, 00, 0.7),
                child: Stack(
                  //mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Align(
                      alignment: Alignment.center,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.all(Radius.circular(50.0)),
                          onTap: () {
                            !_startRecording
                                ? onVideoRecordButtonPressed()
                                : onStopButtonPressed();
                            setState(() {
                              _startRecording = !_startRecording;
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.all(4.0),
                            child: Image.asset(
                              !_startRecording
                                  ? _assetVideoRecorder
                                  : _assetStopVideoRecorder,
                              width: 72.0,
                              height: 72.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                    !_startRecording ? _getToggleCamera() : new Container(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

  }

  Widget _getToggleCamera() {
    return Align(
      alignment: Alignment.centerRight,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.all(Radius.circular(50.0)),
          onTap: () {
            !_toggleCamera
                ? onCameraSelected(widget.cameras[1])
                : onCameraSelected(widget.cameras[0]);
            setState(() {
              _toggleCamera = !_toggleCamera;
            });
          },
          child: Container(
            padding: EdgeInsets.all(4.0),
            child: Image.asset(
              'assets/images/ic_switch_camera_3.png',
              color: Colors.grey[200],
              width: 42.0,
              height: 42.0,
            ),
          ),
        ),
      ),
    );
  }

  void onCameraSelected(CameraDescription cameraDescription) async {
    if (controller != null) await controller!.dispose();
    controller = CameraController(cameraDescription, ResolutionPreset.medium);

    controller!.addListener(() {
      if (mounted) setState(() {});
      if (controller!.value.hasError) {
        showSnackBar('Camera Error: ${controller!.value.errorDescription}');
      }
    });

    try {
      await controller!.initialize();
    } on CameraException catch (e) {
      _showException(e);
    }

    if (mounted) setState(() {});
  }

  String timestamp() => new DateTime.now().millisecondsSinceEpoch.toString();


  void onVideoRecordButtonPressed() {
    startVideoRecording().then((_) {
      if (mounted) setState(() {});
    });
  }

  void onStopButtonPressed() {
    stopVideoRecording().then((_) {
      if (mounted) setState(() {});
      showSnackBar('Video recorded to: $_');
      videoFile = _;
      setCameraResult();
    });
  }

  Future<void> startVideoRecording() async {
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
      return;
    }

    if (cameraController.value.isRecordingVideo) {
      // A recording is already started, do nothing.
      return null;
    }

    try {
      await cameraController.startVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      return;
    }
  }

  Future<XFile?> stopVideoRecording() async {
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isRecordingVideo) {
      return null;
    }

    try {
      return await cameraController.stopVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }

  }

  void _showException(CameraException e) {
    logError(e.code, e.description!);
    showSnackBar('Error: ${e.code}\n${e.description}');
  }

  void showSnackBar(String message) {
    print(message);

  }
  void _showCameraException(CameraException e) {
    logError(e.code, e.description!);
    showInSnackBar('Error: ${e.code}\n${e.description}');
  }
  void showInSnackBar(String message) {
    // ignore: deprecated_member_use
    _scaffoldKey.currentState?.showSnackBar(SnackBar(content: Text(message)));
  }
  void setCameraResult() {
    print("Recording Done! ${videoFile!.path}");
    Navigator.pop(context, videoFile!.path);
  }

  void logError(String code, String message) =>
      print('Error: $code\nMessage: $message');
}
