//
//  SSSettingsViewController.m
//  Soundspeed
//
//  Created by Clay on 7/31/14.
//  Copyright (c) 2014 Clay Jones. All rights reserved.
//

#import "SSSettingsViewController.h"

@interface SSSettingsViewController ()

@property UIButton *linkDropboxButton;

@end

@implementation SSSettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
      [self.view setBackgroundColor:[UIColor redColor]];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated {
  [self.navigationController.navigationBar setTintColor:[SSStylesheet primaryColor]];

}

@end
