import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class FlutterUgcUpload {
  static const MethodChannel _channel = MethodChannel('flutter_ugc_upload');
  static const EventChannel _eventChannel = EventChannel('flutter_ugc_upload_stream');

  static final Stream<Map<String, Object>> _onGetResult =
      _eventChannel.receiveBroadcastStream().asBroadcastStream().map<Map<String, Object>>((element) => element.cast<String, Object>());

  StreamController<ProgressResult>? _receiveStream;
  StreamSubscription<Map<String, Object>>? _subscription;

  /// 获取上传进度流
  Stream<ProgressResult> onProgressResult() {
    if (_receiveStream == null) {
      _receiveStream = StreamController();
      _subscription = _onGetResult.listen((Map<String, Object> event) {
        Map<String, Object> newEvent = Map<String, Object>.of(event);
        _receiveStream?.add(ProgressResult.fromMap(newEvent));
      });
    }
    return _receiveStream!.stream;
  }

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<int?> uploadVideo(String signature, String videoPath,String customKey, {String? coverPath = ""}) async {
    _channel.invokeMethod('setCustomKey', {'customKey': customKey});
    var arguments = {};
    arguments['signature'] = signature;
    arguments['videoPath'] = videoPath;
    arguments['coverPath'] = coverPath;
    int publishCode = await _channel.invokeMethod('uploadVideo', arguments);
    return publishCode;
  }
}

class ProgressResult {
  final String method;
  final int? uploadBytes;
  final int? totalBytes;
  final int? retCode;
  final String? descMsg;
  final String? videoId;
  final String? videoURL;
  final String? coverURL;
  ProgressResult(this.uploadBytes, this.totalBytes, this.retCode, this.descMsg, this.videoId, this.videoURL, this.coverURL, {required this.method});
  factory ProgressResult.fromMap(Map<dynamic, dynamic> map) =>
      ProgressResult(map['uploadBytes'], map['totalBytes'], map['retCode'], map['descMsg'], map['videoId'], map['videoURL'], map['coverURL'],
          method: map['method']);

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['method'] = method;
    data['uploadBytes'] = uploadBytes;
    data['totalBytes'] = totalBytes;
    data['retCode'] = retCode;
    data['descMsg'] = descMsg;
    data['videoId'] = videoId;
    data['videoURL'] = videoURL;
    data['coverURL'] = coverURL;
    return data;
  }

}
