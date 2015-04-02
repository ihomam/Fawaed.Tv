//
//  downloadObject.h
//  FawaedTV
//
//  Created by Homam on 2015-02-24.
//  Copyright (c) 2015 Homam. All rights reserved.
//


#import <Foundation/Foundation.h>

@protocol downloadTasksQueueProtocol <NSObject>
    -(void)startAnotherDownloadTask;
@end
@interface downloadTasksQueue : NSObject
    @property (nonatomic,weak) id<downloadTasksQueueProtocol> delegate;
@end

//#############################################################################//
//#############################################################################//
//#############################################################################//

@class episodeObject;
@class episodeDownloadObject;
@interface downloadManager : NSObject

+(instancetype)sharedDownloadObj;
-(episodeDownloadObject *)downloadThisEpisode:(episodeObject *)epObj soundFile:(BOOL)isSoundFile;
@property (nonatomic,strong) NSMutableDictionary *listOfDownloadedObjs;
@end