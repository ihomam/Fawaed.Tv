//
//  downloadObject.m
//  FawaedTV
//
//  Created by Homam on 2015-02-24.
//  Copyright (c) 2015 Homam. All rights reserved.
//

#import "downloadManager.h"
#import "AFURLSessionManager.h"
#import "episodeObject.h"
#import "NSObject+FBKVOController.h"
#import "episodsManager.h"

@interface downloadManager()
    @property (nonatomic,strong) AFURLSessionManager *downloadManager;
    @property (nonatomic,strong) NSURL               *urlDocs;
@end

@implementation downloadManager

+(instancetype)sharedDownloadObj{
    static downloadManager *_downloadManager = Nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _downloadManager                        = [downloadManager new];
        _downloadManager.listOfDownloadedObjs   = [NSMutableDictionary new];
        
        NSURLSessionConfiguration *conf = [NSURLSessionConfiguration  defaultSessionConfiguration];//backgroundSessionConfigurationWithIdentifier:@"asd"];
        _downloadManager.downloadManager= [[AFURLSessionManager alloc] initWithSessionConfiguration:conf];
        _downloadManager.urlDocs        = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory
                                                                                 inDomain:NSUserDomainMask
                                                                        appropriateForURL:nil
                                                                                   create:NO
                                                                                    error:nil];
    });
    
    return _downloadManager;
}
-(episodeDownloadObject *)downloadThisEpisode:(episodeObject *)epObj soundFile:(BOOL)isSoundFile{
    // .0 prepare episodeDownloadObject
    episodeDownloadObject *epDownObj        = [episodeDownloadObject new];
    epDownObj.episodeObj                    = epObj;
    epDownObj.episodeDownloadProgress       = Nil;
    epDownObj.episodeDownloadError          = Nil;
    epDownObj.episodeDownloadCurrentStatus  = downloadStatusInitiating;
    
    // .1 prepare file name
    NSString *fileName;
    if (isSoundFile) {
        fileName = [NSString stringWithFormat:@"%d.mp3",epObj.episodeID];
    }else{
        fileName = [NSString stringWithFormat:@"%d.avi",epObj.episodeID];
    }
    
    // 2. check if the file is already been downloading ... then we needs to stop operation
    if (self.listOfDownloadedObjs[epDownObj.episodeObj.episodeLinkMp3]) {
        epDownObj = self.listOfDownloadedObjs[epDownObj.episodeObj.episodeLinkMp3];
        epDownObj.episodeDownloadCurrentStatus = downloadStatusCanceled;
        [epDownObj.episodeDownloadTask cancel];
        return epDownObj;
    }

    // 4. start downloading
    self.listOfDownloadedObjs[epDownObj.episodeObj.episodeLinkMp3] = epDownObj;
    NSProgress *progress    = Nil;
    NSURL *urlDownload      = [NSURL URLWithString:epDownObj.episodeObj.episodeLinkMp3];
    NSURLRequest *request   = [[NSURLRequest alloc]initWithURL:urlDownload];
    NSURLSessionDownloadTask *dt = [self.downloadManager downloadTaskWithRequest:request
                                                                        progress:&progress
                                                                     destination:^NSURL *(NSURL *targetPath, NSURLResponse *response){
                                                                         return [self.urlDocs URLByAppendingPathComponent:fileName];}
                                                               completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error){
                                                                   if (!error) {
                                                                       /// downloaded successfully :) :)
                                                                       epDownObj.episodeDownloadCurrentStatus = downloadStatusFinished;
                                                                       episodeDownloadedFileType EDFType;
                                                                       isSoundFile ? (EDFType = episodeDownloadedFileAudio):(EDFType = episodeDownloadedFileVideo);
                                                                       [episodsManager episodeDownloaded:epObj type:EDFType];
                                                                       [self anObjectIsfinishedDownloadingShouldWeEmptyOurDataSource:epDownObj];
                                                                   }else{
                                                                       [self.listOfDownloadedObjs removeObjectForKey:epDownObj.episodeObj.episodeLinkMp3];
                                                                       epDownObj.episodeDownloadCurrentStatus = downloadStatusCanceled;
                                                                       epDownObj.episodeDownloadError = error;
                                                                   }
                                                                   if (epDownObj.episodeDownloadBlock)
                                                                       epDownObj.episodeDownloadBlock();
                                                                   [self sendAppGlobalNotification];
                                                               }];
    
    epDownObj.episodeDownloadTask = dt;
    [epDownObj.episodeDownloadTask resume];
    [self.KVOController observe:progress
                        keyPath:NSStringFromSelector(@selector(fractionCompleted))
                        options:NSKeyValueObservingOptionNew
                          block:^(id observer, id object, NSDictionary *change) {
                              epDownObj.episodeDownloadCurrentStatus = downloadStatusDownloading;
                              epDownObj.episodeDownloadProgress      = (NSProgress *)object;
                              if (epDownObj.episodeDownloadBlock)
                                  epDownObj.episodeDownloadBlock();
                              [self sendAppGlobalNotification];
                          }];
    return epDownObj;
}
-(void)sendAppGlobalNotification{
    [[NSNotificationCenter defaultCenter]postNotificationName:@"updateProgressTab" object:Nil];
}
-(void)anObjectIsfinishedDownloadingShouldWeEmptyOurDataSource:(episodeDownloadObject *)epDownObj{
    // 0 check how many objects we are downloading right now
        // downloading only one object
        // so empty dataSource anyway
    if (self.listOfDownloadedObjs.count == 1){
        [self.listOfDownloadedObjs removeObjectForKey:epDownObj.episodeObj.episodeLinkMp3];
    }else{
        // downloading many objects
        // check if they are all are finished. if yes then empty datasource
        __block bool shouldDelete;
        [self.listOfDownloadedObjs enumerateKeysAndObjectsUsingBlock:^(id key, episodeDownloadObject *obj, BOOL *stop) {
            shouldDelete = YES;

            if (obj.episodeDownloadProgress.fractionCompleted < 1){
                // we have unfinished business here. stop looping. we'll not empty the datasource
                // go cintune your work 
                shouldDelete = NO;
                *stop = YES;
            }
        }];
        if (shouldDelete) {
            self.listOfDownloadedObjs = Nil;
        }
    }
}
@end