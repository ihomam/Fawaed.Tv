//
//  databaseObject.m
//  FawaedTV
//
//  Created by Homam on 2015-02-14.
//  Copyright (c) 2015 Homam. All rights reserved.
//

#import "databaseManager.h"
#import "FMDB.h"
#import "FMDatabaseQueue.h"


@interface databaseManager()
    @property (nonatomic,strong) FMDatabaseQueue *dbQeue;
@end


@implementation databaseManager
+(instancetype)sharedDatabaseObj{
    static databaseManager *_sharedDatabaseObj = Nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _sharedDatabaseObj          = [databaseManager new];

        NSString *dbPath = [NSString stringWithFormat:@"%@/db",NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0]];
        _sharedDatabaseObj.dbQeue   = [FMDatabaseQueue databaseQueueWithPath:dbPath];
        [_sharedDatabaseObj.dbQeue inDatabase:^(FMDatabase *db) {
            
            [db executeUpdate:@"CREATE TABLE if not exists bookmark (id INTEGER PRIMARY KEY  AUTOINCREMENT  NOT NULL , contentID INTEGER, contentTitle TEXT,  contentImgLink  TEXT, contentType INTEGER)"];
            
            [db executeUpdate:@"CREATE TABLE if not exists localfilesindex (id INTEGER PRIMARY KEY  AUTOINCREMENT  NOT NULL , fileName TEXT, fileSize  TEXT,contentID INTEGER , contentTitle TEXT, contentLecturer TEXT)"];
        }];
    });
    
    
    return _sharedDatabaseObj;
}
-(void)excuteUpdate:(NSString *)sql onCompletion:(void(^)(BOOL updated))isUpdated;{
    [self.dbQeue inDatabase:^(FMDatabase *db) {
       BOOL result = [db executeUpdate:sql];
        if (isUpdated) {
            isUpdated(result);
        }
    }];
}
-(void)excuteQuery:(NSString *)sql onCompletion:(void(^)(FMResultSet *result))completion{
    [self.dbQeue inDatabase:^(FMDatabase *db) {
        FMResultSet *result = [db executeQuery:sql];
        if (completion) completion(result);
        [result close];
    }];
}

@end
