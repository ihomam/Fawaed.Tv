//
//  serverObject.m
//  FawaedTV
//
//  Created by Homam on 2014-12-12.
//  Copyright (c) 2014 Homam. All rights reserved.
//

#import "serverManager.h"
#import "globalVars.h"
#import <TBXML/TBXML.h>



@implementation serverManager
+(instancetype)sharedServerObj{
    static serverManager *_sharedServerObj = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedServerObj = [[self alloc]initWithBaseURL:[NSURL URLWithString:linkWebSiteDomain]];
        
        // put the responseSerializer to AFHTTPResponseSerializer because i need
        // nsdata as response not nsxmlparser nor json parser
        _sharedServerObj.responseSerializer = [AFHTTPResponseSerializer serializer];

        // the response comes with content type application/rss+xml
        _sharedServerObj.responseSerializer.acceptableContentTypes = [_sharedServerObj.responseSerializer.acceptableContentTypes setByAddingObject:@"application/rss+xml"];
    });
    
    return _sharedServerObj;
}

#pragma mark -
-(BOOL)displayDownloadBtn{
    if (!_displayDownloadBtn) {
        [self getDownloadBtnEnabled];
    }
    return _displayDownloadBtn;
}
-(void)getDownloadBtnEnabled{
    // prepare request link
    NSString *link = linkWebSiteDomain;
    
    // send request
    [[self dataTaskWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:link]]
            completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
                if (!error) {
                    /// response
                    NSError *errorXmlParser;
                    TBXML *xmlResponse = [TBXML tbxmlWithXMLData:responseObject error:&errorXmlParser];
                    if (!errorXmlParser) {
                        self.displayDownloadBtn = [self proccessXMLFromConfigRequest:xmlResponse];
                        [[NSNotificationCenter defaultCenter]postNotificationName:@"displayDownloadBtnStateChanged" object:Nil];
                    }
                }
            }]resume];
    
}
-(void)getWholeSchemaObjectWithCompleation:(void(^)(BOOL finishedSuccessfully,
                                                    NSMutableArray *resultOfSeries,
                                                    NSMutableArray *resultOfCategories,
                                                    NSMutableArray *resultOfYears,
                                                    NSMutableArray *resultOfLecturers))compleation{
    // prepare request link
    NSString *link = linkWebSiteDomain;
    
    // send it
    [[self dataTaskWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:link]]
            completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
                if (!error) {
                    NSError *errorXmlParser;
                    TBXML *xmlResponse = [TBXML tbxmlWithXMLData:responseObject error:&errorXmlParser];
                    if (!errorXmlParser) {
                        NSMutableArray *allSeries   = [seriesObject proccessXMLFromAllSerieceRequest:xmlResponse];
                        NSMutableArray *allYears    = [yearObject proccessXMLFromAllYearsRequest:xmlResponse];
                        NSMutableArray *allCategorie= [categoryObject proccessXMLFromAllCategoriesRequest:xmlResponse];
                        NSMutableArray *allLecturers= [lecturerObject proccessXMLFromAlllecturersRequest:xmlResponse];
                        self.displayDownloadBtn     = [self proccessXMLFromConfigRequest:xmlResponse];
                        
                        if (compleation) {
                            compleation(YES,allSeries,allCategorie,allYears,allLecturers);
                        }
                    }
                }else{
                    if (compleation) {
                        compleation(NO,Nil,Nil,Nil,Nil);
                    }
                }
            }]resume];

    
}
-(void)getAllSeriesWithCompleation:(void(^)(NSMutableArray *result))compleation{
    // prepare request link
    NSString *link = linkWebSiteDomain;
    
    // send it
    [[self dataTaskWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:link]]
            completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
                if (!error) {
                    NSError *errorXmlParser;
                    TBXML *xmlResponse = [TBXML tbxmlWithXMLData:responseObject error:&errorXmlParser];
                    if (!errorXmlParser) {
                        if (compleation) {
                            compleation([seriesObject proccessXMLFromAllSerieceRequest:xmlResponse]);
                        }
                    }
                }else{
                    if (compleation) {
                        compleation(Nil);
                    }
                }
            }]resume];
}
-(void)getAllYearsWithCompleation:(void(^)(NSMutableArray *resultOfYears))compleation{
    // prepare request link
    NSString *link = linkWebSiteDomain;
    
    // send it
    [[self dataTaskWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:link]]
            completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
                if (!error) {
                    NSError *errorXmlParser;
                    TBXML *xmlResponse = [TBXML tbxmlWithXMLData:responseObject error:&errorXmlParser];
                    if (!errorXmlParser) {
                        if (compleation) {
                            compleation([yearObject proccessXMLFromAllYearsRequest:xmlResponse]);
                        }
                    }
                }else{
                    if (compleation) {
                        compleation(Nil);
                    }
                }
            }]resume];
}
-(void)getAllCategoriesWithCompleation:(void(^)(NSMutableArray *resultOfCategories))compleation{
    // prepare request link
    NSString *link = linkWebSiteDomain;
    
    // send it
    [[self dataTaskWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:link]]
            completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
                if (!error) {
                    NSError *errorXmlParser;
                    TBXML *xmlResponse = [TBXML tbxmlWithXMLData:responseObject error:&errorXmlParser];
                    if (!errorXmlParser) {
                        if (compleation) {
                            compleation([categoryObject proccessXMLFromAllCategoriesRequest:xmlResponse]);
                        }
                    }
                }else{
                    if (compleation) {
                        compleation(Nil);
                    }
                }
            }]resume];
}
-(void)getAllLecturersWithCompleation:(void(^)(NSMutableArray *resultOfLecturers))compleation{
    // prepare request link
    NSString *link = linkWebSiteDomain;
    
    // send it
    [[self dataTaskWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:link]]
            completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
                if (!error) {
                    NSError *errorXmlParser;
                    TBXML *xmlResponse = [TBXML tbxmlWithXMLData:responseObject error:&errorXmlParser];
                    if (!errorXmlParser) {
                        if (compleation) {
                            compleation([lecturerObject proccessXMLFromAlllecturersRequest:xmlResponse]);
                        }
                    }
                }else{
                    if (compleation) {
                        compleation(Nil);
                    }
                }
            }]resume];
    
}
-(void)getAllEpisodesOfSeries:(seriesObject *)seriesObj WithCompleation:(void(^)(seriesObject *result))compleation{
    // prepare request link
    NSString *link = [NSString stringWithFormat:@"%@series/%d",linkWebSiteDomain,seriesObj.seriesID];

    // send it
    [[self dataTaskWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:link]]
            completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
                if (!error) {
                    NSError *errorXmlParser;
                    TBXML *xmlResponse = [TBXML tbxmlWithXMLData:responseObject error:&errorXmlParser];
                    if (!errorXmlParser) {
                        if (compleation) {
                            compleation([seriesObj processXML:xmlResponse]);
                        }
                    }
                }else{
                    if (compleation) {
                        compleation(Nil);
                    }
                }
            }]resume];
}
-(void)getAllSeriesOfLecturer:(lecturerObject *)lecturerObj WithCompleation:(void(^)(lecturerObject *result))compleation{
    // prepare request link
    NSString *link = [NSString stringWithFormat:@"%@lecturer/%d",linkWebSiteDomain,lecturerObj.lecturerID];
    
    // send it
    [[self dataTaskWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:link]]
            completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
                if (!error) {
                    NSError *errorXmlParser;
                    TBXML *xmlResponse = [TBXML tbxmlWithXMLData:responseObject error:&errorXmlParser];
                    if (!errorXmlParser) {
                        if (compleation) {
                            compleation([lecturerObject processXML:xmlResponse]);
                        }
                    }
                }else{
                    if (compleation) {
                        compleation(Nil);
                    }
                }
            }]resume];
}

