//
//  bookmarkObj.m
//  FawaedTV
//
//  Created by Homam on 2015-02-14.
//  Copyright (c) 2015 Homam. All rights reserved.
//

#import "bookmarkObj.h"
#import "databaseManager.h"
@implementation bookmarkObj


+(NSMutableDictionary *)getBookmarksFromDatabase{
    
    NSMutableDictionary *dictOfBookmarks = [NSMutableDictionary new];
    
    for (NSUInteger i=0; i< 5; i++) {
        
        // prepare sql query and result container "array"
        NSMutableArray *arrayOfBookmarkType = [NSMutableArray new];
        NSString *sql                       = [NSString stringWithFormat:@"select * from bookmark where contentType = %lu",(unsigned long)i];
        
        [[databaseManager sharedDatabaseObj]excuteQuery:sql onCompletion:^(FMResultSet *result) {
            while ([result next]) {
                
                bookmarkObj *newBMObj       = [bookmarkObj new];
                newBMObj.bookmarkID         = [result intForColumn:@"id"];
                newBMObj.bookmarkContentID  = [result intForColumn:@"contentID"];
                newBMObj.bookmarkTitle      = [result stringForColumn:@"contentTitle"];
                newBMObj.bookmarkImageLink  = [result stringForColumn:@"contentImgLink"];
                newBMObj.bookmarkType       = [result intForColumn:@"contentType"];

                [arrayOfBookmarkType addObject:newBMObj];
            }
            dictOfBookmarks[@(i)] = arrayOfBookmarkType;
        }];
    }
    return dictOfBookmarks;
}
+(bookmarkObj *)getBookmarkForContentID:(int)contentID{
    __block bookmarkObj *bObj;
    NSString *sql = [NSString stringWithFormat:@"select * from bookmark where contentID = %d",contentID];
    [[databaseManager sharedDatabaseObj]excuteQuery:sql onCompletion:^(FMResultSet *result) {
        if ([result next]) {
            bObj                    = [bookmarkObj new];
            bObj.bookmarkID         = [result intForColumn:@"id"];
            bObj.bookmarkContentID  = [result intForColumn:@"contentID"];
            bObj.bookmarkTitle      = [result stringForColumn:@"contentTitle"];
            bObj.bookmarkImageLink  = [result stringForColumn:@"contentImgLink"];
            bObj.bookmarkType       = [result intForColumn:@"contentType"];
        }
    }];
    
    return bObj;
}
-(void)addToDataBaseWithCompletion:(void(^)(bookmarkObj *newObj))completion;{
    NSString *sql = [NSString stringWithFormat:@"INSERT INTO bookmark (contentID,contentTitle,contentImgLink,contentType) VALUES (%d,'%@','%@',%d)",
                     self.bookmarkContentID,
                     self.bookmarkTitle,
                     self.bookmarkImageLink,
                     (int)self.bookmarkType];
    
    [[databaseManager sharedDatabaseObj]excuteUpdate:sql onCompletion:^(BOOL updated) {
        NSLog(@"%d result",updated);
    }];
    NSString *sqlForaddedObj = [NSString stringWithFormat:@"select * from bookmark where contentID = %d and contentType=%d",self.bookmarkContentID,(int)self.bookmarkType];
    [[databaseManager sharedDatabaseObj]excuteQuery:sqlForaddedObj onCompletion:^(FMResultSet *result) {
        if ([result next]) {
            self.bookmarkID = [result intForColumn:@"id"];
        }
        if (completion) {
            completion(self);
        }
    }];
}
-(void)removeFromDataBase{
    NSString *sql = [NSString stringWithFormat:@"delete from bookmark where id = %d",self.bookmarkID];
    [[databaseManager sharedDatabaseObj]excuteUpdate:sql onCompletion:^(BOOL updated) {
        NSLog(@"%d result",updated);
    }];
}
-(bookmarkObj *)isAlreadyAvailableInDBWithCompletion:(void(^)(bookmarkObj *obj))completion{
    NSString *sql = [NSString stringWithFormat:@"select * from bookmark where contentID = %d and contentType = %d ",self.bookmarkContentID,(int)self.bookmarkType];
    __block bookmarkObj *newBMObj;
    [[databaseManager sharedDatabaseObj]excuteQuery:sql onCompletion:^(FMResultSet *result) {
        if ([result next]) {
            newBMObj                    = [bookmarkObj new];
            newBMObj.bookmarkID         = [result intForColumn:@"id"];
            newBMObj.bookmarkContentID  = [result intForColumn:@"contentID"];
            newBMObj.bookmarkTitle      = [result stringForColumn:@"contentTitle"];
            newBMObj.bookmarkImageLink  = [result stringForColumn:@"contentImgLink"];
            newBMObj.bookmarkType       = [result intForColumn:@"contentType"];
        }
        if (completion) {
            completion(newBMObj);
        }
    }];
    return newBMObj;
}
@end
