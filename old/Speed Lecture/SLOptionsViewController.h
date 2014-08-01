//
//  SLOptionsViewController.h
//  Soundspeed
//
//  Created by Clay Jones on 4/24/14.
//  Copyright (c) 2014 Clay Jones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DropboxSDK/DropboxSDK.h>

@interface SLOptionsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, DBRestClientDelegate>

@property NSArray *cachedFiles;

@end
