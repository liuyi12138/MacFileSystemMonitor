//
//  EventInfo.m
//  MFSMonitorLibrary
//
//  Created by liuyi on 2023/11/9.
//

#import "EventInfo.h"
#import <bsm/libbsm.h>

extern "C" pid_t responsibility_get_pid_responsible_for_pid(pid_t);
NSString* convertStringToken(es_string_token_t* stringToken);

@implementation EventInfo

- (instancetype)initWithMessage:(const es_message_t*)message {
    self = [super init];
    if (self) {
        self.index = 0;
        self.type = message->event_type;
        self.timestamp = [NSDate date];
        self.process = [[ProcessInfo alloc] initWithMessage:message->process];
        [self extractPaths:message];
    }
    return self;
}

- (void)extractPaths:(const es_message_t*)message {
    switch (message->event_type) {
        case ES_EVENT_TYPE_NOTIFY_CREATE: {
            if(message->event.create.destination_type == ES_DESTINATION_TYPE_EXISTING_FILE) {
                self.destPath = convertStringToken(&message->event.create.destination.existing_file->path);
            } else {
                NSString *directory = convertStringToken(&message->event.create.destination.new_path.dir->path);
                NSString *fileName = convertStringToken((es_string_token_t*)&message->event.create.destination.new_path.filename);
                self.destPath = [directory stringByAppendingPathComponent:fileName];
            }
            
            break;
        }
        case ES_EVENT_TYPE_NOTIFY_OPEN:
            self.destPath = convertStringToken(&message->event.open.file->path);
            break;
        case ES_EVENT_TYPE_NOTIFY_WRITE:
            self.destPath = convertStringToken(&message->event.write.target->path);
            break;
        case ES_EVENT_TYPE_NOTIFY_CLOSE:
            self.destPath = convertStringToken(&message->event.close.target->path);
            break;
        case ES_EVENT_TYPE_NOTIFY_LINK:
            self.sourcePath = convertStringToken(&message->event.link.source->path);
            self.destPath = [convertStringToken(&message->event.link.target_dir->path) stringByAppendingPathComponent:convertStringToken((es_string_token_t*)&message->event.link.target_filename)];
            break;
        case ES_EVENT_TYPE_NOTIFY_RENAME:
            self.sourcePath = convertStringToken(&message->event.rename.source->path);
            if(message->event.rename.destination_type == ES_DESTINATION_TYPE_EXISTING_FILE) {
                self.destPath = convertStringToken(&message->event.rename.destination.existing_file->path);
            } else {
                self.destPath = [convertStringToken(&message->event.rename.destination.new_path.dir->path) stringByAppendingPathComponent:convertStringToken((es_string_token_t*)&message->event.rename.destination.new_path.filename)];
            }
            break;
        case ES_EVENT_TYPE_NOTIFY_UNLINK:
            self.destPath = convertStringToken(&message->event.unlink.target->path);
            break;
        default:
            break;
    }
    
    return;
}

@end


@implementation ProcessInfo

- (instancetype)initWithMessage:(es_process_t*)message {
    self = [super init];
    if (self) {
        self.pid = audit_token_to_pid(message->audit_token);
        self.ppid = message->ppid;
        self.respid = responsibility_get_pid_responsible_for_pid(self.pid);
        
        self.processPath = convertStringToken(&message->executable->path);
        self.processName = [self.processPath lastPathComponent];
    }
    return self;
}


@end

#pragma mark - utils

NSString* convertStringToken(es_string_token_t* stringToken) {
    NSString* string = nil;
    
    if (stringToken == NULL ||
        stringToken->data == NULL ||
        stringToken->length <= 0) {
        return string;
    }
    
    string = [[NSString alloc] initWithBytes:stringToken->data length:stringToken->length encoding:NSUTF8StringEncoding];
    
    return string;
}
