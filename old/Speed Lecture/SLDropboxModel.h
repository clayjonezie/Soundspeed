//
//  SLDropboxModel.h
//  Speed Lecture
//
//  Created by Clay Jones on 12/3/13.
//  Copyright (c) 2013 Clay Jones. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DropboxSDK/DropboxSDK.h>

@interface SLDropboxModel : NSObject <DBRestClientDelegate>

@property (nonatomic) DBRestClient *restClient;
@property NSArray *filesInLecturesDirectory;
@property (nonatomic, assign) id<DBRestClientDelegate> delegate;

+(SLDropboxModel *)sharedModel;
-(bool) linkWithReset:(BOOL)reset;
-(void) ensureLink;
-(DBRestClient *)restClient;
-(void) refreshFolders;

@end