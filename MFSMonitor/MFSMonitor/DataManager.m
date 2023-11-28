//
//  DataManager.m
//  MFSMonitor
//
//  Created by liuyi on 2023/11/13.
//

#import "DataManager.h"

@interface DataManager()

@property (nonatomic, retain) NSMutableArray<EventInfo *> *rawEvents;
@property (nonatomic, retain) NSMutableArray<EventInfo *> *filteredEvents;
@property (nonatomic, retain) EventFilter *filter;
@property (nonatomic, retain) NSArray<NSSortDescriptor *> *sortDescriptors;

@end

@implementation DataManager

static DataManager *instance = nil;
+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[DataManager alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.rawEvents = @[].mutableCopy;
        self.filteredEvents = @[].mutableCopy;
        self.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:YES]];
    }
    return self;
}

- (void)startMonitorEvents {
    es_event_type_t events[] = {ES_EVENT_TYPE_NOTIFY_CREATE, ES_EVENT_TYPE_NOTIFY_OPEN, ES_EVENT_TYPE_NOTIFY_WRITE, ES_EVENT_TYPE_NOTIFY_RENAME, ES_EVENT_TYPE_NOTIFY_LINK, ES_EVENT_TYPE_NOTIFY_UNLINK};

    __weak typeof(self) weakSelf = self;
    MFSCallbackBlock block = ^(EventInfo *event) {
        __strong typeof(self) strongSelf = weakSelf;
        @synchronized (self) {
            event.index = strongSelf.rawEvents.count+1;
            [strongSelf.rawEvents addObject:event];
            if (strongSelf.filter && [strongSelf.filter filterEvent:event]) {
                [strongSelf.filteredEvents addObject:event];
            }
        }
    };

    [[MFSMonitorLibrary shareInstance] startMonitor:events count:sizeof(events)/sizeof(events[0]) callback:block];
}

- (void)stopMonitorEvents {
    [[MFSMonitorLibrary shareInstance] stopMonitor];
}

- (void)clearEventsCache {
    @synchronized (self) {
        [_rawEvents removeAllObjects];
        [_filteredEvents removeAllObjects];
    }
}

- (void)setEventFilter:(EventFilter *)filter {
    _filter = filter;
    [self getFilteredEvent:YES];
}

- (NSArray<EventInfo *> *)getFilteredEvent:(BOOL)updateAll {
    if (!_filter) {
        return [_rawEvents sortedArrayUsingDescriptors:_sortDescriptors];
    }
    if (!updateAll) {
        return [_filteredEvents sortedArrayUsingDescriptors:_sortDescriptors];
    }
    NSMutableArray<EventInfo *> *tmpFilteredEvents = @[].mutableCopy;
    for (EventInfo *event in _rawEvents) {
        if ([_filter filterEvent:event]) {
            [tmpFilteredEvents addObject:event];
        }
    }
    _filteredEvents = tmpFilteredEvents.mutableCopy;
    return [_filteredEvents sortedArrayUsingDescriptors:_sortDescriptors];
}

- (void)setSortDescriptors:(NSArray<NSSortDescriptor *> *)sortDescriptors {
    _sortDescriptors = sortDescriptors;
}

@end
