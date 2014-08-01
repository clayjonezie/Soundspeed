//
//  SLSecondViewController.m
//  Speed Lecture
//
//  Created by Clay Jones on 11/28/13.
//  Copyright (c) 2013 Clay Jones. All rights reserved.
//

#import <DBChooser/DBChooser.h>
#import "SLPlaybackViewController.h"
#import "AFNetworking.h"

@interface SLPlaybackViewController ()

@end

@implementation SLPlaybackViewController


-(id) initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {

    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.hud = [[UIActivityIndicatorView alloc] init];
    if (self.selectedFile == NULL || [self.selectedFile isEqualToString:@""]) {
        self.selectedFile = NULL;
        [self.fileLabel setText:@"No file selected"];
    }
    [self.fileDownloadProgressView setHidden:YES];
    [self.jumpSegmentedControl setSelectedSegmentIndex:UISegmentedControlNoSegment];
    [self.jumpSegmentedControl addTarget:self action:@selector(jumpTime:) forControlEvents:UIControlEventValueChanged];
    
    [self disallowPlaying];
    [self.timeSlider setContinuous:NO];
    
    [self.volumeView setVolumeThumbImage:[UIImage imageNamed:@"slider-thumb.png"] forState:UIControlStateNormal];
    [self.timeSlider setThumbImage:[UIImage imageNamed:@"slider-thumb.png"] forState:UIControlStateNormal];
    // TODO
    // set volume slider to current system volume.
    // set volume slider image to smaller circle
    // set time slider image to a bar or something
    self.navigationItem.leftBarButtonItem.title = @" \u2699";
}

-(void) jumpTime:(id)sender {
    if ([sender isKindOfClass:[UISegmentedControl class]]) {
        
        if (self.scrubbing)
            return;
        
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
        if ([self audioPlayerIsInit]) {
            NSTimeInterval currentTime = [self.audioPlayer currentTime];
            [self.audioPlayer setCurrentTime:currentTime + jump];
            [self updateAudioUIElements];
        }
        [self.jumpSegmentedControl setSelectedSegmentIndex:UISegmentedControlNoSegment];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Turn on remote control event delivery
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    // Set itself as the first responder
    [self becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    DebugLog(@"<--- view did disapear %@", self);
    
    [super viewWillDisappear:animated];
}

-(BOOL) audioPlayerIsInit {
    return self.audioPlayer && self.audioPlayer.url != nil;
}

-(void) chooseFile {
    [[DBChooser defaultChooser] openChooserForLinkType:DBChooserLinkTypeDirect
                                    fromViewController:self completion:^(NSArray *results)
     {
         if ([results count]) {
             [self disallowPlaying];
             [self pauseAudio];
             DBChooserResult *result = [results objectAtIndex:0];
             if (result.size < kFileSizeThreshold) {
                 [self.fileLabel setText:result.name];
                 [self loadFile:result.link toName:result.name];
             } else {
                 QuickAlert(@"that file was way to large");
             }
         } else {
             // User canceled the action
         }
     }];
}

-(void) loadFile:(NSURL *)link toName:(NSString *)name {
    [self emptyTempDirectory];
    
    // things for url request and loading indicator
    self.fileDownloadProgressView.progress = 0;
    NSURLRequest *req = [[NSURLRequest alloc] initWithURL:link];
    AFURLConnectionOperation *operation = [[AFURLConnectionOperation alloc] initWithRequest:req];
    
    NSString *localPath = [[NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), name] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURL *localURL = [NSURL URLWithString:[NSString stringWithFormat:@"file://%@", localPath]];
    
    // make file to stream into
    [[NSFileManager defaultManager] createFileAtPath:[NSString stringWithFormat:@"%@", localPath]
                                            contents:nil
                                          attributes:nil];
    
    NSOutputStream *stream = [[NSOutputStream alloc] initWithURL:localURL append:NO];
    
    operation.outputStream = stream;
    [self.fileDownloadProgressView setHidden:NO];
    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        self.fileDownloadProgressView.progress = (float)totalBytesRead / totalBytesExpectedToRead;
    }];
    [operation setCompletionBlock:^{
        [self.fileDownloadProgressView setHidden:YES];
        [self fileDidLoad:localURL];

    }];
    [operation start];
}

-(void) fileDidLoad: (NSURL *)localURL {
    NSError* err;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&err];

    if (err) {
        DebugLog(@"<--- error reading data:  %@", [err description]);
    }

    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:localURL error:&err];
    [self.audioPlayer setEnableRate:YES];

    if (err) {
        DebugLog(@"error %@", [err description]);
    }
    
    [self.audioPlayer setDelegate:self];
    [self.audioPlayer prepareToPlay];
    [self allowPlaying];
    [self setupAudioUIElements];
    
    [self updateNowPlayingInfo];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)timeSliderEditingDidBegin:(id)sender {
    DebugLog(@"<--- time slider editing began");
}

- (IBAction)timeSliderEditingDidEnd:(id)sender {
    DebugLog(@"<--- time slider editing did end");
}

- (IBAction)playButtonTapped:(id)sender {
    [self.timer invalidate];
    if (self.audioPlayer.playing) {
        [self pauseAudio];
    } else {
        // checks if audio player is init properly
        if ([self audioPlayerIsInit]) {
            [self playAudio];
        }
    }
}

