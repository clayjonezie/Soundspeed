//
//  SLHelper.h
//  Speed Lecture
//
//  Created by Clay Jones on 12/23/13.
//  Copyright (c) 2013 Clay Jones. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SLHelper : NSObject

+(NSString*)timeFormat:(float)value;
+(void)logCachesDirectory;
+(NSString *)cachesDirectory;
+(UIBarButtonItem *) gearButtonItem;
+(NSArray*)m4aFilesInCachesDirectory;

@end
