//
//  categoryObject.h
//  FawaedTV
//
//  Created by Homam on 2014-12-13.
//  Copyright (c) 2014 Homam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBXML.h"

@interface categoryObject : NSObject
@property (nonatomic)        int            categoryID;
@property (nonatomic,strong) NSString       *categoryImgLink;
@property (nonatomic,strong) NSString       *categoryTitle;
@property (nonatomic,strong) NSMutableArray *categorySeriesArray;

+(instancetype)processXML:(TBXML *)xmlObject;
+(NSMutableArray *)proccessXMLFromAllCategoriesRequest:(TBXML *)xmlObject;

@end
