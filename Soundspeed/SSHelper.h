//
//  SSHelper.h
//  Soundspeed
//
//  Created by Clay on 8/1/14.
//  Copyright (c) 2014 Clay Jones. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSHelper : NSObject

+(NSString*)timeFormat:(float)value;
+ (NSString *) cachesDirectory;
+ (NSString *)documentsDirectory;

@end
