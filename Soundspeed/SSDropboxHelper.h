//
//  SSDropboxHelper.h
//  Soundspeed
//
//  Created by Clay on 8/3/14.
//  Copyright (c) 2014 Clay Jones. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Dropbox/Dropbox.h>

@interface SSDropboxHelper : NSObject

+ (void)forceSyncInBackground;
+ (DBFilesystem *)sharedFilesystem;

@end
