//
//  EventFilter.m
//  MFSMonitor
//
//  Created by liuyi on 2023/11/10.
//

#import "EventFilter.h"

@implementation FilterRule

- (instancetype)initRule:(ORI_TYPE)oriType
             compareType:(COMPARE_TYPE)compareType
                   value:(NSString *)value {
    self = [super init];
    if (self) {
        self.oriType = oriType;
        self.compareType = compareType;
        self.value = value;
    }
    return self;
}

- (BOOL)isRuleValid {
    if (_oriType == ORI_TYPE_PROCESS_PID ||
        _oriType == ORI_TYPE_PROCESS_PPID ||
        _oriType == ORI_TYPE_PROCESS_RESPID) {
        if (_compareType !=COMPARE_TYPE_EQUAL && _compareType != COMPARE_TYPE_NOT_EQUAL) {
            return NO;
        }
        int intValue = [_value intValue];
        if (!_value && _value.length > 0 && intValue == 0) {
            return NO;
        }
        
    }
    return YES;
}

@end

@implementation EventFilter

- (instancetype)init {
    self = [super init];
    if (self) {
        self.rules = @[];
        self.mode = FILTER_MODE_ALL_MATCH;
    }
    return self;
}

- (BOOL)addFilterRule:(FilterRule *)rule {
    if (![rule isRuleValid]) {
        return NO;
    }
    NSMutableArray *newRules = _rules.mutableCopy;
    [newRules addObject:rule];
    _rules = newRules.copy;
    return YES;
}

- (BOOL)removeFilterRule:(int)index {
    NSMutableArray *newRules = _rules.mutableCopy;
    if (newRules.count <= index) {
        return NO;
    }
    [newRules removeObjectAtIndex:index];
    _rules = newRules.copy;
    return YES;
}


- (BOOL)filterEvent:(EventInfo *)event {
    for (FilterRule *rule in _rules) {
        NSString *eventValue = @"";
        switch (rule.oriType) {
            case ORI_TYPE_SOURCE_PATH:
                eventValue = event.sourcePath;
                break;
            case ORI_TYPE_DEST_PATH:
                eventValue = event.destPath;
                break;
            case ORI_TYPE_PROCESS_NAME:
                eventValue = event.process.processName;
                break;
            case ORI_TYPE_PROCESS_PATH:
                eventValue = event.process.processPath;
                break;
            case ORI_TYPE_PROCESS_PID:
                eventValue = [NSString stringWithFormat:@"%d", event.process.pid];
                break;
            case ORI_TYPE_PROCESS_PPID:
                eventValue = [NSString stringWithFormat:@"%d", event.process.ppid];
                break;
            case ORI_TYPE_PROCESS_RESPID:
                eventValue = [NSString stringWithFormat:@"%d", event.process.respid];
                break;
        }
        
        BOOL compareResult = NO;
        switch (rule.compareType) {
            case COMPARE_TYPE_EQUAL: {
                compareResult = [eventValue isEqualTo:rule.value];
                break;
            }
            case COMPARE_TYPE_NOT_EQUAL: {
                compareResult = ![eventValue isEqualTo:rule.value];
                break;
            }
            case COMPARE_TYPE_CONTAIN: {
                compareResult = [eventValue containsString:rule.value];
                break;
            }
            case COMPARE_TYPE_NOT_CONTAIN: {
                compareResult = ![eventValue containsString:rule.value];
                break;
            }
            case COMPARE_TYPE_PREFIX: {
                compareResult = [eventValue hasPrefix:rule.value];
                break;
            }
            case COMPARE_TYPE_NOT_PREFIX: {
                compareResult = ![eventValue hasPrefix:rule.value];
                break;
            }
        }
        
        if (_mode == FILTER_MODE_ANY_MATCH && compareResult) {
            return YES;
        } else if (_mode == FILTER_MODE_ALL_MATCH && !compareResult) {
            return NO;
        }
    }
    return (_mode == FILTER_MODE_ALL_MATCH);
}

@end
