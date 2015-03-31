//
//  fileObject.m
//  FawaedTV
//
//  Created by Homam on 2015-03-30.
//  Copyright (c) 2015 Homam. All rights reserved.
//

#import "fileObject.h"
#import "databaseManager.h"

@implementation fileObject


+(NSArray *)getFilesFromDatabase{
    NSMutableArray *arrayOfFiles = [NSMutableArray new];
    NSString *sql = [NSString stringWithFormat:@"select * from localfilesindex"];
    [[databaseManager sharedDatabaseObj]excuteQuery:sql onCompletion:^(FMResultSet *result) {
        while ([result next]) {
            fileObject *newfObj         = [fileObject new];
            newfObj.fileID              = [result intForColumn:@"id"];
            newfObj.fileName            = [result stringForColumn:@"fileName"];
            newfObj.fileSize            = [result stringForColumn:@"fileSize"];
            newfObj.fileEpisodeID       = [result intForColumn:@"contentID"];
            newfObj.fileEpisodeTitle    = [result stringForColumn:@"contentTitle"];
            newfObj.fileEpisodeLecturer = [result stringForColumn:@"contentLecturer"];
            
            [arrayOfFiles addObject:newfObj];
        }
    }];
    return arrayOfFiles.copy;
}
-(void)addToDataBase{
    NSString *sql = [NSString stringWithFormat:@"INSERT INTO localfilesindex (fileName, fileSize, contentID, contentTitle, contentLecturer) VALUES ('%@','%@',%d,'%@','%@')",
                     self.fileName,
                     self.fileSize,
                     self.fileEpisodeID,
                     self.fileEpisodeTitle,
                     self.fileEpisodeLecturer];
    
    [[databaseManager sharedDatabaseObj]excuteUpdate:sql onCompletion:^(BOOL updated) {
        NSLog(@"%d result",updated);
    }];
}
-(void)removeFromDataBase{
    NSString *sql = [NSString stringWithFormat:@"delete from localfilesindex where fileName = '%@'",self.fileName];
    [[databaseManager sharedDatabaseObj]excuteUpdate:sql onCompletion:^(BOOL updated) {
        NSLog(@"%d result",updated);
    }];
}
-(BOOL)isAlreadyAvailableInDB{
    NSString *sql = [NSString stringWithFormat:@"select * from localfilesindex where fileName = '%@'",self.fileName];
    __block BOOL fileExist = NO;
    [[databaseManager sharedDatabaseObj]excuteQuery:sql onCompletion:^(FMResultSet *result) {
        /// is there a result ?
        if ([result next])
            fileExist = YES;
    }];
    return fileExist;
}

-(NSString *)getDescription{
    NSString *fileDescription;
    self.fileEpisodeLecturer ? (fileDescription = self.fileEpisodeLecturer):(fileDescription);
    self.fileSize ? (fileDescription = [NSString stringWithFormat:@"%@  %@ MB",fileDescription,self.fileSize]) : (fileDescription);
    
    return fileDescription;
}
+(fileObject *)getFileObjForFileName:(NSString *)fileName fromList:(NSArray *)listOfObjs{
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(fileObject *fObj, NSDictionary *bindings) {
        BOOL goal = [fObj.fileName isEqualToString:fileName];
        return goal;
    }];
    NSArray *result = [listOfObjs filteredArrayUsingPredicate:predicate];
    if (result.count > 0) {
        return result[0];
    }
    return Nil;
}
-(fileType)fileType{
    fileType fType = fileTypeAudio;
    if ([self.fileName hasSuffix:@"avi"]) {
        fType = fileTypeVideo;
    }
    return fType;
}
@end
