//
//  seriesObject.m
//  FawaedTV
//
//  Created by Homam on 2014-12-13.
//  Copyright (c) 2014 Homam. All rights reserved.
//

#import "seriesObject.h"
#import "episodeObject.h"

@implementation seriesObject

+(NSMutableArray *)proccessXMLFromAllSerieceRequest:(TBXML *)xmlObject{
    NSMutableArray *result = [NSMutableArray new];
    // .1 get channel obj then the title
    TBXMLElement *elmAllSeries  = [TBXML childElementNamed:@"all-series" parentElement:xmlObject.rootXMLElement];

    [TBXML iterateElementsForQuery:@"series"
                       fromElement:elmAllSeries
                         withBlock:^(TBXMLElement *element) {
                             seriesObject *newSerObj    = [seriesObject new];
                             newSerObj.seriesID         = [[TBXML valueOfAttributeNamed:@"id" forElement:element]intValue];
                             newSerObj.seriesTitle      = [TBXML valueOfAttributeNamed:@"name" forElement:element];
                             newSerObj.seriesImageLink  = [TBXML valueOfAttributeNamed:@"image-url" forElement:element];
                             
                             [result addObject:newSerObj];
    }];
    
    return result;
}

// parse thx xmlObj
-(instancetype)processXML:(TBXML *)xmlObject{
    // .1 get channel obj then the title
    TBXMLElement *elmSeriesChannel  = [TBXML childElementNamed:@"channel" parentElement:xmlObject.rootXMLElement];
    TBXMLElement *elmSeriesTitle    = [TBXML childElementNamed:@"title" parentElement:elmSeriesChannel];
    self.seriesTitle        = [TBXML textForElement:elmSeriesTitle];
    
    // .2 prepare array of
    self.seriesLectures     = [NSMutableArray new];
    __block NSError *error = Nil;
    // .3 iterate through channel tag and build episode objs
    [TBXML iterateElementsForQuery:@"item"
                       fromElement:elmSeriesChannel
                         withBlock:^(TBXMLElement *element) {
                             
                             // 3.1 prepare tags elements
                             TBXMLElement *elmItemTitle = [TBXML childElementNamed:@"title" parentElement:element error:&error];
                             TBXMLElement *elmItemLink  = [TBXML childElementNamed:@"link" parentElement:element error:&error];
                             TBXMLElement *elmItemImg   = [TBXML childElementNamed:@"enclosure" parentElement:element error:&error];
                             TBXMLElement *elmItemWatch = [TBXML childElementNamed:@"fawaed:watch" parentElement:element error:&error];
                             TBXMLElement *elmItemListen= [TBXML childElementNamed:@"fawaed:listen" parentElement:element error:&error];
                             TBXMLElement *elmItemMp3   = [TBXML childElementNamed:@"fawaed:mp3" parentElement:element error:&error];
                             TBXMLElement *elmItemAvi   = [TBXML childElementNamed:@"fawaed:avi" parentElement:element error:&error];
                             TBXMLElement *elmItemTeache= [TBXML childElementNamed:@"dc:creator" parentElement:element error:&error];
                             
                             // ttp://www.fawaed.tv/episode/12876
                             
                             // 3.2 prepare episodeObject
                             episodeObject *epObj   = [episodeObject new];
                             epObj.episodeSeriesID  = self.seriesID;
                             epObj.episodeTitle     = [TBXML textForElement:elmItemTitle error:&error];
                             epObj.episodeImageLink = [TBXML valueOfAttributeNamed:@"url" forElement:elmItemImg error:&error];
                             epObj.episodeLink      = [TBXML textForElement:elmItemLink error:&error];
                             epObj.episodeWatchLink = [TBXML textForElement:elmItemWatch error:&error];
                             epObj.episodeListenLink= [TBXML textForElement:elmItemListen error:&error];
                             epObj.episodeMp3Link   = [TBXML textForElement:elmItemMp3 error:&error];
                             epObj.episodeAviLink   = [TBXML textForElement:elmItemAvi error:&error];
                             epObj.episodeLecturer  = [TBXML textForElement:elmItemTeache error:&error];
                             
                             NSRange backSlashRange = [epObj.episodeLink rangeOfString:@"/" options:NSBackwardsSearch];
                             if (backSlashRange.location != NSNotFound) {
                                 epObj.episodeID = [epObj.episodeLink substringFromIndex:backSlashRange.location+backSlashRange.length].intValue;
                             }
                             // 3.3
                             [self.seriesLectures addObject:epObj];
                             self.seriesLecturer = [TBXML textForElement:elmItemTeache error:&error];
                             
                         }];
    
    
    return self;
}

@end
