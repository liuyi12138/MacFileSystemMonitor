//
//  ViewController.m
//  MFSMonitor
//
//  Created by liuyi on 2023/11/9.
//

#import "ViewController.h"
#import "DataManager.h"
#import "EventCellView.h"
#import <Masonry/Masonry.h>

#define eventTableTag           1
#define filterTableTag          2

@interface ViewController()

@property (nonatomic, retain) NSTableView *eventTableView;
@property (nonatomic, retain) NSArray<EventInfo *> *events;
@property (nonatomic, strong) NSTimer *updateTimer;
@property (nonatomic, assign) NSInteger selectedEventIndex;

@property (nonatomic, retain) NSMutableArray<NSString *> *showCols;
@property (nonatomic, retain) NSDictionary<NSString *, NSTableColumn *> *tableCols;

@property (nonatomic, retain) NSTableView *filterTableView;
@property (nonatomic, retain) NSComboBox *filterModeBox;
@property (nonatomic, retain) NSMutableArray<FilterData *> *filterRulesData;

@property (nonatomic, retain) NSButton *startButton;
@property (nonatomic, assign) BOOL isMoniting;

@property (nonatomic, retain) NSTextField *totalText;
@property (nonatomic, strong) MASConstraint *scrollViewHeightConstraint;

@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initButton];
    [self initFilterRuleTableView];
    [self initEventTableView];
    [self initText];
    
    _selectedEventIndex = unSelectedIndex;
    _isMoniting = NO;
    if (!_updateTimer) {
        _updateTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateEvents:) userInfo:nil repeats:YES];
    }
}

- (void)initButton {
    _startButton = [[NSButton alloc] init];
    [_startButton setTitle:@"  开始"];
    NSImage *startImg = [NSImage imageNamed:@"start"];
    [startImg setSize:NSMakeSize(20, 20)];
    [_startButton setImage:startImg];
    [_startButton setImagePosition:NSImageLeft];
    [_startButton setBordered:NO];
    [_startButton setRefusesFirstResponder:YES];
    [_startButton setTarget:self];
    [_startButton setAction:@selector(startMonitor)];
    [self.view addSubview:_startButton];
    [_startButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@30);
        make.width.equalTo(@60);
        make.top.equalTo(self.view).offset(5);
        make.left.equalTo(self.view).offset(20);
    }];
    
    NSButton *clearButton = [[NSButton alloc] init];
    [clearButton setTitle:@"  清除"];
    NSImage *clearImg = [NSImage imageNamed:@"clear"];
    [clearImg setSize:NSMakeSize(20, 20)];
    [clearButton setImage:clearImg];
    [clearButton setImagePosition:NSImageLeft];
    [clearButton setBordered:NO];
    [clearButton setRefusesFirstResponder:YES];
    [clearButton setTarget:self];
    [clearButton setAction:@selector(clearEvents)];
    [self.view addSubview:clearButton];
    [clearButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@30);
        make.width.equalTo(@60);
        make.top.equalTo(_startButton);
        make.left.equalTo(_startButton.mas_right).offset(20);
    }];
    
    NSButton *filterButton = [[NSButton alloc] init];
    [filterButton setTitle:@"  筛选"];
    NSImage *filterImg = [NSImage imageNamed:@"filter"];
    [filterImg setSize:NSMakeSize(16, 16)];
    [filterButton setImage:filterImg];
    [filterButton setImagePosition:NSImageLeft];
    [filterButton setBordered:NO];
    [filterButton setRefusesFirstResponder:YES];
    [filterButton setTarget:self];
    [filterButton setAction:@selector(filterEvents)];
    [self.view addSubview:filterButton];
    [filterButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@30);
        make.width.equalTo(@60);
        make.centerY.equalTo(clearButton);
        make.left.equalTo(clearButton.mas_right).offset(20);
    }];
    
    _filterModeBox = [[NSComboBox alloc] init];
    [_filterModeBox setEditable:NO];
    [_filterModeBox setSelectable:NO];
    [_filterModeBox addItemWithObjectValue:@"Match All Rules"];
    [_filterModeBox addItemWithObjectValue:@"Match One Rule"];
    [_filterModeBox selectItemAtIndex:0];
    [self.view addSubview:_filterModeBox];
    [_filterModeBox mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@30);
        make.width.equalTo(@120);
        make.centerY.equalTo(filterButton);
        make.left.equalTo(filterButton.mas_right).offset(20);
    }];
    
}

