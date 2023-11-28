//
//  EventInfo.h
//  MFSMonitorLibrary
//
//  Created by liuyi on 2023/11/9.
//

#import <Foundation/Foundation.h>
#import <EndpointSecurity/EndpointSecurity.h>

@interface ProcessInfo : NSObject

@property (nonatomic, retain) NSString *processName;
@property (nonatomic, retain) NSString *processPath;
@property (nonatomic, assign) pid_t pid;
@property (nonatomic, assign) pid_t ppid;
@property (nonatomic, assign) pid_t respid;

- (instancetype)initWithMessage:(es_process_t*)message;

@end

@interface EventInfo : NSObject

@property (nonatomic, assign) NSInteger index;
@property (nonatomic, retain) ProcessInfo *process;
@property (nonatomic, retain) NSString *sourcePath;
@property (nonatomic, retain) NSString *destPath;
@property (nonatomic, assign) es_event_type_t type;
@property (nonatomic, assign) NSDate *timestamp;

- (instancetype)initWithMessage:(const es_message_t*)message;

@end

