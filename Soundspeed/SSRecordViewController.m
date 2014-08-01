//
//  SSRecordViewController.m
//  Soundspeed
//
//  Created by Clay on 7/31/14.
//  Copyright (c) 2014 Clay Jones. All rights reserved.
//

#import "SSRecordViewController.h"

@interface SSRecordViewController ()

@property UITextField *titleField;
@property UISwitch *dateSwitch;
@property UISwitch *timeSwitch;
@property UILabel *dateLabel;
@property UILabel *timeLabel;
@property UILabel *titleLabel;

@end

const CGFloat SSRecordViewCellHeight = 44.0f;

@implementation SSRecordViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    _titleField = [[UITextField alloc] init];
    [_titleField setPlaceholder:@"Recording Title"];
    [_titleField setTextAlignment:NSTextAlignmentCenter];
    [_titleField addTarget:self action:@selector(titleFieldDismissed) forControlEvents:UIControlEventEditingDidEndOnExit];
    [_titleField setReturnKeyType:UIReturnKeyDone];
    [_titleField setTextColor:[SSStylesheet primaryColor]];
    [_titleField setFont:[SSStylesheet primaryFontLarge]];
    
    _dateSwitch = [UISwitch new];
    [_dateSwitch setOnTintColor:[SSStylesheet primaryColor]];
    _timeSwitch = [UISwitch new];
    [_timeSwitch setOnTintColor:[SSStylesheet primaryColor]];
    _dateLabel = [UILabel new];
    [_dateLabel setText:@"DATE"];
    [_dateLabel setFont:[SSStylesheet primaryFontLarge]];
    [_dateLabel setTextColor:[SSStylesheet primaryColor]];
    _timeLabel = [UILabel new];
    [_timeLabel setText:@"TIME"];
    [_timeLabel setTextColor:[SSStylesheet primaryColor]];
    [_timeLabel setFont:[SSStylesheet primaryFontLarge]];
    
    _titleLabel = [UILabel new];
    [_titleLabel setTextColor:[SSStylesheet primaryColor]];
    [_titleLabel setTextAlignment:NSTextAlignmentCenter];
    [_titleLabel setFont:[SSStylesheet primaryFontLarge]];
    
    [self.view addSubview:_titleField];
    [self.view addSubview:_dateSwitch];
    [self.view addSubview:_timeSwitch];
    [self.view addSubview:_timeLabel];
    [self.view addSubview:_dateLabel];
    [self.view addSubview:_titleLabel];
    
    [self updateTitleLabel];
  }
  return self;
}

-(void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  CGFloat width = self.view.frame.size.width;
  
  CGFloat divWidth = width * 4 / 5;
  CALayer *div1 = [[CALayer alloc] init];
  CALayer *div2 = [[CALayer alloc] init];
  
  [div1 setFrame:CGRectMake((width - divWidth) / 2, SSRecordViewCellHeight * 2, divWidth, 1.0f)];
  [div2 setFrame:CGRectMake((width - divWidth) / 2, SSRecordViewCellHeight * 3, divWidth, 1.0f)];
  
  [div1 setBackgroundColor:[[SSStylesheet primaryColor] CGColor]];
  [div2 setBackgroundColor:[[SSStylesheet primaryColor] CGColor]];
  
  [self.view.layer addSublayer:div1];
  [self.view.layer addSublayer:div2];
  
  [_titleField setFrame:CGRectMake(0, SSRecordViewCellHeight, width, SSRecordViewCellHeight)];
  
  [_dateLabel setFrame:CGRectMake(20, SSRecordViewCellHeight * 2, width / 5, SSRecordViewCellHeight)];
  [_dateSwitch setFrame:CGRectMake(width / 4, SSRecordViewCellHeight * 2 + 5.0f, width / 5, SSRecordViewCellHeight)];
  [_timeLabel setFrame:CGRectMake(width * 2 / 4 + 20, SSRecordViewCellHeight * 2, width / 5, SSRecordViewCellHeight)];
  [_timeSwitch setFrame:CGRectMake(width * 3 / 4, SSRecordViewCellHeight * 2 + 5.0f, width / 5, SSRecordViewCellHeight)];
  
  [_titleLabel setFrame:CGRectMake(0, SSRecordViewCellHeight * 3, width, SSRecordViewCellHeight)];
}

-(NSString *)stringForTitle {
  NSMutableString *title = [[NSMutableString alloc] initWithString:[_titleField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
  
  if (_dateSwitch.on) {
    
  }
  
  if (_timeSwitch.on) {
    
  }
  
  
  
  return [title copy];
}

-(void)updateTitleLabel {
  [_titleLabel setText:[self stringForTitle]];
}

-(void)titleFieldDismissed {
  [_titleField resignFirstResponder];
}

@end
