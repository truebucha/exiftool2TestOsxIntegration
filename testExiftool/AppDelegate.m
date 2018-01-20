//
//  AppDelegate.m
//  testExiftool
//
//  Created by Kanstantsin Bucha on 1/20/18.
//  Copyright © 2018 Truebucha. All rights reserved.
//

#import "AppDelegate.h"
#import "TestExif.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    dispatch_async(dispatch_get_main_queue(), ^{
        [TestExif.shared createTool];
    });
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


@end
