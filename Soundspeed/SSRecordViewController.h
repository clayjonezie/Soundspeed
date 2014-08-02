//
//  SSRecordViewController.h
//  Soundspeed
//
//  Created by Clay on 7/31/14.
//  Copyright (c) 2014 Clay Jones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface SSRecordViewController : UIViewController<AVAudioRecorderDelegate>

@property BOOL recording;

@end
