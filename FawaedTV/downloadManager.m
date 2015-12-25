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

@interface downloadTasksQueue()
    @property (nonatomic,strong) NSMutableArray *tasks;
@end
@implementation downloadTasksQueue
-(void)removeObject:(id)anObject{
    [self.tasks removeObject:anObject];
    [self.delegate startAnotherDownloadTask];
}
-(void)addObject:(id)anObject{
    if(self.tasks.count == 0){
        [self.tasks addObject:anObject];
        [self.delegate startAnotherDownloadTask];
    }else{
        [self.tasks addObject:anObject];
    }
}
-(id)firstObject{
    return [self.tasks firstObject];
}
-(NSMutableArray *)tasks{
    if (!_tasks)
        _tasks = [NSMutableArray new];
    return _tasks;
}
@end

@interface downloadManager()<downloadTasksQueueProtocol>
    @property (nonatomic,strong) AFURLSessionManager *downloadManager;
    @property (nonatomic,strong) NSURL               *urlDocs;
    @property (nonatomic,strong) downloadTasksQueue  *listQueue;
@end

@implementation downloadManager

+(instancetype)sharedDownloadObj{
    static downloadManager *_downloadManager = Nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _downloadManager                        = [downloadManager new];
        _downloadManager.listOfDownloadedObjs   = [NSMutableDictionary new];
        _downloadManager.listQueue              = [downloadTasksQueue new];
        _downloadManager.listQueue.delegate     = _downloadManager;
        
        /// check if we can build NSURLSessionConfiguration using ios 8 class method or not 
        NSURLSessionConfiguration *conf;
        if([[NSURLSessionConfiguration class]respondsToSelector:@selector(backgroundSessionConfigurationWithIdentifier:)]){
            conf = [NSURLSessionConfiguration   backgroundSessionConfigurationWithIdentifier:[NSBundle mainBundle].bundleIdentifier];
        }else{
            conf = [NSURLSessionConfiguration   backgroundSessionConfiguration:[NSBundle mainBundle].bundleIdentifier];
        }
        
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
    epDownObj.episodeDownloadType           = isSoundFile;

    // .1 prepare file name
    NSString *fileName;
    if (isSoundFile) {
        fileName = [NSString stringWithFormat:@"%d.mp3",epObj.episodeID];
    }else{
        fileName = [NSString stringWithFormat:@"%d.avi",epObj.episodeID];
    }
    /// @TODO
    // 2. check if the file is already been downloading ... then we needs to stop operation
    episodeDownloadObject *epDObjOld;
    (isSoundFile) ?
    (epDObjOld = self.listOfDownloadedObjs[epDownObj.episodeObj.episodeLinkMp3]):
    (epDObjOld = self.listOfDownloadedObjs[epDownObj.episodeObj.episodeLinkAvi]);
    
    if (epDObjOld) {
        epDownObj = epDObjOld;
        epDownObj.episodeDownloadCurrentStatus = downloadStatusCanceled;
        [epDownObj.episodeDownloadTask cancel];
        return epDownObj;
    }

    // 4. start downloading
    if (isSoundFile) {
        self.listOfDownloadedObjs[epDownObj.episodeObj.episodeLinkMp3] = epDownObj;
    }else{
        self.listOfDownloadedObjs[epDownObj.episodeObj.episodeLinkAvi] = epDownObj;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSProgress *progress    = Nil;
        NSURL *urlDownload;
        (isSoundFile) ?
        (urlDownload = [NSURL URLWithString:epDownObj.episodeObj.episodeLinkMp3]) :
        (urlDownload = [NSURL URLWithString:epDownObj.episodeObj.episodeLinkAvi]);
        
        NSURLRequest *request   = [[NSURLRequest alloc]initWithURL:urlDownload];

        NSURLSessionDownloadTask *dt = [self.downloadManager downloadTaskWithRequest:request
                                                                            progress:^(NSProgress * _Nonnull downloadProgress) {
                                                                                
                                                                            }
                                                                         destination:^NSURL *(NSURL *targetPath, NSURLResponse *response){
                                                                             return [self.urlDocs URLByAppendingPathComponent:fileName];}
                                                                   completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error){
                                                                       [self.listQueue removeObject:epDownObj];
                                                                       dispatch_async(dispatch_get_main_queue(), ^{
                                                                           if (!error) {
                                                                               // :)
                                                                               epDownObj.episodeDownloadCurrentStatus = downloadStatusFinished;
                                                                               episodeDownloadedFileType EDFType;
                                                                               isSoundFile ? (EDFType = episodeDownloadedFileAudio):(EDFType = episodeDownloadedFileVideo);
                                                                               [episodsManager episodeDownloaded:epObj type:EDFType];
                                                                           }else{
                                                                               (isSoundFile) ?
                                                                               ([self.listOfDownloadedObjs removeObjectForKey:epDownObj.episodeObj.episodeLinkMp3]):
                                                                               ([self.listOfDownloadedObjs removeObjectForKey:epDownObj.episodeObj.episodeLinkAvi]);
                                                                               epDownObj.episodeDownloadCurrentStatus = downloadStatusCanceled;
                                                                               epDownObj.episodeDownloadError = error;
                                                                           }
                                                                           if (epDownObj.episodeDownloadBlock)
                                                                               epDownObj.episodeDownloadBlock();
                                                                           [self anObjectIsfinishedDownloadingShouldWeEmptyOurDataSource:epDownObj];
                                                                           [self sendAppGlobalNotification];
                                                                       });
                                                                   }];
        
        epDownObj.episodeDownloadTask = dt;
        [self.KVOController observe:progress
                            keyPath:NSStringFromSelector(@selector(fractionCompleted))
                            options:NSKeyValueObservingOptionNew
                              block:^(id observer, id object, NSDictionary *change) {
                                  if (!epDownObj.episodeDownloadStartTime)
                                      epDownObj.episodeDownloadStartTime = [[NSDate date]timeIntervalSince1970];
                                  dispatch_async(dispatch_get_main_queue(), ^{
                                      epDownObj.episodeDownloadCurrentStatus = downloadStatusDownloading;
                                      epDownObj.episodeDownloadProgress      = (NSProgress *)object;
                                      if (epDownObj.episodeDownloadBlock)
                                          epDownObj.episodeDownloadBlock();
                                      [self sendAppGlobalNotification];
                                  });
                              }];
        [self.listQueue addObject:epDownObj];
    });
    return epDownObj;
}
-(void)sendAppGlobalNotification{
    [[NSNotificationCenter defaultCenter]postNotificationName:@"updateProgressTab" object:Nil];
}
-(void)anObjectIsfinishedDownloadingShouldWeEmptyOurDataSource:(episodeDownloadObject *)epDownObj{
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
        [self.listOfDownloadedObjs removeAllObjects];
    }
}
-(void)startAnotherDownloadTask{
    episodeDownloadObject *edObj = [self.listQueue firstObject];
    [edObj.episodeDownloadTask resume];
}
@end