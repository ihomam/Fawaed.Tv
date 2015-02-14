//
//  yearObject.m
//  FawaedTV
//
//  Created by Homam on 2014-12-13.
//  Copyright (c) 2014 Homam. All rights reserved.
//

#import "yearObject.h"
#import "seriesObject.h"

@implementation yearObject
+(NSMutableArray *)proccessXMLFromAllYearsRequest:(TBXML *)xmlObject{
    NSMutableArray *result = [NSMutableArray new];
    // .1 get channel obj then the title
    TBXMLElement *elmAllSeries  = [TBXML childElementNamed:@"years" parentElement:xmlObject.rootXMLElement];
    
    [TBXML iterateElementsForQuery:@"year"
                       fromElement:elmAllSeries
                         withBlock:^(TBXMLElement *element) {
                             yearObject *newYearObj     = [yearObject new];
                             newYearObj.yearID          = [[TBXML valueOfAttributeNamed:@"id" forElement:element]intValue];
                             newYearObj.yearTitle       = [TBXML valueOfAttributeNamed:@"name" forElement:element];
                             [result addObject:newYearObj];
                         }];
    
    return result;
}
+(instancetype)processXML:(TBXML *)xmlObject{
    
    yearObject *newYearObj              = [yearObject new];
    
    // .1 get channel obj then the title
    TBXMLElement *elmAllSeries          = [TBXML childElementNamed:@"all-series" parentElement:xmlObject.rootXMLElement];
    
    // .2 prepare array of
    newYearObj.yearSeriesArray          = [NSMutableArray new];
    
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
                             [newYearObj.yearSeriesArray addObject:seObj];
                         }];
    
    
    return newYearObj;
}


@end
