//
//  SLSecondViewController.h
//  Speed Lecture
//
//  Created by Clay Jones on 11/28/13.
//  Copyright (c) 2013 Big Trees Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

#import "SLHelper.h"

#define kFileSizeThreshold 268400000

typedef NS_ENUM(NSInteger, PlaybackSpeed) {
    half,
    one,
    oneAndAHalf,
    two
};

@interface SLPlaybackViewController : UIViewController <AVAudioPlayerDelegate>

@property NSString *selectedFile;
@property UIActivityIndicatorView *hud;
@property (weak, nonatomic) IBOutlet MPVolumeView *volumeView;

@property (weak, nonatomic) IBOutlet UIButton *timeSpeedButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *jumpSegmentedControl;
@property (weak, nonatomic) IBOutlet UIButton *playPauseButton;
@property (weak, nonatomic) IBOutlet UISlider *volumeSlider;
@property (weak, nonatomic) IBOutlet UILabel *fileLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *fileDownloadProgressView;
@property AVAudioPlayer *audioPlayer;
@property (weak, nonatomic) IBOutlet UISlider *timeSlider;
@property BOOL scrubbing;
@property NSTimer *timer;
@property (weak, nonatomic) IBOutlet UILabel *currentTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *maxTimeLabel;
@property PlaybackSpeed currentPlaybackSpeed;

- (IBAction)timeSliderEditingDidBegin:(id)sender;
- (IBAction)timeSliderEditingDidEnd:(id)sender;
- (IBAction)playButtonTapped:(id)sender;
- (IBAction)playbackSpeedButtonTapped:(id)sender;
- (IBAction)chooseFileButtonTapped:(id)sender;
@end
