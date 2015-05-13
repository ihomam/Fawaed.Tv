//
//  episodeObject.m
//  FawaedTV
//
//  Created by Homam on 2014-12-13.
//  Copyright (c) 2014 Homam. All rights reserved.
//

#import "episodeObject.h"
#import "databaseManager.h"
#import "fileObject.h"
#import "bookmarkObj.h"
#import "serverManager.h"

@implementation episodeObject
-(BOOL)checkIfMp3FileInLocalFolder{
    BOOL exist          = NO;
    NSString *fileName  = [NSString stringWithFormat:@"%d.mp3",self.episodeID];
    NSString *pathFile  = [NSString stringWithFormat:@"%@/%@",NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0],fileName];
    exist               = [[NSFileManager defaultManager]fileExistsAtPath:pathFile isDirectory:Nil];
    self.episodeLinkMp3Local= pathFile;
    return exist;
}
-(BOOL)checkIfAviFileInLocalFolder{
    BOOL exist          = NO;
    NSString *fileName  = [NSString stringWithFormat:@"%d.avi",self.episodeID];
    NSString *pathFile  = [NSString stringWithFormat:@"%@/%@",NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0],fileName];
    exist               = [[NSFileManager defaultManager]fileExistsAtPath:pathFile isDirectory:Nil];
    self.episodeLinkAviLocal= pathFile;
    return exist;
}
-(NSString *)episodeLinkMp3Local{
    static NSString *path   = Nil;
    NSString *fileName      = [NSString stringWithFormat:@"%d.mp3",self.episodeID];
    path                    = [NSString stringWithFormat:@"%@/%@",NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0],fileName];
    
    return path;
}
-(NSString *)episodeLinkAviLocal{
    static NSString *path   = Nil;
    NSString *fileName      = [NSString stringWithFormat:@"%d.avi",self.episodeID];
    path                    = [NSString stringWithFormat:@"%@/%@",NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0],fileName];
    
    return path;
}
-(UIImage *)episodeLinkImageObject{
    BOOL exist          = NO;
    NSString *fileName  = [NSString stringWithFormat:@"%d",self.episodeID];
    NSString *pathFile  = [NSString stringWithFormat:@"%@/images/%@",NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0],fileName];
    exist               = [[NSFileManager defaultManager]fileExistsAtPath:pathFile isDirectory:Nil];
    if (exist) {
        _episodeLinkImageObject = [UIImage imageWithContentsOfFile:pathFile];
        return _episodeLinkImageObject;
    }
    
    return Nil;
}
-(void)getImageObjFromWebservice:(void(^)(UIImage *img))completion{
    [[serverManager sharedServerObj]getImageOfEpisode:self withComletion:^(UIImage *episodeImage) {
        if (completion) {
            completion(episodeImage);
        }
    }];
}
-(void)addToDatabase{
    if ([self episodeExists])
        return;
    
    NSString *sql = [NSString stringWithFormat:@"INSERT INTO episode (id,seriesID,title,lecturer,link,linkImage,linkWatch,linkListen,linkAvi,linkMp3) VALUES (%d,%d,'%@','%@','%@','%@','%@','%@','%@','%@')",
                     self.episodeID,
                     self.episodeSeriesID,
                     self.episodeTitle,
                     self.episodeLecturer,
                     self.episodeLink,
                     self.episodeLinkImage,
                     self.episodeLinkWatch,
                     self.episodeLinkListen,
                     self.episodeLinkAvi,
                     self.episodeLinkMp3];
    
    [[databaseManager sharedDatabaseObj]excuteUpdate:sql onCompletion:^(BOOL updated) {
        NSLog(@"%d result",updated);
    }];
}
-(void)removeFromDatabase{
    NSString *sql = [NSString stringWithFormat:@"delete from episode where id = %d",self.episodeID];
    [[databaseManager sharedDatabaseObj]excuteUpdate:sql onCompletion:^(BOOL updated) {
        NSLog(@"%d result",updated);
    }];
}
+(episodeObject *)episodeObjectForFile:(fileObject *)fObj{
    __block episodeObject *eObj;
    NSString *sql = [NSString stringWithFormat:@"select * from episode where id = %d",fObj.fileEpisodeID];
    [[databaseManager sharedDatabaseObj]excuteQuery:sql onCompletion:^(FMResultSet *result) {
        while ([result next]) {
            eObj                    = [episodeObject new];
            eObj.episodeID          = [result intForColumn:@"id"];
            eObj.episodeSeriesID    = [result intForColumn:@"seriesID"];
            eObj.episodeTitle       = [result stringForColumn:@"title"];
            eObj.episodeLecturer    = [result stringForColumn:@"lecturer"];
            eObj.episodeLink        = [result stringForColumn:@"link"];
            eObj.episodeLinkImage   = [result stringForColumn:@"linkImage"];
            eObj.episodeLinkWatch   = [result stringForColumn:@"linkWatch"];
            eObj.episodeLinkListen  = [result stringForColumn:@"linkListen"];
            eObj.episodeLinkAvi     = [result stringForColumn:@"linkAvi"];
            eObj.episodeLinkMp3     = [result stringForColumn:@"linkMp3"];
        }
    }];
    return eObj;
}
+(episodeObject *)episodeObjectForBookmark:(bookmarkObj *)bObj{
    __block episodeObject *eObj;
    NSString *sql = [NSString stringWithFormat:@"select * from episode where id = %d",bObj.bookmarkContentID];
    [[databaseManager sharedDatabaseObj]excuteQuery:sql onCompletion:^(FMResultSet *result) {
        while ([result next]) {
            eObj                    = [episodeObject new];
            eObj.episodeID          = [result intForColumn:@"id"];
            eObj.episodeSeriesID    = [result intForColumn:@"seriesID"];
            eObj.episodeTitle       = [result stringForColumn:@"title"];
            eObj.episodeLecturer    = [result stringForColumn:@"lecturer"];
            eObj.episodeLink        = [result stringForColumn:@"link"];
            eObj.episodeLinkImage   = [result stringForColumn:@"linkImage"];
            eObj.episodeLinkWatch   = [result stringForColumn:@"linkWatch"];
            eObj.episodeLinkListen  = [result stringForColumn:@"linkListen"];
            eObj.episodeLinkAvi     = [result stringForColumn:@"linkAvi"];
            eObj.episodeLinkMp3     = [result stringForColumn:@"linkMp3"];
        }
    }];
    return eObj;
}
-(BOOL)episodeExists{
    __block BOOL exists = NO;
    NSString *sql = [NSString stringWithFormat:@"select * from episode where id = %d",self.episodeID];
    [[databaseManager sharedDatabaseObj]excuteQuery:sql onCompletion:^(FMResultSet *result) {
        if ([result next]) exists = YES;
    }];
    return exists;
}
@end

