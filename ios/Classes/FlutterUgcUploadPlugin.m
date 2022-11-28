#import "FlutterUgcUploadPlugin.h"
#import "FlutterUgcUploadPluginStream.h"
#import "TXUGCPublish.h"

@implementation FlutterUgcUploadPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"flutter_ugc_upload"
            binaryMessenger:[registrar messenger]];
  FlutterUgcUploadPlugin* instance = [[FlutterUgcUploadPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
    
    FlutterEventChannel *eventChanel = [FlutterEventChannel eventChannelWithName:@"flutter_ugc_upload_stream" binaryMessenger:[registrar messenger]];
      [eventChanel setStreamHandler:[[FlutterUgcUploadPluginStream sharedInstance] streamHandler]];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"getPlatformVersion" isEqualToString:call.method]) {
    result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
  }else if ([@"uploadVideo" isEqualToString:call.method]){
      [self uploadVideo : call result:result];
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (void) uploadVideo:(FlutterMethodCall*)call
              result:(FlutterResult)result {
    
    NSLog(@"执行了uploadVideo 方法");
    NSString *signature = call.arguments[@"signature"];
    NSString *videoPath = call.arguments[@"videoPath"];
    NSString *coverPath = call.arguments[@"coverPath"];
    TXUGCPublish *_videoPublish = [[TXUGCPublish alloc] initWithUserID:@"independence_ios"];
    _videoPublish.delegate = (id)self;
    TXPublishParam *publishParam = [[TXPublishParam alloc] init];
    publishParam.signature  = signature;
    publishParam.videoPath  = videoPath;
    if(![coverPath isEqual:@""]){
        publishParam.coverPath  = coverPath;
    }
    [_videoPublish publishVideo:publishParam];
    
}

#pragma mark - TXVideoPublishListener

- (void)onPublishProgress:(NSInteger)uploadBytes totalBytes:(NSInteger)totalBytes {
    //self.progressView.progress = (float)uploadBytes/totalBytes;
    NSDictionary<NSString *, id> *eventData = @{
                   @"uploadBytes": @(uploadBytes),
                   @"totalBytes": @(totalBytes),
                   @"method": @"publishProgress"
           
       };
    [[FlutterUgcUploadPluginStream sharedInstance] streamHandler].eventSink(eventData);
}

- (void)onPublishComplete:(TXPublishResult*)res {
    //NSString *string = [NSString stringWithFormat:@"上传完成，错误码[%d]，信息[%@]", res.retCode, res.retCode == 0? res.videoURL: res.descMsg];
    NSDictionary<NSString *, id> *eventData =  @{
                           @"retCode": @(res.retCode),
                           @"descMsg": res.descMsg != nil ? res.descMsg : @"",
                           @"videoId": res.videoId != nil ? res.videoId : @"",
                           @"videoURL": res.videoURL != nil ? res.videoURL : @"",
                           @"coverURL": res.coverURL != nil ? res.coverURL : @"",
                           @"method": @"publishComplete"
       };
    [[FlutterUgcUploadPluginStream sharedInstance] streamHandler].eventSink(eventData);
}

@end
