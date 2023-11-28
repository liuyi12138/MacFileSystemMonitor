//
//  EventCellView.m
//  MFSMonitor
//
//  Created by liuyi on 2023/11/10.
//

#import "EventCellView.h"
#import <Masonry/Masonry.h>

@interface EventCellView()

@property (nonatomic, retain) NSTextField *textView;
@property (nonatomic, retain) NSDateFormatter *dateFormatter;

@end


@implementation EventCellView

- (instancetype)init{
    self = [super init];
    if (self) {
        self.dateFormatter = [[NSDateFormatter alloc] init];
        [self.dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];

        self.textView = [[NSTextField alloc] init];
        [self.textView setEditable:NO];
        [self.textView setBordered:NO];
        [self.textView setAlignment:NSTextAlignmentLeft];
        [self.textView setLineBreakMode:NSLineBreakByTruncatingMiddle];
//        [self.textView setFont:[NSFont fontWithName:@"PingFangSC-Medium" size:13]];
//        [self.textView setTextColor: [NSColor grayColor]];
        [self.textView setBackgroundColor:[NSColor clearColor]];
        [self addSubview:self.textView];
        [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(self);
            make.left.equalTo(self);
            make.height.equalTo(self);
            make.centerY.equalTo(self).offset(3);
        }];
    }
    return self;
}

- (void)setStringWithEvent:(EventInfo *)event identifier:(NSString *)identifier {
    NSString *valueStr;
    if ([identifier isEqualTo:EVENT_INDEX]) {
        valueStr = [NSString stringWithFormat:@"%ld", event.index];
    } else if ([identifier isEqualTo:EVENT_TIMESTAMP]) {
        valueStr = [_dateFormatter stringFromDate:event.timestamp];
    } else if ([identifier isEqualTo:EVENT_TYPE]) {
        switch (event.type) {
            case ES_EVENT_TYPE_NOTIFY_CREATE:
                valueStr = @"CREATE";
                break;
            case ES_EVENT_TYPE_NOTIFY_OPEN:
                valueStr = @"OPEN";
                break;
            case ES_EVENT_TYPE_NOTIFY_WRITE:
                valueStr = @"WRITE";
                break;
            case ES_EVENT_TYPE_NOTIFY_RENAME:
                valueStr = @"RENAME";
                break;
            case ES_EVENT_TYPE_NOTIFY_LINK:
                valueStr = @"LINK";
                break;
            case ES_EVENT_TYPE_NOTIFY_UNLINK:
                valueStr = @"UNLINK";
                break;
            default:
                valueStr = @"OTHER";
                break;
        }
    } else if ([identifier isEqualTo:EVENT_SOURCEPATH]) {
        valueStr = event.sourcePath;
    } else if ([identifier isEqualTo:EVENT_DESTPATH]) {
        valueStr = event.destPath;
    } else if ([identifier isEqualTo:EVENT_PROCEASS_PID]) {
        valueStr = [NSString stringWithFormat:@"%d", event.process.pid];
    } else if ([identifier isEqualTo:EVENT_PROCEASS_PPID]) {
        valueStr = [NSString stringWithFormat:@"%d", event.process.ppid];
    } else if ([identifier isEqualTo:EVENT_PROCEASS_RESPID]) {
        valueStr = [NSString stringWithFormat:@"%d", event.process.respid];
    } else if ([identifier isEqualTo:EVENT_PROCEASS_NAME]) {
        valueStr = event.process.processName;
    } else if ([identifier isEqualTo:EVENT_PROCEASS_PATH]) {
        valueStr = event.process.processPath;
    }
    if (!valueStr) {
        valueStr = @"";
    }
    [_textView setStringValue:valueStr];
}

@end
