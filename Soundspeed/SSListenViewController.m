//
//  SSListenViewController.m
//  Soundspeed
//
//  Created by Clay on 7/31/14.
//  Copyright (c) 2014 Clay Jones. All rights reserved.
//

#import "SSListenViewController.h"
#import "SSDropboxHelper.h"
@interface SSListenViewController ()

@property (nonatomic) UISegmentedControl *jumpControl;
@property (nonatomic) UIButton *playbackButton;
@property (nonatomic) CAShapeLayer *playbackButtonLayer;

@property (nonatomic) UIButton *playbackSpeedButton;
@property (nonatomic) UILabel *recordingLabel;
@property (nonatomic) UISlider *playbackPositionSlider;
@property (nonatomic) UIProgressView *downloadSlider;

@property (nonatomic) BOOL scrubbing;
@property (nonatomic) AVAudioPlayer *player;
@property (nonatomic) NSTimer *playbackTimer;
@property (nonatomic) SSPlaybackSpeed playbackSpeed;

@property (nonatomic) SSDropboxChooser *chooser;

@property (nonatomic) UIActivityIndicatorView *spinner;

@end

@implementation SSListenViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    [self.view setBackgroundColor:[UIColor whiteColor]];
    _chooseButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Recordings" style:UIBarButtonItemStylePlain target:self action:@selector(showRecordings:)];
    [_chooseButtonItem setTintColor:[SSStylesheet primaryColor]];
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  NSArray *jumpControlStrings = @[@"\u2190 5m", @"\u2190 30s", @"30s \u2192", @"5m \u2192"];
  _jumpControl = [[UISegmentedControl alloc] initWithItems:jumpControlStrings];
  [_jumpControl setTintColor:[SSStylesheet primaryColor]];
  [_jumpControl setTitleTextAttributes:@{NSFontAttributeName: [SSStylesheet primaryFontLarge],
                                         NSBaselineOffsetAttributeName: [NSNumber numberWithFloat:-2.0f]}
                              forState:UIControlStateNormal];
  [_jumpControl addTarget:self action:@selector(jumpControlTapped:) forControlEvents:UIControlEventValueChanged];
  [self.view addSubview:_jumpControl];
  
  _recordingLabel = [UILabel new];
  [_recordingLabel setTextColor:[SSStylesheet primaryColor]];
  [_recordingLabel setFont:[SSStylesheet primaryFontLarge]];
  [self.view addSubview:_recordingLabel];
  
  _playbackButton = [UIButton new];
  [_playbackButton addObserver:self forKeyPath:@"enabled" options:NSKeyValueObservingOptionNew context:nil];

  [self.view addSubview:_playbackButton];
  [_playbackButton setTitle:@"foo" forState:UIControlStateNormal];
  
  _playbackSpeedButton = [UIButton new];
  [_playbackSpeedButton.titleLabel setFont:[SSStylesheet primaryFontLarge]];
  [_playbackSpeedButton setTitleColor:[SSStylesheet primaryColor] forState:UIControlStateNormal];
  [_playbackSpeedButton setTitleColor:[SSStylesheet primaryColorFaded] forState:UIControlStateHighlighted];
  [_playbackSpeedButton setTitleColor:[SSStylesheet primaryColorFaded] forState:UIControlStateDisabled];
  [_playbackSpeedButton setTitle:@"1.5x" forState:UIControlStateNormal];
  [self.view addSubview:_playbackSpeedButton];
  
  [self interfaceHasNoFile];
}

-(void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
  [self becomeFirstResponder];
}

