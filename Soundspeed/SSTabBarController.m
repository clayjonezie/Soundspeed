//
//  SSTabBarController.m
//  Soundspeed
//
//  Created by Clay Jones on 7/30/14.
//  Copyright (c) 2014 Clay Jones. All rights reserved.
//

#import "SSTabBarController.h"
#import "SSStylesheet.h"

const CGFloat SSTabBarHeight = 49.0f;

@interface SSTabBarController ()

@end

@implementation SSTabBarController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    _tabBar = [[SSTabBar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - SSTabBarHeight, self.view.frame.size.width, SSTabBarHeight)];
    _tabBar.delegate = self;
    [self.view addSubview:_tabBar];
    
    _recordVC = [[SSRecordViewController alloc] init];
    _listenVC = [[SSListenViewController alloc] init];
    _settingsVC = [[SSSettingsViewController alloc] init];
    
    [_recordVC.view setFrame:CGRectMake(0, 64.0f, self.view.frame.size.width, self.view.frame.size.height - 64.0f - SSTabBarHeight)];
    [_listenVC.view setFrame:CGRectMake(0, 64.0f, self.view.frame.size.width, self.view.frame.size.height - 64.0f - SSTabBarHeight)];
    
    [self.view addSubview:_recordVC.view];
    [_recordVC viewWillAppear:YES];

    UIBarButtonItem *navItem = [[UIBarButtonItem alloc] initWithTitle:@"Settings" style:UIBarButtonItemStyleBordered target:self action:@selector(settingsButtonTapped)];
    
    [navItem setTintColor:[SSStylesheet primaryColor]];
    [self.navigationItem setLeftBarButtonItem:navItem];
    [self.navigationController.navigationBar setTintColor:[SSStylesheet primaryColor]];
  }
  return self;
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [_tabBar setHidden:NO];
}

-(void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  [_tabBar setHidden:YES];
}

-(void)tabBar:(SSTabBar *)tabBar didSelectButton:(SSTabBarButton)button {
  if (button == SSTabBarButtonRecord) {
    [_listenVC.view removeFromSuperview];
    [self.view addSubview:_recordVC.view];
  } else if (button == SSTabBarButtonListen) {
    [_recordVC.view removeFromSuperview];
    [self.view addSubview:_listenVC.view];
  }
    
}

-(void)settingsButtonTapped {
  [self.navigationController pushViewController:_settingsVC animated:YES];
}

@end
