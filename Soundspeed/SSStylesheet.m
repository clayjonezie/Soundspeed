//
//  SSStylesheet.m
//  Soundspeed
//
//  Created by Clay Jones on 7/30/14.
//  Copyright (c) 2014 Clay Jones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSStylesheet.h"

@implementation SSStylesheet

+ (UIColor *)primaryColor  {
    return [UIColor colorWithRed:0.0f green:163.0f / 255.0f blue:178.0f / 255.0f alpha:1.0f];
}

+ (UIColor *)primaryColorFaded {
    return [UIColor colorWithRed:0.0f green:163.0f / 255.0f blue:178.0f / 255.0f alpha:0.6f];
}

+ (UIFont *)primaryFont {
    return [UIFont fontWithName:@"AppleSDGothicNeo-Light" size:12.0f];
}

@end
