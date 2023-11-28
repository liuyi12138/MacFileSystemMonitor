//
//  EventFilter.h
//  MFSMonitor
//
//  Created by liuyi on 2023/11/10.
//

#import <Foundation/Foundation.h>
#import "MFSMonitorLibrary.h"

typedef enum  {
    ORI_TYPE_SOURCE_PATH,
    ORI_TYPE_DEST_PATH,
    ORI_TYPE_PROCESS_NAME,
    ORI_TYPE_PROCESS_PATH,
    ORI_TYPE_PROCESS_PID,
    ORI_TYPE_PROCESS_PPID,
    ORI_TYPE_PROCESS_RESPID,
} ORI_TYPE;

typedef enum {
    COMPARE_TYPE_EQUAL,
    COMPARE_TYPE_NOT_EQUAL,
    COMPARE_TYPE_CONTAIN,
    COMPARE_TYPE_NOT_CONTAIN,
    COMPARE_TYPE_PREFIX,
    COMPARE_TYPE_NOT_PREFIX,
} COMPARE_TYPE;

@interface FilterRule : NSObject

@property (nonatomic, assign) ORI_TYPE oriType;
@property (nonatomic, assign) COMPARE_TYPE compareType;
@property (nonatomic, assign) NSString *value;

- (instancetype)initRule:(ORI_TYPE)oriType
             compareType:(COMPARE_TYPE)compareType
                   value:(NSString *)value;

- (BOOL)isRuleValid;

@end

typedef enum {
    FILTER_MODE_ALL_MATCH,
    FILTER_MODE_ANY_MATCH,
} FilterMode;


@interface EventFilter : NSObject

//@property (nonatomic, assign) es_event_type_t eventType;
@property (nonatomic, assign) FilterMode mode;
@property (nonatomic, retain) NSArray<FilterRule *> *rules;

- (BOOL)addFilterRule:(FilterRule *)rule;

- (BOOL)removeFilterRule:(int)index;

- (BOOL)filterEvent:(EventInfo *)event;

@end

