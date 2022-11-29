import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_ugc_upload/flutter_ugc_upload.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  List<CameraDescription> _cameras = <CameraDescription>[];
  CameraController? controller;
  bool showVideo = false;
  String videoPath  = '';

  @override
  void initState() {
    super.initState();
    initPlatformState();
    FlutterUgcUpload().onProgressResult().listen((ProgressResult event) {
      if (kDebugMode) {
        print('收到上传进度事件');
        print(event.method);
        print(event.toJson());
        //print(json.encode(event));
      }
    });
    initCamera();
  }

  initCamera() async {
    _cameras = await availableCameras();
    controller = CameraController(_cameras[0], ResolutionPreset.high, enableAudio: false);
    controller!.initialize().then((_) {
      if (mounted) {
        setState(() {
          showVideo = true;
        });
      }
    }).catchError((Object e) {});
  }

  Future<XFile?> stopVideoRecording() async {
    final CameraController? cameraController = controller;
    if (cameraController == null || !cameraController.value.isRecordingVideo) {
      return null;
    }
    try {
      return cameraController.stopVideoRecording();
    } on CameraException catch (e) {
    }
  }

  void onVideoRecordButtonPressed() {
    startVideoRecording().then((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  void onStopButtonPressed() {
    stopVideoRecording().then((XFile? file) {
      print(file!.path);
      if (mounted) {
        setState(() {
          videoPath = file.path;
        });
      }
    });
  }

  Future<void> startVideoRecording() async {
    final CameraController? cameraController = controller;
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }
    if (cameraController.value.isRecordingVideo) {
      return;
    }
    try {
      await cameraController.startVideoRecording();
    } on CameraException catch (e) {
      return;
    }
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion =
          await FlutterUgcUpload.platformVersion ?? 'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body:Column(
          children: [
            Text('Running on: $_platformVersion\n'),
            ElevatedButton(onPressed: () async {
              onVideoRecordButtonPressed();
            }, child: const Text("开始录制")),
            ElevatedButton(onPressed: () async {
              onStopButtonPressed();
            }, child: const Text("停止")),
            ElevatedButton(onPressed: () async {
              Directory tempDir = await getTemporaryDirectory();
              String tempPath = tempDir.path;
              print(videoPath);
              int? publishCode = await FlutterUgcUpload.uploadVideo("ZA9cK4ZV92miQRN1i8DlNl0JMDVzZWNyZXRJZD1BS0lEdWQ3S0h4TFRLdUdNQmowMWtDTkh1R0s3U1dLcjc3cUkmY3VycmVudFRpbWVTdGFtcD0xNjY5NjkyMDgxJmV4cGlyZVRpbWU9MzMzOTQ3MDU2MiZyYW5kb209NjIzNDYzMDQyJnZvZFN1YkFwcElkPTE1MDAwMTI2NTMmc3RvcmFnZVJlZ2lvbj1hcC1zaGFuZ2hhaQ==", videoPath);
             print('publishCode');
             print(publishCode);
            }, child: const Text("上传视频video")),
            if(showVideo)
            Expanded(child: CameraPreview(controller!))
          ],
        ),
      ),
    );
  }
}
