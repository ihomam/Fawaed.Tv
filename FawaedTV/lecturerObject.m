//
//  lecturerObject.m
//  FawaedTV
//
//  Created by Homam on 2014-12-13.
//  Copyright (c) 2014 Homam. All rights reserved.
//

#import "lecturerObject.h"
#import "seriesObject.h"

@implementation lecturerObject
+(NSMutableArray *)proccessXMLFromAlllecturersRequest:(TBXML *)xmlObject{
    NSMutableArray *result = [NSMutableArray new];
    // .1 get channel obj then the title
    TBXMLElement *elmAllSeries  = [TBXML childElementNamed:@"lecturers" parentElement:xmlObject.rootXMLElement];
    
    [TBXML iterateElementsForQuery:@"lecturer"
                       fromElement:elmAllSeries
                         withBlock:^(TBXMLElement *element) {
                             lecturerObject *lecObj     = [lecturerObject new];
                             lecObj.lecturerID          = [[TBXML valueOfAttributeNamed:@"id" forElement:element]intValue];
                             lecObj.lecturerTitle       = [TBXML valueOfAttributeNamed:@"name" forElement:element];
                             lecObj.lecturerImgLink     = [TBXML valueOfAttributeNamed:@"image-url" forElement:element];
                             
                             [result addObject:lecObj];
                         }];
    
    return result;

}
// parse thx xmlObj
+(instancetype)processXML:(TBXML *)xmlObject{
    
    lecturerObject *newLecturerObj = [lecturerObject new];
    
    // .1 get channel obj then the title
    TBXMLElement *elmAllSeries          = [TBXML childElementNamed:@"all-series" parentElement:xmlObject.rootXMLElement];
    
    // .2 prepare array of
    newLecturerObj.lecturerSeriesArray  = [NSMutableArray new];
    
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
                             [newLecturerObj.lecturerSeriesArray addObject:seObj];
                         }];
    
    
    return newLecturerObj;
}

@end
