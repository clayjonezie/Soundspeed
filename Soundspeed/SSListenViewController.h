//
//  SSListenViewController.h
//  Soundspeed
//
//  Created by Clay on 7/31/14.
//  Copyright (c) 2014 Clay Jones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "SSDropboxChooser.h"


typedef NS_ENUM(NSInteger, SSPlaybackSpeed) {
  half,
  one,
  oneAndAHalf,
  two
};

@interface SSListenViewController : UIViewController<SSDropboxChooserDelegate, AVAudioPlayerDelegate>

@property (nonatomic, readonly) UIBarButtonItem *chooseButtonItem;

@end
