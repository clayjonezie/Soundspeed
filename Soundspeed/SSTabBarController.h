//
//  SSTabBarController.h
//  Soundspeed
//
//  Created by Clay Jones on 7/30/14.
//  Copyright (c) 2014 Clay Jones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSTabBar.h"
#import "SSListenViewController.h"
#import "SSRecordViewController.h"
#import "SSSettingsViewController.h"

@interface SSTabBarController : UIViewController <SSTabBarDelegate, UINavigationBarDelegate>

@property (nonatomic, readonly) SSTabBar *tabBar;
@property (nonatomic) SSListenViewController *listenVC;
@property (nonatomic) SSRecordViewController *recordVC;
@property (nonatomic) SSSettingsViewController *settingsVC;

+ (CGFloat)tabBarHeight;

@end
