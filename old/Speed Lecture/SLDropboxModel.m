//
//  SLDropboxModel.m
//  Speed Lecture
//
//  Created by Clay Jones on 12/3/13.
//  Copyright (c) 2013 Clay Jones. All rights reserved.
//

#import "SLDropboxModel.h"

@implementation SLDropboxModel

+(SLDropboxModel *)sharedModel {
    static SLDropboxModel *sModel = nil;
    @synchronized(self) {
        if (sModel == nil)
            sModel = [[self alloc] init];
    }
    return sModel;
}

- (void)refreshSession {
    
}

-(bool) linkWithReset:(BOOL)reset {
    if (reset && [DBSession sharedSession]) {
        _restClient = nil;
        [[DBSession sharedSession] unlinkAll];
    }
    DBSession *session = [[DBSession alloc] initWithAppKey:kDBAppKey appSecret:kDBAppSecret root:kDBRootDropbox];
    [DBSession setSharedSession:session];
    if (![[DBSession sharedSession] isLinked]) {
        [[DBSession sharedSession]
         linkFromController:[[[[UIApplication sharedApplication] keyWindow] subviews] objectAtIndex:0]];

    }
    if ([[DBSession sharedSession] isLinked]) {
        _restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        _restClient.delegate = self;
        [self.restClient loadMetadata:@"/"];
        return true;
    } else {
        return false;
    }
}

-(void) ensureLink {
#if (!TARGET_IPHONE_SIMULATOR)
    if (([DBSession sharedSession] == NULL) ||
        (![[DBSession sharedSession] isLinked])) {
        [self linkWithReset:NO];
    }
#endif
}

- (DBRestClient *)restClient {
    if (_restClient == nil) {
        if ( [[DBSession sharedSession].userIds count] ) {
            _restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
            _restClient.delegate = self;
        }
    }
    
    return _restClient;
}

-(void) refreshFolders {
    [self.restClient loadMetadata:@"/"];
    [self.restClient loadMetadata:@"/Soundspeed"];
}

-(void)restClient:(DBRestClient *)client loadedMetadata:(DBMetadata *)metadata {
    if ([metadata.filename isEqualToString: @"Soundspeed"]) {
        NSMutableArray *newFiles = [[NSMutableArray alloc] init];
        for (int i = 0; i < metadata.contents.count; i++) {
            [newFiles addObject:((DBMetadata *)[metadata.contents objectAtIndex:i]).filename];
        }
        self.filesInLecturesDirectory = [NSArray arrayWithArray:newFiles];
    } else if ([metadata.filename isEqualToString:@"/"]) {
        if (![self metadataContainsLecturesFolder:metadata]) {
            [self.restClient createFolder:@"/Soundspeed"];
        }
    }
}

-(BOOL)metadataContainsLecturesFolder:(DBMetadata *)metadata {
    if (metadata.isDirectory) {
        for (DBMetadata *file in metadata.contents) {
            if ([file.filename isEqualToString:@"Soundspeed"]) {
                return YES;
            }
        }
    }
    return NO;
}

- (void)restClient:(DBRestClient*)client uploadedFile:(NSString*)destPath from:(NSString*)srcPath metadata:(DBMetadata*)metadata {
    if (self.delegate != nil) {
        [self.delegate restClient:client uploadedFile:destPath from:srcPath metadata:metadata];
    }
}

- (void)restClient:(DBRestClient*)client uploadFileFailedWithError:(NSError*)error {
    if (self.delegate != nil) {
        [self.delegate restClient:client uploadFileFailedWithError:error];
    }
}

- (void)restClient:(DBRestClient*)client loadMetadataFailedWithError:(NSError*)error {
    NSLog(@"failed to load meta data");
    [self linkWithReset:YES];
}

@end
