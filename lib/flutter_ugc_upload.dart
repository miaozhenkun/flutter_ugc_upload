
import 'dart:async';

import 'package:flutter/services.dart';

class FlutterUgcUpload {
  static const MethodChannel _channel = MethodChannel('flutter_ugc_upload');
  static const EventChannel _eventChannel =  EventChannel('flutter_ugc_upload_stream');

  static final Stream<Map<String, Object>> _onGetResult = _eventChannel
      .receiveBroadcastStream()
      .asBroadcastStream()
      .map<Map<String, Object>>((element) => element.cast<String, Object>());

  StreamController<ProgressResult>? _receiveStream;
  StreamSubscription<Map<String, Object>>? _subscription;

  /// 获取上传进度流
  Stream<ProgressResult> onProgressResult() {
    if (_receiveStream == null) {
      _receiveStream = StreamController();
      _subscription = _onGetResult.listen((Map<String, Object> event) {
        print('event----'+ event.toString());
        Map<String, Object> newEvent = Map<String, Object>.of(event);
        _receiveStream?.add( ProgressResult.fromMap(newEvent));
      });
    }
    return _receiveStream!.stream;
  }

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
  static Future<Map?>  uploadVideo(String signature, String videoPath,{String? coverPath = ""}) async {
    var arguments = {};
    arguments['signature'] = signature;
    arguments['videoPath'] = videoPath;
    arguments['coverPath'] = coverPath;
    Map map = await _channel.invokeMethod('uploadVideo', arguments);
    return map;
  }
}

class ProgressResult {
  final int progress;
  final int uploadBytes;
  final int totalBytes;
  ProgressResult({required this.progress,required this.uploadBytes,required this.totalBytes});
  factory ProgressResult.fromMap(Map<dynamic, dynamic> map) =>  ProgressResult(
    progress: map['progress'],
    uploadBytes: map['uploadBytes'],
    totalBytes: map['totalBytes'],
  );
}