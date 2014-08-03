//
//  SSAppDelegate.m
//  Soundspeed
//
//  Created by Clay Jones on 7/30/14.
//  Copyright (c) 2014 Clay Jones. All rights reserved.
//

#import "SSAppDelegate.h"
#import "SSTabBarController.h"
#import <Dropbox/Dropbox.h>

@interface SSAppDelegate ()

@property UINavigationController *navController;

@end

@implementation SSAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

  self.window.backgroundColor = [UIColor whiteColor];
  [self.window makeKeyAndVisible];
  
  _tabBarController = [[SSTabBarController alloc] init];
  _navController = [[UINavigationController alloc] init];
  [_navController pushViewController:_tabBarController animated:NO];
  [self.window setRootViewController:_navController];
  
  // setup dropbox
  DBAccountManager *accountManager = [[DBAccountManager alloc] initWithAppKey:@"59gw8vscdz1u5oc" secret:@"xg6gb603nla3kn0"];
  [DBAccountManager setSharedManager:accountManager];
  
  DBAccount *account = [[DBAccountManager sharedManager] linkedAccount];
  if (account) {
    DBFilesystem *filesystem = [[DBFilesystem alloc] initWithAccount:account];
    [DBFilesystem setSharedFilesystem:filesystem];
  }
  
  return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
  // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
  // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
  // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
  // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
  // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
  // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
  // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url
  sourceApplication:(NSString *)source annotation:(id)annotation {
  
  DBAccount *account = [[DBAccountManager sharedManager] handleOpenURL:url];
  if (account) {
    return YES;
    if ([[_navController topViewController] isKindOfClass:[SSSettingsViewController class]]) {
      [((SSSettingsViewController*)[_navController topViewController]) linkDropboxAccountDidSucceed];
    } else {
      QuickAlert(@"Success linking Dropbox Account");
    }
    
    DBAccount *account = [[DBAccountManager sharedManager] linkedAccount];
    if (account) {
      DBFilesystem *filesystem = [[DBFilesystem alloc] initWithAccount:account];
      [DBFilesystem setSharedFilesystem:filesystem];
    }
  }
  return NO;
}

@end