@implementation episodeDownloadObject
-(NSString *)downloadDetails{
    NSString *details;
    double speed = 0; int64_t tot,rec;
    tot = self.episodeDownloadProgress.totalUnitCount;
    rec = self.episodeDownloadProgress.completedUnitCount;
    if (self.episodeDownloadStartTime)
        speed = self.episodeDownloadProgress.completedUnitCount / ([[NSDate date]timeIntervalSince1970]-self.episodeDownloadStartTime);
    
    details = [NSString stringWithFormat:@"%@ of %@ - %@",
               [self formatByte:rec forspeed:NO],
               [self formatByte:tot forspeed:NO],
               [self formatByte:speed forspeed:YES]];
    
    return details;
}
-(NSString *)formatByte:(int64_t)byte forspeed:(BOOL)isSpeedFormat{
    NSString *formatedByte;
    if (byte == 0)
        return formatedByte;
    
    if (!isSpeedFormat) {
        if((byte/1000000) >= 1){
            formatedByte = [NSString stringWithFormat:@"%.01f MB",(float)byte/1000000];
        }else if (byte){
            formatedByte = [NSString stringWithFormat:@"%.01f KB",(float)byte/1000];
        }
    }else{
        if((byte/1000000) >= 1){
            formatedByte = [NSString stringWithFormat:@"%d MB/Sec",(int)byte/1000000];
        }else if (byte){
            formatedByte = [NSString stringWithFormat:@"%d KB/Sec",(int)byte/1000];
        }
    }

    
    return formatedByte;
}
@end