//
//  SLHelper.m
//  Speed Lecture
//
//  Created by Clay Jones on 12/23/13.
//  Copyright (c) 2013 Clay Jones. All rights reserved.
//

#import "SLHelper.h"

@implementation SLHelper

+(NSString*)timeFormat:(float)value{
    
    // from internet http://www.ymc.ch/en/building-a-simple-audioplayer-in-ios
    // cause lazy
    
    float minutes = floor(lroundf(value)/60);
    float seconds = lroundf(value) - (minutes * 60);
    
    int roundedSeconds = lroundf(seconds);
    int roundedMinutes = lroundf(minutes);
    
    NSString *time = [[NSString alloc]
                      initWithFormat:@"%d:%02d",
                      roundedMinutes, roundedSeconds];
    return time;
}

+(NSString *) cachesDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    if ([paths count]) {
        NSString *bundle = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
        NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:bundle];
        return path;
    } else {
        DebugLog(@"<--- no paths after searching for caches dir");
        return NULL;
    }
}

+(void)logCachesDirectory {
    NSArray *dirFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self cachesDirectory] error:nil];
    DebugLog(@"====caches dir===");
    for (NSString *file in dirFiles) {
        DebugLog(@"%@", file);
    }
}

+(NSArray*)m4aFilesInCachesDirectory {
    NSMutableArray *files = [NSMutableArray new];
    NSArray *dirFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self cachesDirectory] error:nil];
    for (NSString *file in dirFiles) {
        if ([[file pathExtension] isEqualToString:@"m4a"]) {
            [files addObject:file];
        }
    }
    return [NSArray arrayWithArray:files];
}

+(UIBarButtonItem *)gearButtonItem {
    UIBarButtonItem *gear = [[UIBarButtonItem alloc] init];
    gear.title = @" \u2699";
    UIFont *f1 = [UIFont fontWithName:@"Helvetica" size:24.0];
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:f1, NSFontAttributeName, nil];
    [gear setTitleTextAttributes:dict forState:UIControlStateNormal];
    return gear;
}

@end
