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
  value = lroundf(value);
  float hours = floor(value / 3600);
  float minutes = floor((value - hours * 3600) / 60);
  float seconds = floor(value - hours * 3600 - minutes * 60);

  int roundedHours = roundf(hours);
  int roundedSeconds = roundf(seconds);
  int roundedMinutes = roundf(minutes);
  
  NSString *time;
  if (hours) {
    time = [[NSString alloc]
            initWithFormat:@"%d:%02d:%02d",
            roundedHours, roundedMinutes, roundedSeconds];
    
    
  } else {
    time = [[NSString alloc]
            initWithFormat:@"%02d:%02d",
            roundedMinutes, roundedSeconds];
  }
  return time;
}

+ (NSString *)documentsDirectory {
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  return [paths objectAtIndex:0];
}

@end