-(void)viewWillLayoutSubviews {
  CGFloat width = self.view.frame.size.width;
  CGFloat height = self.view.frame.size.height;
  CGFloat segmentHeight = 44.0f;
  CGFloat margin = 7.0f;
  
  [_jumpControl setFrame:CGRectMake(margin, margin, width - 2 * margin, segmentHeight - 2 * margin)];
  [_recordingLabel setFrame:CGRectMake(margin, segmentHeight, width - 2 * margin, segmentHeight)];
  
  CGFloat playbackButtonSize = 50.0f;
  [_playbackButton setFrame:CGRectMake((width - playbackButtonSize) / 2, height - playbackButtonSize - margin * 3, playbackButtonSize, playbackButtonSize)];
  
  [_playbackButtonLayer removeFromSuperlayer];
  if ([_player isPlaying]) {
    _playbackButtonLayer = [self pauseButtonLayerInFrame:_playbackButton.frame];
  } else {
    _playbackButtonLayer = [self playButtonLayerInFrame:_playbackButton.frame];
  }
  [_playbackButton.layer addSublayer:_playbackButtonLayer];
  [_playbackButton addTarget:self action:@selector(playButtonTapped) forControlEvents:UIControlEventTouchUpInside];
  [_playbackSpeedButton sizeToFit];
  [_playbackSpeedButton setFrame:CGRectMake((width * 3/4) - _playbackSpeedButton.frame.size.width / 2, (_playbackButton.frame.origin.y + playbackButtonSize / 2) - _playbackSpeedButton.frame.size.height / 2, _playbackSpeedButton.frame.size.width, _playbackSpeedButton.frame.size.height)];
  [_playbackButton setEnabled:_playbackButton.enabled];
}

- (void)interfaceHasNoFile {
  [_jumpControl setEnabled:NO];
  [_recordingLabel setTextColor:[SSStylesheet primaryColorFaded]];
  [_recordingLabel setText:@"No file selected"];
  [_playbackSpeedButton setEnabled:NO];
  [_playbackButton setEnabled:NO];
}

- (void)interfaceHasFile:(NSString *)file {
  [_jumpControl setEnabled:YES];
  [_recordingLabel setTextColor:[SSStylesheet primaryColor]];
  [_recordingLabel setText:file];
  [_playbackSpeedButton setEnabled:YES];
  [_playbackButton setEnabled:YES];
}

- (void)jumpControlTapped:(id)sender {
  if ([sender isKindOfClass:[UISegmentedControl class]]) {
    
    if (_scrubbing) {
      return;
    }
    
    NSInteger index = [(UISegmentedControl *)sender selectedSegmentIndex];
    int jump = 0;
    switch (index) {
      case 0:
        jump = 5 * 60 * -1;
        // back 5m
        break;
      case 1:
        jump = -30;
        // back 30s
        break;
      case 2:
        jump = 30;
        // forwards 30s
        break;
      case 3:
        jump = 60 * 5;
        // forwards 5m
        break;
        
      default:
        break;
    }
    
//    if ([self audioPlayerIsInit]) {
//      NSTimeInterval currentTime = [self.audioPlayer currentTime];
//      [self.audioPlayer setCurrentTime:currentTime + jump];
//      [self updateAudioUIElements];
//    }
    [_jumpControl setSelectedSegmentIndex:UISegmentedControlNoSegment];
  }
}

