//
//  SSRecordViewController.m
//  Soundspeed
//
//  Created by Clay on 7/31/14.
//  Copyright (c) 2014 Clay Jones. All rights reserved.
//

#import "SSRecordViewController.h"
#import <Dropbox/Dropbox.h>

@interface SSRecordViewController ()

@property UITextField *titleField;
@property UISwitch *dateSwitch;
@property UISwitch *timeSwitch;
@property UILabel *dateLabel;
@property UILabel *timeLabel;
@property UILabel *titleLabel;
@property UILabel *elapsedTimeLabel;
@property UIButton *recordButton;

@property NSURL *audioFilePath;
@property DBFile *dbFile;
@property (nonatomic, retain) AVAudioRecorder *recorder;
@property NSTimer *updateTimeTimer;

@end

const CGFloat SSRecordViewCellHeight = 44.0f;
const CGFloat SSRecordButtonSize = 75.0f;

@implementation SSRecordViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    _titleField = [[UITextField alloc] init];
    [_titleField setPlaceholder:@"Recording Title"];
    [_titleField setTextAlignment:NSTextAlignmentCenter];
    [_titleField addTarget:self action:@selector(titleFieldDismissed) forControlEvents:UIControlEventEditingDidEndOnExit];
    [_titleField addTarget:self action:@selector(updateTitleLabel) forControlEvents:UIControlEventAllEditingEvents];
    [_titleField setReturnKeyType:UIReturnKeyDone];
    [_titleField setTextColor:[SSStylesheet primaryColor]];
    [_titleField setFont:[SSStylesheet primaryFontLarge]];
    
    _dateSwitch = [UISwitch new];
    [_dateSwitch setOnTintColor:[SSStylesheet primaryColor]];
    [_dateSwitch addTarget:self action:@selector(updateTitleLabel) forControlEvents:UIControlEventValueChanged];
    _timeSwitch = [UISwitch new];
    [_timeSwitch setOnTintColor:[SSStylesheet primaryColor]];
    [_timeSwitch addTarget:self action:@selector(updateTitleLabel) forControlEvents:UIControlEventValueChanged];
    
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
    
    _elapsedTimeLabel = [UILabel new];
    
    [_titleLabel setFont:[SSStylesheet primaryFontLarge]];
    
    _recordButton = [[UIButton alloc] init];
    
    [self.view addSubview:_titleField];
    [self.view addSubview:_dateSwitch];
    [self.view addSubview:_timeSwitch];
    [self.view addSubview:_timeLabel];
    [self.view addSubview:_dateLabel];
    [self.view addSubview:_titleLabel];
    [self.view addSubview:_recordButton];
    [self.view addSubview:_elapsedTimeLabel];
    
    _recording = NO;
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
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
  

  [_recordButton setFrame:CGRectMake((width - SSRecordButtonSize) / 2, SSRecordViewCellHeight * 5, SSRecordButtonSize, SSRecordButtonSize)];
  
  [_recordButton.layer setCornerRadius:SSRecordButtonSize / 2];
  [_recordButton.layer setBackgroundColor:[[SSStylesheet primaryColor] CGColor]];

  [_recordButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
  [_recordButton setTitle:@"Rec." forState:UIControlStateNormal];
  [_recordButton addTarget:self action:@selector(recordButtonTapped) forControlEvents:UIControlEventTouchUpInside];
  
  [_elapsedTimeLabel setFrame:CGRectMake(0, SSRecordViewCellHeight * 7, width, 30.0f)];
  [_elapsedTimeLabel setTextColor:[SSStylesheet primaryColor]];
  [_elapsedTimeLabel setFont:[SSStylesheet primaryFontLarge]];
  [_elapsedTimeLabel setTextAlignment:NSTextAlignmentCenter];
  [_elapsedTimeLabel setAlpha:0.0f];
  
  [self updateRecordButton];
  [self updateTitleLabel];
}

