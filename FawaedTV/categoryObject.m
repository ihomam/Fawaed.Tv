//
//  categoryObject.m
//  FawaedTV
//
//  Created by Homam on 2014-12-13.
//  Copyright (c) 2014 Homam. All rights reserved.
//

#import "categoryObject.h"
#import "seriesObject.h"

@implementation categoryObject
+(NSMutableArray *)proccessXMLFromAllCategoriesRequest:(TBXML *)xmlObject{
    NSMutableArray *result = [NSMutableArray new];
    // .1 get channel obj then the title
    TBXMLElement *elmAllSeries  = [TBXML childElementNamed:@"categories" parentElement:xmlObject.rootXMLElement];
    
    [TBXML iterateElementsForQuery:@"category"
                       fromElement:elmAllSeries
                         withBlock:^(TBXMLElement *element) {
                             categoryObject *catObj     = [categoryObject new];
                             catObj.categoryID          = [[TBXML valueOfAttributeNamed:@"id" forElement:element]intValue];
                             catObj.categoryTitle       = [TBXML valueOfAttributeNamed:@"name" forElement:element];
                             catObj.categoryImgLink     = [TBXML valueOfAttributeNamed:@"image-url" forElement:element];
                             
                             [result addObject:catObj];
                         }];
    
    return result;

}
// parse thx xmlObj
+(instancetype)processXML:(TBXML *)xmlObject{
    
    categoryObject *newCatObj           = [categoryObject new];
    
    // .1 get channel obj then the title
    TBXMLElement *elmAllSeries          = [TBXML childElementNamed:@"all-series" parentElement:xmlObject.rootXMLElement];
    
    // .2 prepare array of
    newCatObj.categorySeriesArray       = [NSMutableArray new];
    
    // .3 iterate through channel tag and build episode objs
    [TBXML iterateElementsForQuery:@"series"
                       fromElement:elmAllSeries
                         withBlock:^(TBXMLElement *element) {
                             
                             
                             // 3.1 prepare episodeObject
                             seriesObject *seObj    = [seriesObject new];
                             seObj.seriesID         = [TBXML valueOfAttributeNamed:@"id" forElement:element].intValue;
                             seObj.seriesImageLink  = [TBXML valueOfAttributeNamed:@"image-url" forElement:element];
                             seObj.seriesTitle      = [TBXML valueOfAttributeNamed:@"name" forElement:element];
                             
                             
                             // 3.2
                             [newCatObj.categorySeriesArray addObject:seObj];
                         }];
    
    
    return newCatObj;
}

@end
