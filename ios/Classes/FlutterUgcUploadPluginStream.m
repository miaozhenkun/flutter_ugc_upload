//
//  FlutterUgcUploadPluginStream.m
//  AFNetworking
//
//  Created by chen on 2022/11/28.
//
#import "FlutterUgcUploadPluginStream.h"

@implementation FlutterUgcUploadPluginStream

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static FlutterUgcUploadPluginStream *manager = nil;
    dispatch_once(&onceToken, ^{
        manager = [[FlutterUgcUploadPluginStream alloc] init];
        FlutterUgcUploadPluginStreamHandler * streamHandler = [[FlutterUgcUploadPluginStreamHandler alloc] init];
        manager.streamHandler = streamHandler;
    });
    
    return manager;
}

@end

@implementation FlutterUgcUploadPluginStreamHandler

- (FlutterError*)onListenWithArguments:(id)arguments eventSink:(FlutterEventSink)eventSink {
    self.eventSink = eventSink;
    return nil;
}

- (FlutterError*)onCancelWithArguments:(id)arguments {
    self.eventSink = nil;
    return nil;
}

@end