- (void)initFilterRuleTableView {
    FilterData *defaultData = [[FilterData alloc] init];
    defaultData.index = 0;
    _filterRulesData = @[defaultData].mutableCopy;
    
    _filterTableView = [[NSTableView alloc] init];
    [_filterTableView setTag:filterTableTag];
    [_filterTableView setDataSource:self];
    [_filterTableView setDelegate:self];
    [_filterTableView setBackgroundColor:[NSColor clearColor]];
    [_filterTableView setHeaderView: nil];
    
    NSTableColumn *filterCol = [[NSTableColumn alloc] initWithIdentifier:@"filter"];
    [_filterTableView addTableColumn:filterCol];
    
    NSScrollView *scrollView = [[NSScrollView alloc] init];
    [scrollView setBorderType:NSNoBorder];
    [scrollView setHasVerticalScroller:YES];
    [scrollView setHasHorizontalScroller:NO];
    [scrollView setAutohidesScrollers:NO];
    [scrollView setAutomaticallyAdjustsContentInsets:YES];
    [scrollView setDocumentView:_filterTableView];
    CGFloat scrollViewHeight = 60.0;
    [self.view addSubview:scrollView];
    [scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        _scrollViewHeightConstraint = make.height.mas_equalTo(scrollViewHeight);
        make.width.equalTo(self.view);
        make.top.equalTo(self.view).offset(60);
    }];
    
}

