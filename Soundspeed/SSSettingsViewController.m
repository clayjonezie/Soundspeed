//
//  SSSettingsViewController.m
//  Soundspeed
//
//  Created by Clay on 7/31/14.
//  Copyright (c) 2014 Clay Jones. All rights reserved.
//

#import "SSSettingsViewController.h"
#import <Dropbox/Dropbox.h>

@interface SSSettingsViewController ()

@property UIButton *linkDropboxButton;

@end

@implementation SSSettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    
  }
  return self;
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [self.view setBackgroundColor:[UIColor whiteColor]];
  [self.navigationController.navigationBar setTintColor:[SSStylesheet primaryColor]];
  
  [_linkDropboxButton removeFromSuperview];
  _linkDropboxButton = [[UIButton alloc] init];
  [_linkDropboxButton setTitleColor:[SSStylesheet primaryColor] forState:UIControlStateNormal];
  
  [_linkDropboxButton.titleLabel setFont:[SSStylesheet primaryFontLarge]];
  [_linkDropboxButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
  
  if ([[DBAccountManager sharedManager] linkedAccount]) {
    DBAccountInfo *account = [[[DBAccountManager sharedManager] linkedAccount] info];
    [_linkDropboxButton setTitle:[NSString stringWithFormat:@"Dropbox Account (%@) is Linked!", account.displayName]
                        forState:UIControlStateNormal];
    [_linkDropboxButton.layer setBorderWidth:0.0f];
    [_linkDropboxButton.titleLabel setNumberOfLines:2];
  } else {
    [_linkDropboxButton setTitle:@"Link Dropbox Account" forState:UIControlStateNormal];
    [_linkDropboxButton.titleLabel setNumberOfLines:1];
    [_linkDropboxButton.layer setBorderColor:[[SSStylesheet primaryColor] CGColor]];
    [_linkDropboxButton.layer setCornerRadius:10.0f];
    [_linkDropboxButton.layer setBorderWidth:1.0f];
    [_linkDropboxButton setTitleColor:[SSStylesheet primaryColorFaded] forState:UIControlStateHighlighted];
    [_linkDropboxButton addTarget:self action:@selector(linkDropboxAccount) forControlEvents:UIControlEventTouchUpInside];
  }

  CGFloat viewWidth = self.view.frame.size.width;
  CGSize size = CGSizeMake(viewWidth - 60.0f, 60.0f);
  CGFloat margin = 12.0f;
  [_linkDropboxButton setFrame:CGRectMake((viewWidth - size.width - 2 * margin) / 2, 100.0f, size.width + margin * 2, size.height + margin)];
  
  [self.view addSubview:_linkDropboxButton];
}

- (void)linkDropboxAccount {
  [[DBAccountManager sharedManager] linkFromController:self];
}

- (void)linkDropboxAccountDidSucceed {
  
}


@end
