//
//  FlutterUgcUploadPluginStream.h
//  Pods
//
//  Created by miao on 2022/11/28.
//
#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>

NS_ASSUME_NONNULL_BEGIN
@class FlutterUgcUploadPluginStreamHandler;
@interface FlutterUgcUploadPluginStream : NSObject
+ (instancetype)sharedInstance ;
@property (nonatomic, strong) FlutterUgcUploadPluginStreamHandler* streamHandler;

@end

@interface FlutterUgcUploadPluginStreamHandler : NSObject<FlutterStreamHandler>
@property (nonatomic, strong,nullable) FlutterEventSink eventSink;

@end
NS_ASSUME_NONNULL_END
