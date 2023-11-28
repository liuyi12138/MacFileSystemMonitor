//
//  AppDelegate.m
//  MFSMonitor
//
//  Created by liuyi on 2023/11/9.
//

#import "AppDelegate.h"
#import "DataManager.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    [[DataManager shareInstance] stopMonitorEvents];
    [[DataManager shareInstance] clearEventsCache];
}


- (BOOL)applicationSupportsSecureRestorableState:(NSApplication *)app {
    return YES;
}


@end
