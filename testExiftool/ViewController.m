//
//  ViewController.m
//  testExiftool
//
//  Created by Kanstantsin Bucha on 1/20/18.
//  Copyright © 2018 Truebucha. All rights reserved.
//

#import "ViewController.h"
#import "TestExif.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
}

- (void)viewDidAppear {
    
    [super viewDidAppear];
    
    NSURL * url = [NSBundle.mainBundle URLForResource: @"769474"
                                        withExtension: @"JPG"];
    if (url == nil) {
        return;
    }
    
    NSString * imagePath = url.path;
    
    NSLog(@"======================\n==\n==\n==\n==\n==\n==\n======================\n");
    [TestExif.shared testFile: imagePath];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


@end
