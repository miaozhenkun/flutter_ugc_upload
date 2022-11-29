#import "FlutterUgcUploadPlugin.h"
#import "TXUGCPublish.h"

@implementation FlutterUgcUploadPlugin{
    FlutterEventSink _eventSink;
    TXUGCPublish *_txUgcPublish;
    NSString *customKey;
}
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"flutter_ugc_upload"
            binaryMessenger:[registrar messenger]];
  FlutterUgcUploadPlugin* instance = [[FlutterUgcUploadPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
    
    FlutterEventChannel *eventChannel = [FlutterEventChannel eventChannelWithName:@"flutter_ugc_upload_stream" binaryMessenger:[registrar messenger]];
    [eventChannel setStreamHandler:instance];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"getPlatformVersion" isEqualToString:call.method]) {
    result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
  }else if ([@"setCustomKey" isEqualToString:call.method]) {
      [self setCustomKey:call result:result];
  } else if ([@"uploadVideo" isEqualToString:call.method]){
      [self uploadVideo : call result:result];
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (void)setCustomKey:(FlutterMethodCall*)call
              result:(FlutterResult)result
{
    NSString *customKey = call.arguments[@"customKey"];
    
    if (self->_txUgcPublish == nil || (customKey != nil && ![customKey isEqualToString:self->customKey])) {
        self->_txUgcPublish = [[TXUGCPublish alloc] initWithUserID:customKey];
        self->_txUgcPublish.delegate = (id)self;
    }

    self->customKey = customKey;
}


- (void) uploadVideo:(FlutterMethodCall*)call
              result:(FlutterResult)result {
    NSString *signature = call.arguments[@"signature"];
    NSString *videoPath = call.arguments[@"videoPath"];
    NSString *coverPath = call.arguments[@"coverPath"];
    
    TXPublishParam *publishParam = [[TXPublishParam alloc] init];
    publishParam.enableHTTPS  = true;
    publishParam.signature  = signature;
    publishParam.videoPath  = videoPath;
    if(![coverPath isEqual:@""]){
        publishParam.coverPath  = coverPath;
    }
    int ret = [_txUgcPublish publishVideo:publishParam];
    result([NSNumber numberWithInt:ret]);
    
}

#pragma mark - TXVideoPublishListener

- (void)onPublishProgress:(NSInteger)uploadBytes totalBytes:(NSInteger)totalBytes {
    //self.progressView.progress = (float)uploadBytes/totalBytes;
    NSDictionary<NSString *, id> *eventData = @{
                   @"uploadBytes": @(uploadBytes),
                   @"totalBytes": @(totalBytes),
                   @"method": @"publishProgress"
           
       };
    self->_eventSink(eventData);
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
    self->_eventSink(eventData);
}

- (FlutterError * _Nullable)onCancelWithArguments:(id _Nullable)arguments {
    _eventSink = nil;
    return nil;
}

- (FlutterError * _Nullable)onListenWithArguments:(id _Nullable)arguments eventSink:(nonnull FlutterEventSink)events {
    _eventSink = events;
    return nil;
}

@end
