//
//  SSDropboxHelper.m
//  Soundspeed
//
//  Created by Clay on 8/3/14.
//  Copyright (c) 2014 Clay Jones. All rights reserved.
//

#import "SSDropboxHelper.h"

@implementation SSDropboxHelper

+ (void)forceSyncInBackground {
  
}

+ (DBFilesystem *)sharedFilesystem {
  DBFilesystem *filesystem = [DBFilesystem sharedFilesystem];
  if (!filesystem) {
    if (![[DBAccountManager sharedManager] linkedAccount]) {
      QuickAlert(@"Please link your account in settings");
      return nil;
    } else {
      filesystem = [[DBFilesystem alloc] initWithAccount:[[DBAccountManager sharedManager] linkedAccount]];
      if (filesystem) {
        [DBFilesystem setSharedFilesystem:filesystem];
      } else {
        QuickAlert(@"Error creating filesystem with your Dropbox account");
        return nil;
      }
    }
  }
  return filesystem;
}



@end
