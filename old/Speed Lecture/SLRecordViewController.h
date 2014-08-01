//
//  SLFirstViewController.h
//  Speed Lecture
//
//  Created by Clay Jones on 11/28/13.
//  Copyright (c) 2013 Clay Jones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <DropboxSDK/DropboxSDK.h>
#import "SLDropboxModel.h"
#import "MBProgressHUD.h"
#import "SLHelper.h"

#define kRecordButtonTitleRecord @"Record"
#define kRecordButtonTitleStop @"Stop"

@interface SLRecordViewController : UITableViewController <DBRestClientDelegate, AVAudioRecorderDelegate, UITextFieldDelegate> {
    IBOutlet UIButton *recordButton;
    
    NSString *audioFilePath;
    AVAudioRecorder *recorder;
    SystemSoundID soundID;
    
    BOOL isRecording;
    UIBackgroundTaskIdentifier bgTask;
    NSDictionary *recordingSettings;
}

@property (weak, nonatomic) IBOutlet UILabel *recordingTimeLabel;
@property (weak, nonatomic) IBOutlet UITextField *textFieldTitle;
@property (nonatomic, readonly) DBRestClient *restClient;
@property (weak, nonatomic) IBOutlet UISwitch *switchAppendDate;
@property (weak, nonatomic) IBOutlet UISwitch *switchAppendTime;
@property (weak, nonatomic) IBOutlet UILabel *filenameLabel;
@property NSTimer *timer;
@property MBProgressHUD *hud;

@property SLDropboxModel *model;
@property (weak, nonatomic) IBOutlet UIButton *optionsBarButton;

- (IBAction)recordButtonTapped:(id)sender;
- (void) uploadFile:(NSString *)filename fromPath:(NSString *)sourcePath;


@end
