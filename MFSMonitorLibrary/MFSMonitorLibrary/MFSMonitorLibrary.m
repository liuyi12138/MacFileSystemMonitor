//
//  MFSMonitorLibrary.m
//  MFSMonitorLibrary
//
//  Created by liuyi on 2023/11/9.
//

#import "MFSMonitorLibrary.h"

@interface MFSMonitorLibrary()

@property (nonatomic, assign) es_client_t* endpointClient;
@property (nonatomic, assign) BOOL started;

@end

@implementation MFSMonitorLibrary

static MFSMonitorLibrary *instance = nil;
+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[MFSMonitorLibrary alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.endpointClient = nil;
        self.started = NO;
    }
    return self;
}

- (BOOL)startMonitor:(es_event_type_t*)events
               count:(uint32_t)count
            callback:(MFSCallbackBlock)callback {
    
    
    es_new_client_result_t result = 0;
    result = es_new_client(&_endpointClient, ^(es_client_t *client, const es_message_t *message) {
        EventInfo *event = [[EventInfo alloc] initWithMessage:message];
        if (event) {
            callback(event);
        }
    });
    
    if (result != ES_NEW_CLIENT_RESULT_SUCCESS) {
        NSLog(@"new es_client failed, result:%d", result);
        return NO;
    }
    
    if (es_clear_cache(_endpointClient) != ES_CLEAR_CACHE_RESULT_SUCCESS) {
        NSLog(@"es_client clear vavhe failed!");
        return NO;
    }
    
    if (es_subscribe(_endpointClient, events, count) != ES_RETURN_SUCCESS) {
        NSLog(@"es_subscribe failed!");
        return NO;
    }
    
    
    
    _started = YES;
    return YES;
}

- (BOOL)stopMonitor {
    do {
        if (!_started) {
            break;
        }
        if (!_endpointClient) {
            break;
        }
        if (es_unsubscribe_all(_endpointClient) != ES_RETURN_SUCCESS) {
            NSLog(@"endpoint security unsubscribe all failed!");
            break;
        }
        if(es_delete_client(_endpointClient) != ES_RETURN_SUCCESS) {
            NSLog(@"delete endpoint security client failed!");
            break;
        }
        _endpointClient = NULL;
        _started = NO;
    } while(0);
    
    return !_started;
}

@end

