//
//  SSHelper.m
//  Soundspeed
//
//  Created by Clay on 8/1/14.
//  Copyright (c) 2014 Clay Jones. All rights reserved.
//

#import "SSHelper.h"

@implementation SSHelper

+ (NSString*)timeFormat:(float)value{
  
  // from this homie http://www.ymc.ch/en/building-a-simple-audioplayer-in-ios
  
  float minutes = floor(lroundf(value)/60);
  float seconds = lroundf(value) - (minutes * 60);
  
  int roundedSeconds = lroundf(seconds);
  int roundedMinutes = lroundf(minutes);
  
  NSString *time = [[NSString alloc]
                    initWithFormat:@"%d:%02d",
                    roundedMinutes, roundedSeconds];
  return time;
}

+ (NSString *) cachesDirectory {
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
  if ([paths count]) {
    NSString *bundle = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:bundle];
    return path;
  } else {
    NSLog(@"<--- no paths after searching for caches dir");
    return NULL;
  }
}

+ (NSString *)documentsDirectory {
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  return [paths objectAtIndex:0];
}

@end