-(void)getAllSeriesOfCategory:(categoryObject *)categoryObj WithCompleation:(void(^)(categoryObject *result))compleation{
    // prepare request link
    NSString *link = [NSString stringWithFormat:@"%@category/%d",linkWebSiteDomain,categoryObj.categoryID];
    
    // send it
    [[self dataTaskWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:link]]
            completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
                if (!error) {
                    NSError *errorXmlParser;
                    TBXML *xmlResponse = [TBXML tbxmlWithXMLData:responseObject error:&errorXmlParser];
                    if (!errorXmlParser) {
                        if (compleation) {
                            compleation([categoryObject processXML:xmlResponse]);
                        }
                    }
                }else{
                    if (compleation) {
                        compleation(Nil);
                    }
                }
            }]resume];
}
-(void)getAllSeriesOfYear:(yearObject *)yearObj WithCompleation:(void(^)(yearObject *result))compleation{
    // prepare request link
    NSString *link = [NSString stringWithFormat:@"%@year/%d",linkWebSiteDomain,yearObj.yearID];
    
    // send it
    [[self dataTaskWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:link]]
            completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
                if (!error) {
                    NSError *errorXmlParser;
                    TBXML *xmlResponse = [TBXML tbxmlWithXMLData:responseObject error:&errorXmlParser];
                    if (!errorXmlParser) {
                        if (compleation) {
                            compleation([yearObject processXML:xmlResponse]);
                        }
                    }
                }else{
                    if (compleation) {
                        compleation(Nil);
                    }
                }
            }]resume];
}
-(void)getImageOfEpisode:(episodeObject *)epObj withComletion:(void(^)(UIImage *episodeImage))completion{
    [[self dataTaskWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:epObj.episodeLinkImage]]
            completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
                if (!error) {
                    UIImage *img = [UIImage imageWithData:responseObject];
                    if (completion) {
                        completion(img);
                    }
                }else{
                    if (completion) {
                        completion(Nil);
                    }
                }
            }]resume];
}
#pragma mark - XML
-(BOOL)proccessXMLFromConfigRequest:(TBXML *)xmlObject{
    __block BOOL shouldDisplayBtn = NO;
    // .1 get channel obj then the title
    TBXMLElement *elmConfig   = [TBXML childElementNamed:@"config" parentElement:xmlObject.rootXMLElement];
    TBXMLElement *elmDownload = [TBXML childElementNamed:@"download" parentElement:elmConfig];
    NSString *value           = [TBXML valueOfAttributeNamed:@"enabled" forElement:elmDownload];
    shouldDisplayBtn          = value.boolValue;
    return shouldDisplayBtn;
}
@end
