//
//  TestExif.h
//  QromaTagMac
//
//  Created by Kanstantsin Bucha on 1/20/18.
//  Copyright © 2018 Qroma LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TestExif : NSObject

+ (instancetype) shared;
- (void) createTool;

- (void) testFile: (NSString *) filePath;
- (NSDictionary<NSString *, NSString *> *) readKeys: (NSArray<NSString *> *) keys
                                               from: (NSString *) filePath;
- (NSArray<NSString *> *) imageMetadataKeys;


- (TestExif *) init __attribute__((unavailable("init not available")));
+ (TestExif *) new __attribute__((unavailable("init not available")));

@end
