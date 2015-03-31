//
//  episodsManager.h
//  FawaedTV
//
//  Created by Homam on 2015-03-30.
//  Copyright (c) 2015 Homam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "episodeObject.h"
typedef NS_ENUM(NSUInteger, episodeDownloadedFileType) {
    episodeDownloadedFileAudio,
    episodeDownloadedFileVideo,
};

@interface episodsManager : NSObject
+(void)episodeDownloaded:(episodeObject *)epObj type:(episodeDownloadedFileType)epType;
+(void)episodeDeleted:(episodeObject *)epObj type:(episodeDownloadedFileType)epType;
@end
