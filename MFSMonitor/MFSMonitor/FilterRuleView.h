//
//  FilterRuleView.h
//  MFSMonitor
//
//  Created by liuyi on 2023/11/22.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

#define unSelectedIndex  -1

typedef enum {
    FILTER_BOX_SOURCE,
    FILTER_BOX_COMPARE
} ComboBoxType;

@interface FilterComboBox : NSComboBox

@property (nonatomic, assign) ComboBoxType type;

- (instancetype)initWithType:(ComboBoxType)type;

@end

@interface FilterData : NSObject

@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign) NSInteger sourceSelectIndex;
@property (nonatomic, assign) NSInteger compareSelectIndex;
@property (nonatomic, retain) NSString *value;

@end

@protocol FilterManagerDelegate <NSObject>

- (void)addFilter:(NSInteger)index;

- (void)deleteFilter:(NSInteger)index;

@end

@interface FilterRuleView : NSTableCellView

@property (nonatomic, retain) id<FilterManagerDelegate> delegate;
@property (nonatomic, retain) FilterData *data;

- (void)setSelectWithData:(FilterData *)data;

- (void)updateData;

@end


