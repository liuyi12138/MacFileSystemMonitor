//
//  EventCellView.h
//  MFSMonitor
//
//  Created by liuyi on 2023/11/10.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "MFSMonitorLibrary.h"

#define EVENT_INDEX                 @"Index"
#define EVENT_TIMESTAMP             @"Time"
#define EVENT_TYPE                  @"EventType"
#define EVENT_SOURCEPATH            @"SourcePath"
#define EVENT_DESTPATH              @"DestPath"
#define EVENT_PROCEASS_PID          @"PID"
#define EVENT_PROCEASS_PPID         @"PPID"
#define EVENT_PROCEASS_RESPID       @"ResPid"
#define EVENT_PROCEASS_NAME         @"ProcessName"
#define EVENT_PROCEASS_PATH         @"ProcessPath"

@interface EventCellView : NSTableCellView

- (void)setStringWithEvent:(EventInfo *)event identifier:(NSString *)identifier;

@end

