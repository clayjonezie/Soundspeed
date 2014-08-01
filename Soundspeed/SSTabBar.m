//
//  SSTabBar.m
//  Soundspeed
//
//  Created by Clay Jones on 7/30/14.
//  Copyright (c) 2014 Clay Jones. All rights reserved.
//

#import "SSTabBar.h"
#import "SSStylesheet.h"
#import <QuartzCore/QuartzCore.h>

@implementation SSTabBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIView *topBorder = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 1.0f)];
        [topBorder setBackgroundColor:[SSStylesheet primaryColor]];
        [self addSubview:topBorder];
        
        UIView *middleBorder = [[UIView alloc] initWithFrame:CGRectMake(frame.size.width / 2, 0, 1.0f, frame.size.height)];
        [middleBorder setBackgroundColor:[SSStylesheet primaryColor]];
        [self addSubview:middleBorder];
        
        _leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width / 2, frame.size.height)];
        _rightView = [[UIView alloc] initWithFrame:CGRectMake(frame.size.width / 2, 0, frame.size.width / 2, frame.size.height)];
        
        [self addSubview:_leftView];
        [self addSubview:_rightView];
        
        _recordButton = [[UIButton alloc] init];
        _listenButton = [[UIButton alloc] init];
        
        [_recordButton setTitle:@"RECORD" forState:UIControlStateNormal];
        [_listenButton setTitle:@"LISTEN" forState:UIControlStateNormal];
        
        [_recordButton setTitleColor:[SSStylesheet primaryColor] forState:UIControlStateNormal];
        [_listenButton setTitleColor:[SSStylesheet primaryColor] forState:UIControlStateNormal];
        
        [_recordButton.titleLabel setFont:[SSStylesheet primaryFont]];
        [_listenButton.titleLabel setFont:[SSStylesheet primaryFont]];

        [_recordButton addTarget:self action:@selector(recordButtonSelected) forControlEvents:UIControlEventTouchUpInside];
        [_listenButton addTarget:self action:@selector(listenButtonSelected) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:_recordButton];
        [self addSubview:_listenButton];
        
        [self recordButtonSelected];
    }
    return self;
}

- (void)layoutSubviews {
    [_recordButton setFrame:_leftView.frame];
    [_listenButton setFrame:_rightView.frame];
}

- (void)recordButtonSelected {
    [_leftView setBackgroundColor:[SSStylesheet primaryColor]];
    [_recordButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_rightView setBackgroundColor:[UIColor clearColor]];
    [_listenButton setTitleColor:[SSStylesheet primaryColor] forState:UIControlStateNormal];
    [_delegate tabBar:self didSelectButton:SSTabBarButtonRecord];
}

- (void)listenButtonSelected {
    [_rightView setBackgroundColor:[SSStylesheet primaryColor]];
    [_listenButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_leftView setBackgroundColor:[UIColor clearColor]];
    [_recordButton setTitleColor:[SSStylesheet primaryColor] forState:UIControlStateNormal];
    [_delegate tabBar:self didSelectButton:SSTabBarButtonListen];
}

@end