- (IBAction)playbackSpeedButtonTapped:(id)sender {
    switch (self.currentPlaybackSpeed) {
        case one:
            self.currentPlaybackSpeed = oneAndAHalf;
            break;
            
        case oneAndAHalf:
            self.currentPlaybackSpeed = two;
            break;
        
        case two:
            self.currentPlaybackSpeed = half;
            break;
            
        case half:
            self.currentPlaybackSpeed = one;
            break;
            
        default:
            break;
    }
    
    NSString *newLabel;
    float newRate;
    switch (self.currentPlaybackSpeed) {
        case one:
            newLabel = @"1x";
            newRate = 1;
            break;
            
        case oneAndAHalf:
            newRate = 1.5;
            newLabel = @"1.5x";
            break;
            
        case two:
            newRate = 2;
            newLabel = @"2x";
            break;
            
        case half:
            newRate = .5;
            newLabel = @"0.5x";
            break;
            
        default:
            break;
    }
    
    [self.timeSpeedButton setTitle:newLabel forState:UIControlStateNormal];
    [self.audioPlayer setRate:newRate];
}

- (void)playAudio {
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(updateAudioUIElements) userInfo:nil repeats:YES];
    [self.audioPlayer play];
    [self.playPauseButton setTitle:@"Pause" forState:UIControlStateNormal];
    
    [self updateNowPlayingInfo];
}

- (void)pauseAudio {
    [self.audioPlayer pause];
    [self.playPauseButton setTitle:@"Play" forState:UIControlStateNormal];
    
    [self updateNowPlayingInfo];
}

- (IBAction)chooseFileButtonTapped:(id)sender {
    [self chooseFile];
}

-(void)allowPlaying {
    [self.playPauseButton setEnabled:YES];
    [self.jumpSegmentedControl setEnabled:YES];
}

-(void)disallowPlaying {
    [self.playPauseButton setEnabled:NO];
    [self.jumpSegmentedControl setEnabled:NO];
    [self.timeSlider setValue:0 animated:YES];
    [self.timeSlider setEnabled:NO];
}

-(void)setupAudioUIElements {
    self.currentPlaybackSpeed = half    ;
    [self playbackSpeedButtonTapped:nil];
    
    [self.playPauseButton setTitle:@"Play" forState:UIControlStateNormal];
    [self.timeSlider setEnabled:YES];
    [self.timeSlider setValue:0 animated:YES];
    [self.timeSlider setMaximumValue:[self.audioPlayer duration]];
    self.timeSlider.minimumValue = 0;
    [self.maxTimeLabel setText:[SLHelper timeFormat:[self.audioPlayer duration]]];
    [self.currentTimeLabel setText:[SLHelper timeFormat:0]];
}

-(void)updateAudioUIElements {
    // update slider to show what it needs to
    if (!self.scrubbing) {
        self.timeSlider.value = [self.audioPlayer currentTime];
        [self.currentTimeLabel setText:[SLHelper timeFormat:[self.timeSlider value]]];
    }
}

- (IBAction)changeTime:(id)sender {
    self.scrubbing = NO;
    
    [self.audioPlayer setCurrentTime:self.timeSlider.value];
    [self updateAudioUIElements];
}

- (void)setCurrentAudioTime:(float)value {
    [self.audioPlayer setCurrentTime:value];
}

- (NSTimeInterval)getCurrentAudioTime {
    return [self.audioPlayer currentTime];
}

- (float)getAudioDuration {
    return [self.audioPlayer duration];
}

#pragma mark audio player delegates

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    DebugLog(@"<--- audio player finished and success: %d", flag);
    // Turn off remote control event delivery
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    
    // Resign as first responder
    [self resignFirstResponder];
    [self pauseAudio];
}

- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player {
    [self pauseAudio];
    DebugLog(@"<--- player began inturruption");
}

/* audioPlayerEndInterruption:withOptions: is called when the audio session interruption has ended and this player had been interrupted while playing. */
/* Currently the only flag is AVAudioSessionInterruptionFlags_ShouldResume. */
- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player withOptions:(NSUInteger)flags {
    [self playAudio];   
    DebugLog(@"<--- player ended inturruption");
}

-(void)emptyTempDirectory {
    NSString *tempPath = NSTemporaryDirectory();
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *dirContents = [fileManager contentsOfDirectoryAtPath:tempPath error:nil];
    if (dirContents) {
        for (int i = 0; i < [dirContents count]; i++) {
            NSString *contentsOnly = [NSString stringWithFormat:@"%@%@", tempPath, [dirContents objectAtIndex:i]];
            [fileManager removeItemAtPath:contentsOnly error:nil];
        }
    }
}

- (IBAction)timeSliderTouchDragInside:(id)sender {
    [self timeSliderMoved];
}

- (IBAction)timeSliderTouchDragOutside:(id)sender {
    [self timeSliderMoved];
}

-(void) timeSliderMoved {
    // when the time slider is moved but not released (it's not continuous)
    [self.currentTimeLabel setText:[SLHelper timeFormat:[self.timeSlider value]]];
    self.scrubbing = YES;
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
                       [self.fileLabel text],
                       @"",
                       [NSNumber numberWithFloat:[self.audioPlayer duration]],
                       [NSNumber numberWithFloat:[self.audioPlayer rate]],
                       [NSNumber numberWithDouble:[self.audioPlayer currentTime]],
                       nil];
    
    NSDictionary *mediaInfo = [NSDictionary dictionaryWithObjects:values forKeys:keys];
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:mediaInfo];
}

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
                if (self.audioPlayer.isPlaying) {
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
