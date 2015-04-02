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

@implementation episodeObject
-(BOOL)checkIfMp3FileInLocalFolder{
    BOOL exist          = NO;
    NSString *fileName  = [NSString stringWithFormat:@"%d.mp3",self.episodeID];
    NSString *pathFile  = [NSString stringWithFormat:@"%@/%@",NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0],fileName];
    exist               = [[NSFileManager defaultManager]fileExistsAtPath:pathFile isDirectory:Nil];
    self.episodeLinkMp3Local= pathFile;
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
@end