- (void)showRecordings:(id)sender {
  if (![sender isKindOfClass:[UIBarButtonItem class]])
    return;
  
  BOOL show = [[(UIBarButtonItem*)sender title] isEqualToString:@"Recordings"];
  
  if (show) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      DBFilesystem *filesystem = [SSDropboxHelper sharedFilesystem];
      
      NSError *error;
      DBPath *path = [[DBPath root] childPath:@"Soundspeed"];
      
      if (!filesystem.completedFirstSync) {
        dispatch_async(dispatch_get_main_queue(), ^{
          [_chooseButtonItem setEnabled:NO];
          _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
          [_spinner setFrame:CGRectMake(self.view.frame.size.width / 2 - 10, self.view.frame.size.height / 2 - 10, 10, 10)];
          [_spinner startAnimating];
          [self.view addSubview:_spinner];
          QuickAlert(@"We need to sync with Dropbox. This should take less than a minute and only happens once.");
        });
      }
      
      NSArray *fileInfos = [filesystem listFolder:path error:&error];
      if (error) {
        CJERROR(error);
      }
      
      dispatch_async(dispatch_get_main_queue(), ^{
        [_chooseButtonItem setEnabled:YES];
        [_spinner removeFromSuperview];
        _spinner = nil;

        [_chooseButtonItem setTitle:@"Cancel"];
        _chooser = [[SSDropboxChooser alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)
                                                  andFiles:fileInfos];
        _chooser.delegate = self;
        
        [_chooser setAlpha:0.0f];
        [self.view addSubview:_chooser];
        [UIView animateWithDuration:0.25f animations:^{
          [_chooser setAlpha:1.0f];
        } completion:^(BOOL finished) {
          
        }];
      });
    });
  } else {
    [_chooseButtonItem setTitle:@"Recordings"];
    [UIView animateWithDuration:0.25f animations:^{
      [_chooser setAlpha:0.0f];
    } completion:^(BOOL finished) {
      [_chooser removeFromSuperview];
      _chooser = nil;
    }];
  }
}

- (CAShapeLayer *)playButtonLayerInFrame:(CGRect)frame {
  CAShapeLayer *layer = [[CAShapeLayer alloc] init];
  [layer setFillColor:[[UIColor clearColor] CGColor]];
  CGFloat height = frame.size.height;
  CGFloat width = frame.size.width;
  CGMutablePathRef path = CGPathCreateMutable();
  
  CGPathMoveToPoint(path, NULL, 0, 0);
  CGPathAddLineToPoint(path, NULL, width - 1, height / 2);
  CGPathAddLineToPoint(path, NULL, 0, height - 1);
  CGPathAddLineToPoint(path, NULL, 0, 0);
  
  [layer setPath:path];
  [layer setStrokeColor:[[SSStylesheet primaryColor] CGColor]];
  [layer setPosition:CGPointMake(0, 0)];
  
  CGPathRelease(path);
  
  return layer;
}

- (CAShapeLayer *)pauseButtonLayerInFrame:(CGRect)frame {
  CAShapeLayer *layer = [[CAShapeLayer alloc] init];
  [layer setFillColor:[[UIColor clearColor] CGColor]];
  CGFloat height = frame.size.height;
  CGFloat width = frame.size.width;
  CGFloat third = width / 3;
  CGMutablePathRef path = CGPathCreateMutable();
  
  CGPathMoveToPoint(path, NULL, 0, 0);
  CGPathAddLineToPoint(path, NULL, third, 0);
  CGPathAddLineToPoint(path, NULL, third, height - 1);
  CGPathAddLineToPoint(path, NULL, 0, height - 1);
  CGPathAddLineToPoint(path, NULL, 0, 0);
  
  CGPathMoveToPoint(path, NULL, third * 2, 0);
  CGPathAddLineToPoint(path, NULL, width - 1, 0);
  CGPathAddLineToPoint(path, NULL, width -1, height - 1);
  CGPathAddLineToPoint(path, NULL, third * 2, height - 1);
  CGPathAddLineToPoint(path, NULL, third * 2, 0);
  
  [layer setPath:path];
  [layer setStrokeColor:[[SSStylesheet primaryColor] CGColor]];
  [layer setPosition:CGPointMake(0, 0)];
  
  CGPathRelease(path);
  
  return layer;
}

- (void)playButtonTapped {
  if (_player.isPlaying) {
    [self pauseAudio];
  } else {
    [self playAudio];
  }
}

