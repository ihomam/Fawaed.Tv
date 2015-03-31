//
//  bookmarkObj.h
//  FawaedTV
//
//  Created by Homam on 2015-02-14.
//  Copyright (c) 2015 Homam. All rights reserved.
//


#import <Foundation/Foundation.h>
@interface bookmarkObj : NSObject
typedef NS_ENUM(NSUInteger, bookmarkObjectType) {
    bookmarkTypeSeries,
    bookmarkTypeCategory,
    bookmarkTypeLecturer,
    bookmarkTypeYear,
    bookmarkTypeEpisode,
};

    @property (nonatomic)        int            bookmarkID;
    @property (nonatomic)        int            bookmarkContentID;
    @property (nonatomic,strong) NSString       *bookmarkTitle;
    @property (nonatomic,strong) NSString       *bookmarkImageLink;
    @property (nonatomic)        bookmarkObjectType           bookmarkType;


+(NSMutableDictionary *)getBookmarksFromDatabase;
+(bookmarkObj *)getBookmarkForContentID:(int)contentID;
-(void)addToDataBaseWithCompletion:(void(^)(bookmarkObj *newObj))completion;
-(void)removeFromDataBase;
-(bookmarkObj *)isAlreadyAvailableInDBWithCompletion:(void(^)(bookmarkObj *obj))completion;
@end
