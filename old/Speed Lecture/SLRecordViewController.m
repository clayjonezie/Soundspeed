//
//  SLFirstViewController.m
//  Speed Lecture
//
//  Created by Clay Jones on 11/28/13.
//  Copyright (c) 2013 Clay Jones. All rights reserved.
//

#import "SLRecordViewController.h"

@interface SLRecordViewController ()

@end

@implementation SLRecordViewController

- (id) initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        isRecording = NO;
        self.model = [SLDropboxModel sharedModel];
        self.model.delegate = self;
        audioFilePath = NULL;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.switchAppendDate addTarget:self action:@selector(setFilename) forControlEvents:UIControlEventValueChanged];
    [self.switchAppendTime addTarget:self action:@selector(setFilename) forControlEvents:UIControlEventValueChanged];
    [self.model refreshFolders];
    [self.textFieldTitle addTarget:self action:@selector(setFilename) forControlEvents:UIControlEventEditingChanged];
    [self setFilename];
    self.hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:self.hud];
    
    [self.recordingTimeLabel setHidden:YES];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setFilename];
    
    if (!isRecording) {
        //[SLHelper logCachesDirectory];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)recordButtonTapped:(id)sender {
    if (isRecording) {
        [self stopRecording];
        isRecording = NO;
        [recordButton setTitle:kRecordButtonTitleRecord forState:UIControlStateNormal];
    } else {
        [self startRecording];
        isRecording = YES;
        [recordButton setTitle:kRecordButtonTitleStop forState:UIControlStateNormal];
    }
}

-(void)startRecording {
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *err = Nil;
    // this could be a different category, perhaps just record
    [audioSession setCategory:AVAudioSessionCategoryRecord error:&err];
    if (err) {
        DebugLog(@"ERROR: %@ %ld %@", [err domain], (long)[err code], [[err userInfo] description]);
        return;
    }
    
    [audioSession setActive:YES error:&err];
    
    if (err) {
        DebugLog(@"ERROR: %@ %ld %@", [err domain], (long)[err code], [[err userInfo] description]);
        return;
    }
    
    recordingSettings = [[NSMutableDictionary alloc] init];
    
    [recordingSettings setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    [recordingSettings setValue:[NSNumber numberWithInteger:AVAudioQualityMedium] forKey:AVEncoderAudioQualityKey];
    [recordingSettings setValue:[NSNumber numberWithFloat:22050.0f] forKey:AVSampleRateKey];
    [recordingSettings setValue:[NSNumber numberWithInt: 1] forKey:AVNumberOfChannelsKey];
    [recordingSettings setValue:[NSNumber numberWithInt: 8] forKey:AVLinearPCMBitDepthKey];
    
    NSString *filename = [NSString stringWithFormat:@"%@.m4a",[self filenameLabel].text];
    audioFilePath = [[SLHelper cachesDirectory] stringByAppendingPathComponent:filename];
    NSURL *soundFileURL = [NSURL fileURLWithPath:audioFilePath];
    
    err = nil;
    NSDictionary *settingsCopy = [NSDictionary dictionaryWithDictionary:recordingSettings];
    recorder = [[AVAudioRecorder alloc] initWithURL:soundFileURL settings:settingsCopy error:&err];
    
    if (err) {
        DebugLog(@"ERROR: %@ %ld %@", [err domain], (long)[err code], [[err userInfo] description]);
    }
    
    [recorder prepareToRecord];
    recorder.meteringEnabled = YES;
    
    BOOL audioHWAvailiable = audioSession.inputAvailable;
    if (!audioHWAvailiable) {
        QuickAlert(@"Audio hardware is not avaliable");
    }
    
    [recorder record];
    [self.recordingTimeLabel setHidden:NO];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateTimeLabel) userInfo:nil repeats:YES];
}

-(void)stopRecording {
    [recorder stop];
    [self.timer invalidate];
    [self.recordingTimeLabel setText:[SLHelper timeFormat:0]];
    
    NSString *filename = [NSString stringWithFormat:@"%@.m4a",[self filenameLabel].text];
    [self uploadFile:filename fromPath:audioFilePath];
}

-(void) uploadFile:(NSString *)filename fromPath:(NSString *)sourcePath {
    NSString *destDir = @"/Soundspeed";
    [[MBProgressHUD HUDForView:self.view] setMode:MBProgressHUDModeIndeterminate];
    [[MBProgressHUD HUDForView:self.view] setLabelText:@"uploading..."];
    [[MBProgressHUD HUDForView:self.view] show:YES];
    
    bgTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        DebugLog(@"<--- background task is expiring");
        [[UIApplication sharedApplication] endBackgroundTask:bgTask];
    }];
    NSLog(@"attempting to upload %@ from %@", filename, sourcePath);
    [[self.model restClient] uploadFile:filename toPath:destDir withParentRev:nil fromPath:audioFilePath];
}

- (void)restClient:(DBRestClient*)client uploadedFile:(NSString*)destPath
              from:(NSString*)srcPath metadata:(DBMetadata*)metadata {
    
    [[MBProgressHUD HUDForView:self.view] hide:YES];
    [self.recordingTimeLabel setHidden:YES];
    
    // remove the file from caches if it is uploaded
    NSError *err = Nil;
    [[NSFileManager defaultManager] removeItemAtPath:audioFilePath error:&err];
    if (err) {
        DebugLog(@"ERROR: %@ %ld %@", [err domain], (long)[err code], [[err userInfo] description]);
    }
    audioFilePath = NULL;
    
    [[UIApplication sharedApplication] endBackgroundTask:bgTask];
}

- (void)restClient:(DBRestClient*)client uploadFileFailedWithError:(NSError*)error {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    QuickAlert(@"File upload failed. Retry in the options menu.");
}

-(void) setFilename {
    NSString *fn = [self filenameForSound];
    [self.filenameLabel setText:fn];
}

-(BOOL) filenameIsInModel:(NSString *)filename {
    for (NSString *fn in self.model.filesInLecturesDirectory) {
        if ([fn isEqualToString:filename]) {
            DebugLog(@"<--- checking file: %@", fn);    
            return YES;
        }
    }
    return NO;
}

-(NSString *)filenameForSound {
    NSMutableString *fn = [[NSMutableString alloc] initWithString:
                           [self.textFieldTitle.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
    
    NSDate *now = [NSDate date];
    
    if (self.switchAppendDate.on) {
        [fn appendFormat:@" %@",[NSDateFormatter localizedStringFromDate:now dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterNoStyle]];
    }
    if (self.switchAppendTime.on) {
        [fn appendFormat:@" %@", [NSDateFormatter localizedStringFromDate:now dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle]];
    }
    fn = [[fn stringByReplacingOccurrencesOfString:@"/" withString:@"-"] mutableCopy];
    
    if ([fn isEqualToString:@""]) {
        [fn appendString:@"Untitled"];
    }
    return [NSString stringWithString:fn];
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

-(void) updateTimeLabel {
    [self.recordingTimeLabel setText:[SLHelper timeFormat:[recorder currentTime]]];
}

@end