- (NSString *)stringForTitle {
  NSMutableString *title = [[NSMutableString alloc] initWithString:[_titleField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
  
  NSDate *now = [NSDate date];
  
  if (_dateSwitch.on) {
    [title appendFormat:@" %@", [NSDateFormatter localizedStringFromDate:now dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterNoStyle]];
  }
  if (_timeSwitch.on) {
    [title appendFormat:@" %@", [NSDateFormatter localizedStringFromDate:now dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle]];
  }
  
  [title replaceOccurrencesOfString:@"/" withString:@"-" options:NSLiteralSearch range:NSMakeRange(0, [title length])];
  
  if (![title length]) {
    [title appendString:@"Untitled"];
  }

  return [title copy];
}

- (void)updateTitleLabel {
  [_titleLabel setText:[self stringForTitle]];
}

- (void)titleFieldDismissed {
  [_titleField resignFirstResponder];
}

- (void)recordButtonTapped {
  [_titleField resignFirstResponder];

  if (_recording) {
    [self stopRecording];
  } else {
    [self startRecording];
  }
}

- (void)startRecording {
  AVAudioSession *audioSession = [AVAudioSession sharedInstance];
  NSError *error;
  
  [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
  if (error) {
    CJERROR(error);
    return;
  }
  
  [audioSession setActive:YES error:&error];
  if (error) {
    CJERROR(error);
    return;
  }
  
  NSMutableDictionary *recordSettings = [[NSMutableDictionary alloc] initWithCapacity:10];

  [recordSettings setObject:[NSNumber numberWithInteger:kAudioFormatMPEG4AAC] forKey: AVFormatIDKey];
  [recordSettings setObject:[NSNumber numberWithFloat:44100.0] forKey: AVSampleRateKey];
  [recordSettings setObject:[NSNumber numberWithInt:2] forKey:AVNumberOfChannelsKey];
  [recordSettings setObject:[NSNumber numberWithInt:12800] forKey:AVEncoderBitRateKey];
  [recordSettings setObject:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
  [recordSettings setObject:[NSNumber numberWithInt: AVAudioQualityHigh] forKey: AVEncoderAudioQualityKey];
  
  NSString *filename = [NSString stringWithFormat:@"%@.m4a", _titleLabel.text];
  DBPath *newPath = [[DBPath root] childPath:@"Soundspeed"];
  newPath = [newPath childPath:filename];
  _dbFile = [[DBFilesystem sharedFilesystem] createFile:newPath error:&error];

  if (error) {
    CJERROR(error);
    
    if (error.code == DBErrorExists) {
      [self showFilenameExistsAlert];
    }
    
    return;
  }
  
  NSString *fullPath = [[SSHelper documentsDirectory] stringByAppendingPathComponent:filename];
  _audioFilePath = [NSURL fileURLWithPath:fullPath];
  
  NSDictionary *settingsCopy = [NSDictionary dictionaryWithDictionary:recordSettings];
  _recorder = [[AVAudioRecorder alloc] initWithURL:_audioFilePath settings:settingsCopy error:&error];

  if (error) {
    NSLog(@"ERROR: %@ %ld %@", [error domain], (long)[error code], [[error userInfo] description]);
    return;
  }
  
  [_recorder prepareToRecord];
  
  BOOL audioHWAvailiable = audioSession.inputAvailable;
  if (!audioHWAvailiable) {
    QuickAlert(@"Error", @"Audio hardware is not avaliable");
  }
  
  [_recorder setDelegate:self];
  _recording = [_recorder record];

  [self updateRecordButton];
  if (_recording) {
    _updateTimeTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(updateElapsedTimeLabel) userInfo:nil repeats:YES];
  }
}

- (void)stopRecording {
  [_recorder stop];
  [_updateTimeTimer invalidate];
  _recording = NO;
  [self updateRecordButton];
  
  NSError *error;
  [_dbFile writeContentsOfFile:[_audioFilePath path] shouldSteal:YES error:&error];
  if (error) {
    NSLog(@"ERROR: %@ %ld %@", [error domain], (long)[error code], [[error userInfo] description]);
  }
  
  _dbFile = nil;
  _audioFilePath = nil;
}

- (void)updateRecordButton {
  CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"cornerRadius"];
  CAAnimationGroup *group = [CAAnimationGroup animation];
  
  if (!_recording) {
    animation.toValue = [NSNumber numberWithFloat:SSRecordButtonSize / 2];
    animation.fromValue = [NSNumber numberWithFloat:0];
    group.fillMode = kCAFillModeBackwards;
    [_recordButton setTitle:@"Rec." forState:UIControlStateNormal];
    
    
    if ([_titleField.text length]) {
      [UIView animateWithDuration:0.5f animations:^{
        [_titleField setAlpha:0.0f];
      } completion:^(BOOL finished) {
        [_titleField setText:@""];
        [self updateTitleLabel];
        
        [UIView animateWithDuration:0.5 animations:^{
          [_titleField setAlpha:1.0f];
        }];
      }];
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
      if (!_recording) {
        [UIView animateWithDuration:0.5f animations:^{
          [_elapsedTimeLabel setAlpha:0.0f];
        } completion:^(BOOL finished) {
          [_elapsedTimeLabel setText:@""];
        }];
      }
    });
  } else {
    animation.toValue = [NSNumber numberWithFloat:0.0f];
    animation.fromValue = [NSNumber numberWithFloat:SSRecordButtonSize / 2];
    group.fillMode = kCAFillModeForwards;
    [_recordButton setTitle:@"Stop" forState:UIControlStateNormal];
    
    [UIView animateWithDuration:0.5f animations:^{
      [_elapsedTimeLabel setText:@"0:00"];
      [_elapsedTimeLabel setAlpha:1.0f];
    } completion:nil];
  }
  
  group.removedOnCompletion = NO;
  group.duration = 0.25;
  [group setAnimations:@[animation]];
  [_recordButton.layer addAnimation:group forKey:@"cornerRadius"];
}

- (void)updateElapsedTimeLabel {
  [_elapsedTimeLabel setText:[SSHelper timeFormat:[_recorder currentTime]]];
}

- (void)showFilenameExistsAlert {
  NSString *message = @"That recording already exists. Change the Recording Title or add the date or time";
  UIAlertView *filenameExistsAlert = [[UIAlertView alloc] initWithTitle:@"Name in use"
                                                                message:message
                                                               delegate:nil
                                                      cancelButtonTitle:@"Got it"
                                                      otherButtonTitles: nil];
  [filenameExistsAlert show];
}

@end
