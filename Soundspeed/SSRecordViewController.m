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
@property UIButton *recordButton;

@property NSString *audioFilePath;
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
    [_titleLabel setFont:[SSStylesheet primaryFontLarge]];
    _timeLabel = [[UILabel alloc] init];
    
    _recordButton = [[UIButton alloc] init];
    
    [self.view addSubview:_titleField];
    [self.view addSubview:_dateSwitch];
    [self.view addSubview:_timeSwitch];
    [self.view addSubview:_timeLabel];
    [self.view addSubview:_dateLabel];
    [self.view addSubview:_titleLabel];
    [self.view addSubview:_recordButton];
    
    _recording = NO;
  }
  return self;
}

- (void)viewWillAppear:(BOOL)animated {
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
  

  [_recordButton setFrame:CGRectMake((width - SSRecordButtonSize) / 2, SSRecordViewCellHeight * 5, SSRecordButtonSize, SSRecordButtonSize)];
  
  [_recordButton.layer setCornerRadius:SSRecordButtonSize / 2];
  [_recordButton.layer setBackgroundColor:[[SSStylesheet primaryColor] CGColor]];

  [_recordButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
  [_recordButton setTitle:@"Rec." forState:UIControlStateNormal];
  [_recordButton addTarget:self action:@selector(recordButtonTapped) forControlEvents:UIControlEventTouchUpInside];
  
  [_timeLabel setFrame:CGRectMake(0, SSRecordViewCellHeight * 7, width, _timeLabel.frame.size.height)];
  [_timeLabel setTextColor:[SSStylesheet primaryColor]];
  [_timeLabel setFont:[SSStylesheet primaryFont]];
  [_timeLabel setTextAlignment:NSTextAlignmentCenter];
  [_timeLabel setAlpha:0.0f];
  
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
  CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"cornerRadius"];
  CAAnimationGroup *group = [CAAnimationGroup animation];
  
  if (_recording) {
    [self stopRecording];
    animation.toValue = [NSNumber numberWithFloat:SSRecordButtonSize / 2];
    animation.fromValue = [NSNumber numberWithFloat:0];

    group.fillMode = kCAFillModeBackwards;
    _recording = NO;
    [_recordButton setTitle:@"Rec." forState:UIControlStateNormal];
  } else {
    [self startRecording];
    animation.toValue = [NSNumber numberWithFloat:0.0f];
    animation.fromValue = [NSNumber numberWithFloat:SSRecordButtonSize / 2];
    group.fillMode = kCAFillModeForwards;
    _recording = YES;
    [_recordButton setTitle:@"Stop" forState:UIControlStateNormal];
  }
  
  group.removedOnCompletion = NO;
  group.duration = 0.25;
  [group setAnimations:@[animation]];

  [_recordButton.layer addAnimation:group forKey:@"cornerRadius"];
}

- (void)startRecording {
  AVAudioSession *audioSession = [AVAudioSession sharedInstance];
  NSError *error;
  
  [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
  if (error) {
    NSLog(@"ERROR: %@ %ld %@", [error domain], (long)[error code], [[error userInfo] description]);
    return;
  }
  
  [audioSession setActive:YES error:&error];
  if (error) {
    NSLog(@"ERROR: %@ %ld %@", [error domain], (long)[error code], [[error userInfo] description]);
    return;
  }
  
  NSMutableDictionary *recordingSettings = [[NSMutableDictionary alloc] init];
  [recordingSettings setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
  [recordingSettings setValue:[NSNumber numberWithInteger:AVAudioQualityMedium] forKey:AVEncoderAudioQualityKey];
  [recordingSettings setValue:[NSNumber numberWithFloat:44100.0f] forKey:AVSampleRateKey];
  [recordingSettings setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
  [recordingSettings setValue:[NSNumber numberWithInt: 16] forKey:AVLinearPCMBitDepthKey];
  
  NSMutableDictionary *recordSettings = [[NSMutableDictionary alloc] initWithCapacity:10];

  [recordSettings setObject:[NSNumber numberWithInteger:kAudioFormatMPEG4AAC] forKey: AVFormatIDKey];
  [recordSettings setObject:[NSNumber numberWithFloat:44100.0] forKey: AVSampleRateKey];
  [recordSettings setObject:[NSNumber numberWithInt:2] forKey:AVNumberOfChannelsKey];
  [recordSettings setObject:[NSNumber numberWithInt:12800] forKey:AVEncoderBitRateKey];
  [recordSettings setObject:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
  [recordSettings setObject:[NSNumber numberWithInt: AVAudioQualityHigh] forKey: AVEncoderAudioQualityKey];
  
  NSString *filename = [NSString stringWithFormat:@"%@.m4a", _titleLabel.text];
  _audioFilePath = [[SSHelper documentsDirectory] stringByAppendingPathComponent:filename];
  NSURL *soundFileURL = [NSURL fileURLWithPath:_audioFilePath];
  
  NSLog(@" sound file url %@", soundFileURL);
  
  NSDictionary *settingsCopy = [NSDictionary dictionaryWithDictionary:recordSettings];
  _recorder = [[AVAudioRecorder alloc] initWithURL:soundFileURL settings:settingsCopy error:&error];

  if (error) {
    NSLog(@"ERROR: %@ %ld %@", [error domain], (long)[error code], [[error userInfo] description]);
    return;
  }
  
  [_recorder prepareToRecord];
  
  BOOL audioHWAvailiable = audioSession.inputAvailable;
  if (!audioHWAvailiable) {
    QuickAlert(@"Audio hardware is not avaliable");
  }
  
  [_recorder setDelegate:self];
  [_recorder record];
  [UIView animateWithDuration:0.5f animations:^{
    [_timeLabel setText:@"0:00"];
    [_timeLabel setAlpha:1.0f];
  } completion:nil];
  _updateTimeTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(updateTimeLabel) userInfo:nil repeats:YES];
}

- (void)stopRecording {
  [_recorder stop];
  [_updateTimeTimer invalidate];
  
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    if (!_recording) {
      [UIView animateWithDuration:0.5f animations:^{
        [_timeLabel setAlpha:0.0f];
      } completion:^(BOOL finished) {
        [_timeLabel setText:@""];
      }];
    }
  });
}

- (void)updateTimeLabel {
  NSLog(@"update time label %lf", [_recorder currentTime]);
  [_timeLabel setText:[SSHelper timeFormat:[_recorder currentTime]]];
}

@end
