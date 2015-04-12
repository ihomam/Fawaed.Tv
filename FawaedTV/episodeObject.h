//
//  episodeObject.h
//  FawaedTV
//
//  Created by Homam on 2014-12-13.
//  Copyright (c) 2014 Homam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class fileObject;
@class bookmarkObj;
@interface episodeObject : NSObject
    @property (nonatomic)        int      episodeID;
    @property (nonatomic)        int      episodeSeriesID;
    @property (nonatomic,strong) NSString *episodeTitle;
    @property (nonatomic,strong) NSString *episodeLecturer;
    @property (nonatomic,strong) NSString *episodeLink;
    @property (nonatomic,strong) NSString *episodeLinkImage;
    @property (nonatomic,strong) UIImage  *episodeLinkImageObject;
    @property (nonatomic,strong) NSString *episodeLinkWatch;
    @property (nonatomic,strong) NSString *episodeLinkListen;
    @property (nonatomic,strong) NSString *episodeLinkAvi;
    @property (nonatomic,strong) NSString *episodeLinkMp3;
    @property (nonatomic,strong) NSString *episodeLinkMp3Local; // link path for downloaded mp3 file
    @property (nonatomic,strong) NSString *episodeLinkAviLocal; // link path for downloaded AVI file

-(BOOL)checkIfMp3FileInLocalFolder;
-(BOOL)checkIfAviFileInLocalFolder;
-(void)getImageObjFromWebservice:(void(^)(UIImage *img))completion;
-(void)addToDatabase;
-(void)removeFromDatabase;
+(episodeObject *)episodeObjectForFile:(fileObject *)fObj;
+(episodeObject *)episodeObjectForBookmark:(bookmarkObj *)bObj;
@end




typedef NS_ENUM(NSUInteger, downloadStatus) {
    downloadStatusBasic, // it means there is no download going on. we use this no send nil episodeDownloadObject to ddProgressBtn object.
    downloadStatusInitiating,
    downloadStatusDownloading,
    downloadStatusCanceled,
    downloadStatusFinished,
};
typedef NS_ENUM(NSUInteger, downloadFileType) {
    downloadFileTypeVideo,
    downloadFileTypeAudio,
};

@interface episodeDownloadObject : NSObject
    @property (nonatomic,strong)    episodeObject               *episodeObj;
    @property (nonatomic)           NSProgress                  *episodeDownloadProgress;
    @property (nonatomic)           downloadStatus              episodeDownloadCurrentStatus;
    @property (nonatomic)           NSError                     *episodeDownloadError;
    @property (nonatomic,strong)    NSURLSessionDownloadTask    *episodeDownloadTask;
    @property (nonatomic,copy)                                  void(^episodeDownloadBlock)();
    @property (nonatomic)           NSTimeInterval              episodeDownloadStartTime;
    @property (nonatomic)           downloadFileType            episodeDownloadType;
-(NSString *)downloadDetails;
@end