-(void)dropboxChooser:(SSDropboxChooser *)chooser choseFile:(DBFileInfo *)fileInfo {
  [self pauseAudio];
  [self showRecordings:_chooseButtonItem];
  
  [self interfaceHasNoFile];
  [_recordingLabel setText:@"Downloading..."];
  
  __block DBError *dbError;
  DBFile *file = [[DBFilesystem sharedFilesystem] openFile:fileInfo.path error:&dbError];
  
  if (dbError) {
    CJERROR(dbError);
  }
  
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    
    NSData *recordingData;
    if (!file.status.cached) {
      dispatch_async(dispatch_get_main_queue(), ^{
        _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [_spinner setFrame:CGRectMake(self.view.frame.size.width / 2 - 10, self.view.frame.size.height / 2 - 10, 10, 10)];
        [_spinner startAnimating];
        [self.view addSubview:_spinner];
      });
      recordingData = [file readData:&dbError];
      dispatch_async(dispatch_get_main_queue(), ^{
        [_spinner removeFromSuperview];
        _spinner = nil;
      });
    } else {
      recordingData = [file readData:&dbError];
    }
    
    if (dbError) {
      CJERROR(dbError);
      QuickAlert(@"Error reading file");
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
      NSError *error;
      [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
      if (error) {
        CJERROR(error);
        return;
      }
      
      _player = [[AVAudioPlayer alloc] initWithData:recordingData error:&error];
      
      if (error) {
        CJERROR(error);
        return;
      }
      
      [_player setEnableRate:YES];
      [_player setDelegate:self];
      [_player prepareToPlay];
      
      [self interfaceHasFile:fileInfo.path.name];
    });
  });
}

- (void)pauseAudio {
  [_player pause];
  
  [_playbackButtonLayer removeFromSuperlayer];
  _playbackButtonLayer = [self playButtonLayerInFrame:_playbackButton.frame];
  [_playbackButton.layer addSublayer:_playbackButtonLayer];
  
  [self updateNowPlayingInfo];
}

- (void)updateAudioUIElements {
  
}

- (void)playAudio {
  _playbackTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(updateAudioUIElements) userInfo:nil repeats:YES];
  [_player play];
  
  [_playbackButtonLayer removeFromSuperlayer];
  _playbackButtonLayer = [self pauseButtonLayerInFrame:_playbackButton.frame];
  [_playbackButton.layer addSublayer:_playbackButtonLayer];
  
  [self updateNowPlayingInfo];
}

-(void) updateNowPlayingInfo {
  NSArray *keys = [NSArray arrayWithObjects:
                   MPMediaItemPropertyTitle,
                   MPMediaItemPropertyArtist,
                   MPMediaItemPropertyPlaybackDuration,
                   MPNowPlayingInfoPropertyPlaybackRate,
                   MPNowPlayingInfoPropertyElapsedPlaybackTime,
                   nil];
  NSArray *values = [NSArray arrayWithObjects:
                     [_recordingLabel text],
                     @"",
                     [NSNumber numberWithFloat:[_player duration]],
                     [NSNumber numberWithFloat:[_player rate]],
                     [NSNumber numberWithDouble:[_player currentTime]],
                     nil];
  
  NSDictionary *mediaInfo = [NSDictionary dictionaryWithObjects:values forKeys:keys];
  [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:mediaInfo];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
  if (object == _playbackButton) {
    if ([change objectForKey:@"new"] == [NSNumber numberWithInteger:1]) {
      [_playbackButtonLayer setStrokeColor:[[SSStylesheet primaryColor] CGColor]];
    } else {
      [_playbackButtonLayer setStrokeColor:[[SSStylesheet primaryColorFaded] CGColor]];
    }
  }
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {}
- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error {}
- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player {}
- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player withOptions:(NSUInteger)flags {}
- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player withFlags:(NSUInteger)flags {}

- (void)remoteControlReceivedWithEvent:(UIEvent *)receivedEvent {
  if (receivedEvent.type == UIEventTypeRemoteControl) {
    switch (receivedEvent.subtype) {
      case UIEventSubtypeRemoteControlPause:
        [self pauseAudio];
        break;
        
      case UIEventSubtypeRemoteControlPlay:
        [self playAudio];
        break;
        
      case UIEventSubtypeRemoteControlTogglePlayPause:
        if (_player.isPlaying) {
          [self pauseAudio];
        } else {
          [self playAudio];
        }
        break;
        
      default:
        break;
    }
  }
}

@end
