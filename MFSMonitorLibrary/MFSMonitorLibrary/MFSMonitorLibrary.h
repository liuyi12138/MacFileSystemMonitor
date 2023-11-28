//
//  MFSMonitorLibrary.h
//  MFSMonitorLibrary
//
//  Created by liuyi on 2023/11/9.
//

#import <Foundation/Foundation.h>
#import "EventInfo.h"

typedef void (^MFSCallbackBlock)(EventInfo*);

@interface MFSMonitorLibrary : NSObject

+ (instancetype)shareInstance;

- (BOOL)startMonitor:(es_event_type_t*)events
               count:(uint32_t)count
            callback:(MFSCallbackBlock)callback;

- (BOOL)stopMonitor;

@end
