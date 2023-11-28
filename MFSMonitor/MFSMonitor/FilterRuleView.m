//
//  FilterRuleView.m
//  MFSMonitor
//
//  Created by liuyi on 2023/11/22.
//

#import "FilterRuleView.h"
#import <Masonry/Masonry.h>

@implementation FilterComboBox

- (instancetype)initWithType:(ComboBoxType)type {
    self = [super init];
    if (self) {
        [self setEditable:NO];
        [self setSelectable:NO];
        _type = type;
        [self initItemWithType:type];
    }
    return self;
}

- (void)initItemWithType:(ComboBoxType)type {
    if (type == FILTER_BOX_SOURCE) {
        [self addItemWithObjectValue:@"SourcePath"];
        [self addItemWithObjectValue:@"DestPath"];
        [self addItemWithObjectValue:@"ProcessName"];
        [self addItemWithObjectValue:@"ProcessPath"];
        [self addItemWithObjectValue:@"ProcessPid"];
        [self addItemWithObjectValue:@"ProcessPpid"];
        [self addItemWithObjectValue:@"ProcessRespid"];
    } else if (type == FILTER_BOX_COMPARE) {
        [self addItemWithObjectValue:@"Equal"];
        [self addItemWithObjectValue:@"Not Equal"];
        [self addItemWithObjectValue:@"Contain"];
        [self addItemWithObjectValue:@"Not Contain"];
        [self addItemWithObjectValue:@"Prefix"];
        [self addItemWithObjectValue:@"Not Prefix"];
    }
}

@end

#pragma mark - FilterData

@implementation FilterData

- (instancetype)init {
    self = [super init];
    if (self) {
        self.index = unSelectedIndex;
        self.sourceSelectIndex = unSelectedIndex;
        self.compareSelectIndex = unSelectedIndex;
    }
    return self;
}

@end


#pragma mark - FilterRuleView

@interface FilterRuleView()

@property (nonatomic, retain) FilterComboBox *sourceComboBox;
@property (nonatomic, retain) FilterComboBox *compareComboBox;
@property (nonatomic, retain) NSTextField *valueText;
@property (nonatomic, retain) NSTextField *indexText;

@end

@implementation FilterRuleView

- (instancetype)init {
    self = [super init];
    if (self) {
        _indexText = [[NSTextField alloc] init];
        [_indexText setBordered:NO];
        [_indexText setSelectable:NO];
        [_indexText setEditable:NO];
        [_indexText setBackgroundColor:[NSColor clearColor]];
        [_indexText setFont:[NSFont systemFontOfSize:12]];
        [_indexText setStringValue:@"0"];
        [self addSubview:_indexText];
        [_indexText mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self).offset(12);
            make.width.equalTo(@15);
            make.height.equalTo(self);
            make.left.equalTo(self).offset(0);
        }];
        
        _sourceComboBox = [[FilterComboBox alloc] initWithType:FILTER_BOX_SOURCE];
        [self addSubview:_sourceComboBox];
        [_sourceComboBox mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.width.equalTo(@150);
            make.height.equalTo(self);
            make.left.equalTo(_indexText.mas_right).offset(10);
        }];
        
        _compareComboBox = [[FilterComboBox alloc] initWithType:FILTER_BOX_COMPARE];
        [self addSubview:_compareComboBox];
        [_compareComboBox mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.width.equalTo(@150);
            make.height.equalTo(@30);
            make.left.equalTo(_sourceComboBox.mas_right).offset(20);
        }];
        
        NSButton *deleteButton = [[NSButton alloc] init];
        NSImage *deleteImg = [NSImage imageNamed:@"delete"];
        [deleteImg setSize:NSMakeSize(18, 18)];
        [deleteButton setImage:deleteImg];
        [deleteButton setImagePosition:NSImageOnly];
        [deleteButton setBordered:NO];
        [deleteButton setRefusesFirstResponder:YES];
        [deleteButton setTarget:self];
        [deleteButton setAction:@selector(deleteFilterRule)];
        [self addSubview:deleteButton];
        [deleteButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@30);
            make.width.equalTo(@30);
            make.centerY.equalTo(self);
            make.right.equalTo(self).offset(-10);
        }];
        
        NSButton *addButton = [[NSButton alloc] init];
        NSImage *addImg = [NSImage imageNamed:@"add"];
        [addImg setSize:NSMakeSize(18, 18)];
        [addButton setImage:addImg];
        [addButton setImagePosition:NSImageOnly];
        [addButton setBordered:NO];
        [addButton setRefusesFirstResponder:YES];
        [addButton setTarget:self];
        [addButton setAction:@selector(addFilterRule)];
        [self addSubview:addButton];
        [addButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@30);
            make.width.equalTo(@30);
            make.centerY.equalTo(self);
            make.right.equalTo(deleteButton.mas_left).offset(-5);
        }];
        
        _valueText = [[NSTextField alloc] init];
        [_valueText setFont:[NSFont systemFontOfSize:13]];
        [_valueText setRefusesFirstResponder:YES];
        [self addSubview:_valueText];
        [_valueText mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@23);
            make.centerY.equalTo(self).offset(1);
            make.left.equalTo(_compareComboBox.mas_right).offset(20);
            make.right.equalTo(addButton.mas_left).offset(-15);
        }];
        
    }
    return self;
}

- (void)setSelectWithData:(FilterData *)data {
    if (!data || data.index == unSelectedIndex) {
        return;
    }
    _data = data;
    [_indexText setStringValue:[NSString stringWithFormat:@"%ld", data.index+1]];
    if (data.sourceSelectIndex != unSelectedIndex) {
        [_sourceComboBox selectItemAtIndex:data.sourceSelectIndex];
    }
    if (data.compareSelectIndex != unSelectedIndex) {
        [_compareComboBox selectItemAtIndex:data.compareSelectIndex];
    }
    if (data.value) {
        [_valueText setStringValue:data.value];
    }
}

- (void)updateData {
    FilterData *data = _data;
    if (_sourceComboBox.indexOfSelectedItem != NSNotFound) {
        data.sourceSelectIndex = _sourceComboBox.indexOfSelectedItem;
    } else {
        data.sourceSelectIndex = unSelectedIndex;
    }
    
    if (_compareComboBox.indexOfSelectedItem != NSNotFound) {
        data.compareSelectIndex = _compareComboBox.indexOfSelectedItem;
    } else {
        data.compareSelectIndex = unSelectedIndex;
    }
    
    data.value = _valueText.stringValue;
    _data = data;
}

- (void)addFilterRule {
    NSInteger index = _data.index;
    if (index == unSelectedIndex) {
        return;
    }
    if (_delegate) {
        [_delegate addFilter:index];
    }
}

- (void)deleteFilterRule {
    NSInteger index = _data.index;
    if (index == unSelectedIndex) {
        return;
    }
    if (_delegate) {
        [_delegate deleteFilter:index];
    }
}

@end