- (void)initEventTableView {
    _showCols = @[EVENT_INDEX, EVENT_TIMESTAMP, EVENT_TYPE, EVENT_PROCEASS_PID, EVENT_PROCEASS_NAME, EVENT_DESTPATH].mutableCopy;
    
    NSMenu *colMenu = [[NSMenu alloc] init];
    NSArray<NSString *> *allCol = @[EVENT_INDEX, EVENT_TIMESTAMP, EVENT_TYPE, EVENT_PROCEASS_PID, EVENT_PROCEASS_PPID, EVENT_PROCEASS_RESPID, EVENT_PROCEASS_NAME, EVENT_PROCEASS_PATH, EVENT_SOURCEPATH, EVENT_DESTPATH];
    for (NSString *col in allCol) {
        NSString *showStr = col;
        if ([_showCols containsObject:col]) {
            showStr = [NSString stringWithFormat:@"✓  %@", col];
        } else {
            showStr = [NSString stringWithFormat:@"     %@", col];
        }
        NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:showStr action:@selector(changeShowCol:) keyEquivalent:@""];
        [item setRepresentedObject:col];
        [colMenu addItem:item];
    }

    _eventTableView = [[NSTableView alloc] init];
    [_eventTableView.headerView setMenu:colMenu];
    [_eventTableView setTag:eventTableTag];
    [_eventTableView setDataSource:self];
    [_eventTableView setDelegate:self];
    [_eventTableView setUsesAlternatingRowBackgroundColors:YES];
    [_eventTableView setAllowsMultipleSelection:NO];
    [_eventTableView setDoubleAction:@selector(doubleClickRow:)];
    
    NSTableColumn *indexCol = [[NSTableColumn alloc] initWithIdentifier:EVENT_INDEX];
    [indexCol setTitle:EVENT_INDEX];
    [indexCol setWidth:50];
    [indexCol setMinWidth:50];
    [indexCol setMaxWidth:50];
    [indexCol setSortDescriptorPrototype:[[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:NO]];
    [_eventTableView addTableColumn:indexCol];
    
    NSTableColumn *timeCol = [[NSTableColumn alloc] initWithIdentifier:EVENT_TIMESTAMP];
    [timeCol setTitle:EVENT_TIMESTAMP];
    [timeCol setWidth:160];
    [timeCol setMinWidth:160];
    [timeCol setMaxWidth:160];
    [timeCol setSortDescriptorPrototype:[[NSSortDescriptor alloc] initWithKey:@"index" ascending:NO]];
    [_eventTableView addTableColumn:timeCol];

    NSTableColumn *typeCol = [[NSTableColumn alloc] initWithIdentifier:EVENT_TYPE];
    [typeCol setTitle:EVENT_TYPE];
    [typeCol setWidth:80];
    [typeCol setMinWidth:80];
    [typeCol setMaxWidth:80];
    [typeCol setSortDescriptorPrototype:[[NSSortDescriptor alloc] initWithKey:@"type" ascending:YES]];
    [_eventTableView addTableColumn:typeCol];
    
    NSTableColumn *pidCol = [[NSTableColumn alloc] initWithIdentifier:EVENT_PROCEASS_PID];
    [pidCol setTitle:EVENT_PROCEASS_PID];
    [pidCol setWidth:50];
    [pidCol setMinWidth:50];
    [pidCol setMaxWidth:50];
    [pidCol setSortDescriptorPrototype:[[NSSortDescriptor alloc] initWithKey:@"process.pid" ascending:YES]];
    [_eventTableView addTableColumn:pidCol];
    
    NSTableColumn *ppidCol = [[NSTableColumn alloc] initWithIdentifier:EVENT_PROCEASS_PPID];
    [ppidCol setTitle:EVENT_PROCEASS_PPID];
    [ppidCol setWidth:50];
    [ppidCol setMinWidth:50];
    [ppidCol setMaxWidth:50];
    [ppidCol setSortDescriptorPrototype:[[NSSortDescriptor alloc] initWithKey:@"process.ppid" ascending:YES]];
    [_eventTableView addTableColumn:ppidCol];
    
    NSTableColumn *respidCol = [[NSTableColumn alloc] initWithIdentifier:EVENT_PROCEASS_RESPID];
    [respidCol setTitle:EVENT_PROCEASS_RESPID];
    [respidCol setWidth:60];
    [respidCol setMinWidth:60];
    [respidCol setMaxWidth:60];
    [respidCol setSortDescriptorPrototype:[[NSSortDescriptor alloc] initWithKey:@"process.respid" ascending:YES]];
    [_eventTableView addTableColumn:respidCol];

    NSTableColumn *processNameCol = [[NSTableColumn alloc] initWithIdentifier:EVENT_PROCEASS_NAME];
    [processNameCol setTitle:EVENT_PROCEASS_NAME];
    [processNameCol setWidth:100];
    [processNameCol setMinWidth:40];
    [processNameCol setMaxWidth:150];
    [processNameCol setSortDescriptorPrototype:[[NSSortDescriptor alloc] initWithKey:@"process.processName" ascending:YES]];
    [_eventTableView addTableColumn:processNameCol];
    
    NSTableColumn *processPathCol = [[NSTableColumn alloc] initWithIdentifier:EVENT_PROCEASS_PATH];
    [processPathCol setTitle:EVENT_PROCEASS_PATH];
    [processPathCol setWidth:200];
    [processPathCol setMinWidth:100];
    [processPathCol setSortDescriptorPrototype:[[NSSortDescriptor alloc] initWithKey:@"process.processPath" ascending:YES]];
    [_eventTableView addTableColumn:processPathCol];
    
    NSTableColumn *sourcePathCol = [[NSTableColumn alloc] initWithIdentifier:EVENT_SOURCEPATH];
    [sourcePathCol setTitle:EVENT_SOURCEPATH];
    [sourcePathCol setWidth:300];
    [sourcePathCol setMinWidth:100];
    [sourcePathCol setSortDescriptorPrototype:[[NSSortDescriptor alloc] initWithKey:@"sourcePath" ascending:YES]];
    [_eventTableView addTableColumn:sourcePathCol];
    
    NSTableColumn *destPathCol = [[NSTableColumn alloc] initWithIdentifier:EVENT_DESTPATH];
    [destPathCol setTitle:EVENT_DESTPATH];
    [destPathCol setWidth:300];
    [destPathCol setMinWidth:100];
    [destPathCol setSortDescriptorPrototype:[[NSSortDescriptor alloc] initWithKey:@"destPath" ascending:YES]];
    [_eventTableView addTableColumn:destPathCol];
    
    _tableCols = @{
        EVENT_INDEX : indexCol,
        EVENT_TIMESTAMP : timeCol,
        EVENT_TYPE : typeCol,
        EVENT_SOURCEPATH : sourcePathCol,
        EVENT_DESTPATH : destPathCol,
        EVENT_PROCEASS_PID : pidCol,
        EVENT_PROCEASS_PPID : ppidCol,
        EVENT_PROCEASS_RESPID : respidCol,
        EVENT_PROCEASS_NAME : processNameCol,
        EVENT_PROCEASS_PATH : processPathCol
    };
    
    for (NSString *col in allCol) {
        if (![_showCols containsObject:col]) {
            [_tableCols[col] setHidden:YES];
        }
    }

    NSScrollView *scrollView = [[NSScrollView alloc] init];
    [scrollView setBorderType:NSNoBorder];
    [scrollView setHasVerticalScroller:YES];
    [scrollView setHasHorizontalScroller:YES];
    [scrollView setAutohidesScrollers:NO];
    [scrollView setDocumentView:_eventTableView];
    [self.view addSubview:scrollView];
    [scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.view);
        make.bottom.equalTo(self.view);
        make.top.equalTo(_filterTableView.mas_bottom).offset(25);
    }];
}

