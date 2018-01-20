//
//  TestExif.m
//  QromaTagMac
//
//  Created by Kanstantsin Bucha on 1/20/18.
//  Copyright © 2018 Qroma LLC. All rights reserved.
//

#import "TestExif.h"
#import "ExifTool.h"

#include <iostream>

using namespace std;


static ExifTool * tool;

@interface TestExif ()

@end


@implementation TestExif

//MARK: - life cycle -

+ (instancetype)shared {
    static TestExif * _shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shared = [[super allocWithZone: NULL] initShared];
    });
    
    return _shared;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [self shared];
}

- (instancetype)copyWithZone:(struct _NSZone *)zone {
    return self;
}

- (instancetype)initShared {
    self = [super init];
    return self;
}

- (void)dealloc {
    delete tool;
}

- (void) restartDaemon {
    if (tool != NULL) {
        delete tool;
    }
    
    NSString * path = [NSBundle.mainBundle pathForResource: @"ExifTool"
                                                    ofType: @""];
    path = [path stringByAppendingPathComponent: @"exiftool"];
    NSLog(@"Exiftool: Prepare daemon exec using path: %@", path);

    [NSThread detachNewThreadSelector: @selector(startDaemonUsing:)
                             toTarget: self
                           withObject: path];
}

- (void) startDaemonUsing: (NSString *) path {
    NSLog(@"Exiftool: Initiate daemon");
    ExifTool::sNoWatchdog = 0;
    const char* cpath = [path cStringUsingEncoding: [NSString defaultCStringEncoding]];
    tool = new ExifTool(cpath);
}


//MARK: - interface -
- (void) createTool {
    [self guardTool];
}

//MARK: - logic -

- (BOOL) guardTool {
    if (tool == NULL) {
        [self restartDaemon];
    }
    
    while (tool == NULL) {
        NSLog(@"Exiftool: Waiting for daemon to start");
        sleep(1);
    }
    
    if (tool->IsRunning() == false) {
        NSLog(@"Exiftool: Daemon presents but not running! applying restart!");
        [self restartDaemon];
        return NO;
    }

    return YES;
}

- (void) testFile: (NSString *) filePath {
    if ([self guardTool] == NO) {
        return;
    }
    
    const char* file = [filePath cStringUsingEncoding: [NSString defaultCStringEncoding]];
    
    cout << tool->IsRunning();
    // read metadata from the image
    TagInfo *info = tool->ImageInfo(file);
    if (info) {
        // print returned information
        for (TagInfo *i=info; i; i=i->next) {
            cout << i->name << " = " << i->value << endl;
        }
        // we are responsible for deleting the information when done
        delete info;
    } else if (tool->LastComplete() <= 0) {
        cerr << "Error executing exiftool!" << endl;
    }
    // print exiftool stderr messages
    char *err = tool->GetError();
    if (err) cout << err;
          // delete our ExifTool object
}

- (NSDictionary<NSString *, NSString *> *) readKeys: (NSArray<NSString *> *) keys
                                               from: (NSString *) filePath {
    
    NSMutableDictionary * result = [NSMutableDictionary dictionary];
    
    NSStringEncoding encoding = [NSString defaultCStringEncoding];
    
    const char* file = [filePath cStringUsingEncoding: encoding];
    
    TagInfo *info = tool->ImageInfo(file);
    if (info) {
        // print returned information
        for (TagInfo *i=info; i; i=i->next) {
            NSString * key =  [NSString stringWithCString: i->name
                                                 encoding: encoding];
            if ([keys containsObject: key] == NO) {
                continue;
            }
            
            NSString * value =  [NSString stringWithCString: i->value
                                                   encoding: encoding];
            if (value.length == 0) {
                continue;
            }
            
            result[key] = value;
        }
    } else if (tool->LastComplete() <= 0) {
        cerr << "Error executing exiftool!" << endl;
        char* err = tool->GetError();
        if (err) cout << err;
    }
    
    return [result copy];
}

- (NSArray<NSString *> *)imageMetadataKeys {
    NSArray * result = @[
                         // imageMetadata key
                         @"OriginatingProgram",
                         @"ProgramVersion",
                         
                         // Exif.Photo
                         
                         @"DateTimeOriginal",
                         @"CreateDate",
                         
                         //Exif.GPSInfo
                         
                         @"GPSLatitude",
                         @"GPSLatitudeRef",
                         @"GPSLongitude",
                         @"GPSLongitudeRef",
                         @"GPSTimeStamp",
                         
                         // Iptc.Application2
                         
                         @"Location",
                         @"City",
                         @"State",
                         @"Country",
                         @"Iptc.Application2.CountryCode", //?
                         
                         @"Keywords",
                         
                         // Exif.Image
                         @"ImageDescription",
                         @"UserComment"
                         ];
    
    return result;
}

- (void)printKeys {
    NSLog(@"===========================");
    
    // imageIO framework key                                                    // imageMetadata key
    
    NSLog(@"%@", (NSString *)kCGImagePropertyExifDictionary);                   // Exif.Photo
    
    NSLog(@"%@", (NSString *)kCGImagePropertyExifDateTimeOriginal);             // Exif.Photo.DateTimeOriginal     ?Exif.Image.DateTimeOriginal
    NSLog(@"%@", (NSString *)kCGImagePropertyExifDateTimeDigitized);            // Exif.Photo.DateTimeDigitized
    
    NSLog(@"===========================");
    
    
    NSLog(@"%@", (NSString *)kCGImagePropertyGPSDictionary);                     // Exif.GPSInfo
    
    NSLog(@"%@", (NSString *)kCGImagePropertyGPSLatitude);                       // Exif.GPSInfo.GPSLatitude
    NSLog(@"%@", (NSString *)kCGImagePropertyGPSLatitudeRef);                    // Exif.GPSInfo.GPSLatitudeRef
    NSLog(@"%@", (NSString *)kCGImagePropertyGPSLongitude);                      // Exif.GPSInfo.GPSLongitude
    NSLog(@"%@", (NSString *)kCGImagePropertyGPSLongitudeRef);                   // Exif.GPSInfo.GPSLongitudeRef
    NSLog(@"%@", (NSString *)kCGImagePropertyGPSTimeStamp);                      // Exif.GPSInfo.GPSTimeStamp
    
    NSLog(@"===========================");
    
    NSLog(@"%@", (NSString *)kCGImagePropertyIPTCDictionary);                    // Iptc.Application2
    
    NSLog(@"%@", (NSString *)kCGImagePropertyIPTCSubLocation);                   // Iptc.Application2.SubLocation
    NSLog(@"%@", (NSString *)kCGImagePropertyIPTCCity);                          // Iptc.Application2.City
    NSLog(@"%@", (NSString *)kCGImagePropertyIPTCProvinceState);                 // Iptc.Application2.ProvinceState
    NSLog(@"%@", (NSString *)kCGImagePropertyIPTCCountryPrimaryLocationName);    // Iptc.Application2.CountryName
    NSLog(@"%@", (NSString *)kCGImagePropertyIPTCCountryPrimaryLocationCode);    // Iptc.Application2.CountryCode
    
    NSLog(@"%@", (NSString *)kCGImagePropertyIPTCKeywords);                      // Iptc.Application2.Keywords
    
    NSLog(@"===========================");
    
    NSLog(@"%@", (NSString *)kCGImagePropertyTIFFDictionary);                      // Exif.Image
    NSLog(@"%@", (NSString *)kCGImagePropertyTIFFImageDescription);                // Exif.Image.ImageDescription   ?Exif.Photo.UserComment
}

@end
