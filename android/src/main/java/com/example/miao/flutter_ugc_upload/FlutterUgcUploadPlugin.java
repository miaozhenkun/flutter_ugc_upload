package com.example.miao.flutter_ugc_upload;

import android.content.Context;

import androidx.annotation.NonNull;

import com.example.miao.flutter_ugc_upload.videoupload.TXUGCPublish;
import com.example.miao.flutter_ugc_upload.videoupload.TXUGCPublishTypeDef;

import java.util.HashMap;
import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/** FlutterUgcUploadPlugin */
public class FlutterUgcUploadPlugin implements FlutterPlugin, MethodCallHandler, EventChannel.StreamHandler {

  private MethodChannel channel;
  private static Context mContext;
  private EventChannel eventChannel;
  public static EventChannel.EventSink mEventSink = null;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    if (null == mContext) {
      mContext = flutterPluginBinding.getApplicationContext();
    }
    /**
     * 方法调用通道
     */
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "flutter_ugc_upload");
    channel.setMethodCallHandler(this);
    /**
     * 回调监听通道
     */
    eventChannel = new EventChannel(flutterPluginBinding.getBinaryMessenger(), "flutter_ugc_upload_stream");
    eventChannel.setStreamHandler(this);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    if (call.method.equals("getPlatformVersion")) {
      result.success("Android " + android.os.Build.VERSION.RELEASE);
    } else if(call.method.equals("uploadVideo")){
      uploadVideo(call,result);
    } else {
      result.notImplemented();
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }

  private void uploadVideo(MethodCall call, Result result){
    TXUGCPublish mVideoPublish = new TXUGCPublish(mContext, "independence_android");
    mVideoPublish.setListener(new TXUGCPublishTypeDef.ITXVideoPublishListener() {
      @Override
      public void onPublishProgress(long uploadBytes, long totalBytes) {
        Map map =new HashMap();
        map.put("uploadBytes", uploadBytes);
        map.put("totalBytes",  totalBytes);
        map.put("method",  "publishProgress");
        mEventSink.success(map);
      }

      @Override
      public void onPublishComplete(TXUGCPublishTypeDef.TXPublishResult res) {
        Map map = new HashMap();
        map.put("method",  "publishComplete");
        map.put("retCode",res.retCode);
        map.put("descMsg",res.descMsg);
        map.put("videoId",res.videoId);
        map.put("videoURL",res.videoURL);
        map.put("coverURL",res.coverURL);
        mEventSink.success(map);
      }
    });
    TXUGCPublishTypeDef.TXPublishParam param = new TXUGCPublishTypeDef.TXPublishParam();
    param.enableHttps = true;
    param.signature = call.argument("signature");
    param.videoPath = call.argument("videoPath");
    if(call.argument("coverPath")!= "") {
      param.coverPath = call.argument("coverPath");
    }
    int publishCode = mVideoPublish.publishVideo(param);
    result.success(publishCode);
  }

  @Override
  public void onListen(Object arguments, EventChannel.EventSink events) {
    mEventSink = events;
  }

  @Override
  public void onCancel(Object arguments) {
    mEventSink.endOfStream();
  }
}
