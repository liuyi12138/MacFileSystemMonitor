//
//  DataManager.h
//  MFSMonitor
//
//  Created by liuyi on 2023/11/13.
//

#import <Foundation/Foundation.h>
#import "EventFilter.h"
#import "MFSMonitorLibrary.h"

@interface DataManager : NSObject

+ (instancetype)shareInstance;

- (void)startMonitorEvents;

- (void)stopMonitorEvents;

- (void)clearEventsCache;

- (void)setEventFilter:(EventFilter *)filter;

- (NSArray<EventInfo *> *)getFilteredEvent:(BOOL)updateAll;

- (void)setSortDescriptors:(NSArray<NSSortDescriptor *> *)sortDescriptors;

@end
