//
//  SSTabBar.h
//  Soundspeed
//
//  Created by Clay Jones on 7/30/14.
//  Copyright (c) 2014 Clay Jones. All rights reserved.
//

typedef NS_ENUM(NSUInteger, SSTabBarButton) {
    SSTabBarButtonRecord = 0,
    SSTabBarButtonListen,
};

@class SSTabBar;
@protocol SSTabBarDelegate <NSObject>

-(void)tabBar:(SSTabBar *)tabBar didSelectButton:(SSTabBarButton)button;

@end

#import <UIKit/UIKit.h>

@interface SSTabBar : UIView

@property (nonatomic, readonly) UIView *leftView;
@property (nonatomic, readonly) UIView *rightView;

@property (nonatomic, readonly) UIButton *recordButton;
@property (nonatomic, readonly) UIButton *listenButton;

@property (nonatomic, assign) id<SSTabBarDelegate> delegate;

@end