- (void)initText {
    _totalText = [[NSTextField alloc] init];
    [_totalText setBordered:NO];
    [_totalText setSelectable:NO];
    [_totalText setEditable:NO];
    [_totalText setBackgroundColor:[NSColor clearColor]];
    [_totalText setFont:[NSFont systemFontOfSize:12]];
    [_totalText setStringValue:@"0 messages"];
    [self.view addSubview:_totalText];
    [_totalText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@20);
        make.width.equalTo(@100);
        make.left.equalTo(self.view).offset(10);
        make.bottom.equalTo(_eventTableView.mas_top);
    }];
    
    NSTextField *filterText = [[NSTextField alloc] init];
    [filterText setBordered:NO];
    [filterText setSelectable:NO];
    [filterText setEditable:NO];
    [filterText setBackgroundColor:[NSColor clearColor]];
    [filterText setFont:[NSFont systemFontOfSize:12]];
    [filterText setStringValue:@"Filter:    (Source —— CompareRule —— Value)"];
    [self.view addSubview:filterText];
    [filterText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@30);
        make.width.equalTo(@300);
        make.left.equalTo(self.view).offset(10);
        make.bottom.equalTo(_filterTableView.mas_top).offset(10);
    }];
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
}

- (void)updateEvents:(NSTimer *)timer {
    _events = [[DataManager shareInstance] getFilteredEvent:NO];
    if (_totalText) {
        NSString *str = [[NSString alloc] initWithFormat:@"%lu messages", (unsigned long)_events.count];
        [_totalText setStringValue:str];
    }
    [_eventTableView reloadData];
    
    // update select event
    if (_selectedEventIndex != unSelectedIndex) {
        int newIndex = unSelectedIndex;
        for (int i = 0; i < _events.count; ++i) {
            if (_events[i].index == _selectedEventIndex) {
                newIndex = i;
                break;
            }
        }
        if (newIndex != unSelectedIndex) {
            [_eventTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:newIndex] byExtendingSelection:NO];
            if (!timer) {
                [_eventTableView scrollRowToVisible:newIndex];
            }
        } else {
            _selectedEventIndex = unSelectedIndex;
        }
    }
}

- (void)updateFilter {
    for (NSInteger rowIndex = 0; rowIndex < _filterTableView.numberOfRows; rowIndex++) {
        FilterRuleView *cellView = [_filterTableView viewAtColumn:0 row:rowIndex makeIfNecessary:NO];
        if (cellView != nil) {
            [cellView updateData];
            _filterRulesData[rowIndex] = cellView.data;
        }
    }
    CGFloat newHeight = 40.0 * _filterRulesData.count + 20.0;
    [_scrollViewHeightConstraint setOffset:newHeight];
    [_filterTableView reloadData];
}

#pragma mark -- NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    if (tableView.tag == eventTableTag) {
        return _events.count;
    }
    if (tableView.tag == filterTableTag) {
        return _filterRulesData.count;
    }
    
    return 0;
}


- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row {
    if (tableView.tag == eventTableTag) {
        return _events[row];
    }
    if (tableView.tag == filterTableTag) {
        return _filterRulesData[row];
    }
    return nil;
}

#pragma mark -- NSTableViewDelegate

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row {
    if (tableView.tag == eventTableTag) {
        EventCellView *cellView = [tableView makeViewWithIdentifier:@"" owner:self];
        if (!cellView) {
            cellView = [[EventCellView alloc] init];
        }
        [cellView setStringWithEvent:_events[row] identifier:tableColumn.identifier];
        return cellView;
    }
    if (tableView.tag == filterTableTag) {
        FilterRuleView *cellView = [tableView makeViewWithIdentifier:@"" owner:self];
        if (!cellView) {
            cellView = [[FilterRuleView alloc] init];
        }
        [cellView setSelectWithData:_filterRulesData[row]];
        [cellView setDelegate:self];
        return cellView;
    }
    return nil;

}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    if (tableView.tag == eventTableTag) {
        return 28.0;
    }
    if (tableView.tag == filterTableTag) {
        return 40.0;
    }
    return 0.0;
}

- (void)tableView:(NSTableView *)tableView didAddRowView:(NSTableRowView *)rowView forRow:(NSInteger)row {
    
}

- (void)tableView:(NSTableView *)tableView didRemoveRowView:(NSTableRowView *)rowView forRow:(NSInteger)row {
    
}

