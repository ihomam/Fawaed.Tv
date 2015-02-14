//
//  bookmarkObj.h
//  FawaedTV
//
//  Created by Homam on 2015-02-14.
//  Copyright (c) 2015 Homam. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSInteger, bookmarkObjectType){
    bookmarkTypeSeries,
    bookmarkTypeEpisode,
    bookmarkTypeLecturer,
};
@interface bookmarkObj : NSObject
    @property (nonatomic)        int            bookmarkID;
    @property (nonatomic)        int            bookmarkContentID;
    @property (nonatomic,strong) NSString       *bookmarkTitle;
    @property (nonatomic,strong) NSString       *bookmarkImageLink;
    @property (nonatomic)        bookmarkObjectType           bookmarkType;
@end
