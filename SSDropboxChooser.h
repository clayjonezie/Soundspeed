//
//  SSDropboxChooser.h
//  Soundspeed
//
//  Created by Clay on 8/2/14.
//  Copyright (c) 2014 Clay Jones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Dropbox/Dropbox.h>

@class SSDropboxChooser;
@protocol SSDropboxChooserDelegate <NSObject>

-(void)dropboxChooser:(SSDropboxChooser *)chooser choseFile:(DBFileInfo *)fileInfo;

@end

@interface SSDropboxChooser : UIView<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, assign) id<SSDropboxChooserDelegate> delegate;

- (id)initWithFrame:(CGRect)frame andFiles:(NSArray *)fileInfos;

@end