- (void)tableView:(NSTableView *)tableView sortDescriptorsDidChange:(NSArray<NSSortDescriptor *> *)oldDescriptors {
    if (tableView.tag == eventTableTag) {
        _events = [_events sortedArrayUsingDescriptors:tableView.sortDescriptors];
        [[DataManager shareInstance] setSortDescriptors: tableView.sortDescriptors];
        [self updateEvents:nil];
    }
}

- (BOOL)selectionShouldChangeInTableView:(NSTableView *)tableView {
    if (tableView.tag == filterTableTag) {
        return NO;
    }
    return YES;
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    NSInteger selectedRow = _eventTableView.selectedRow;
    if (selectedRow > 0) {
        _selectedEventIndex = _events[selectedRow].index;
    } else {
        _selectedEventIndex = unSelectedIndex;
    }
}

- (void)changeShowCol:(id)sender {
    NSMenuItem *clickedMenuItem = (NSMenuItem *)sender;
    NSString *colName = [clickedMenuItem representedObject];
    NSString *showStr = clickedMenuItem.title;
    
    if ([_showCols containsObject:colName]) {
        [_showCols removeObject:colName];
        showStr = [NSString stringWithFormat:@"     %@", colName];
        [_tableCols[colName] setHidden:YES];
    } else {
        [_showCols addObject:colName];
        showStr = [NSString stringWithFormat:@"✓  %@", colName];
        [_tableCols[colName] setHidden:NO];
    }
    [clickedMenuItem setTitle:showStr];
}

- (void)doubleClickRow:(id)sender {
    NSInteger selectedRow = _eventTableView.selectedRow;
    if (selectedRow > 0) {
        NSString *destPath = _events[selectedRow].destPath;
        [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:@[[NSURL fileURLWithPath:destPath]]];
    }
}

#pragma mark -- Button Action

- (void)startMonitor {
    if (!_isMoniting) {
        [_startButton setTitle:@"  暂停"];
        NSImage *stopImg = [NSImage imageNamed:@"stop"];
        [stopImg setSize:NSMakeSize(20, 20)];
        [_startButton setImage:stopImg];
        [[DataManager shareInstance] startMonitorEvents];
        _isMoniting = YES;
    } else {
        [_startButton setTitle:@"  开始"];
        NSImage *startImg = [NSImage imageNamed:@"start"];
        [startImg setSize:NSMakeSize(20, 20)];
        [_startButton setImage:startImg];
        [[DataManager shareInstance] stopMonitorEvents];
        _isMoniting = NO;
    }
    [self updateEvents:nil];
}

- (void)clearEvents {
    [[DataManager shareInstance] clearEventsCache];
    [self updateEvents:nil];
}

- (void)filterEvents {
    [self updateFilter];
    
    EventFilter *filter = [[EventFilter alloc] init];
    if (_filterModeBox.indexOfSelectedItem == 0) {
        [filter setMode:FILTER_MODE_ALL_MATCH];
    } else if (_filterModeBox.indexOfSelectedItem == 1) {
        [filter setMode:FILTER_MODE_ANY_MATCH];
    }
    
    for (FilterData *data in _filterRulesData) {
        if (data.sourceSelectIndex == unSelectedIndex ||
            data.compareSelectIndex == unSelectedIndex ||
            data.value == nil) {
            continue;
        }
        ORI_TYPE oriType = (ORI_TYPE)data.sourceSelectIndex;
        COMPARE_TYPE compareType = (COMPARE_TYPE)data.compareSelectIndex;
        NSString *value = data.value;
        FilterRule *rule = [[FilterRule alloc] initRule:oriType compareType:compareType value:value];
        [filter addFilterRule:rule];
    }

    [[DataManager shareInstance] setEventFilter:filter];
    _events = [[DataManager shareInstance] getFilteredEvent:YES];
    [self updateEvents:nil];
}

- (void)addFilter:(NSInteger)index {
    [self updateFilter];
    FilterData *newFilter = [[FilterData alloc] init];
    [_filterRulesData insertObject:newFilter atIndex:index+1];
    for (int i = 0; i < _filterRulesData.count; ++i) {
        _filterRulesData[i].index = i;
    }
    [self updateFilter];
}

- (void)deleteFilter:(NSInteger)index {
    [self updateFilter];
    [_filterRulesData removeObjectAtIndex:index];
    if (_filterRulesData.count == 0) {
        FilterData *defaultFilter = [[FilterData alloc] init];
        [_filterRulesData addObject:defaultFilter];
    }
    for (int i = 0; i < _filterRulesData.count; ++i) {
        _filterRulesData[i].index = i;
    }
    [self updateFilter];
}

@end
