//
//  serverObject.m
//  FawaedTV
//
//  Created by Homam on 2014-12-12.
//  Copyright (c) 2014 Homam. All rights reserved.
//

#import "serverObject.h"
#import "globalVars.h"
#import "TBXML.h"


@implementation serverObject
+(instancetype)sharedServerObj{
    static serverObject *_sharedServerObj = nil;
    
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
-(void)getWholeSchemaObjectWithCompleation:(void(^)(BOOL finishedSuccessfully, NSMutableArray *resultOfSeries,NSMutableArray *resultOfCategories,NSMutableArray *resultOfYears,NSMutableArray *resultOfLecturers))compleation{
    // prepare request link
    NSString *link = linkWebSiteDomain;
    
    // send it
    [self GET:link parameters:Nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSError *errorXmlParser;
        TBXML *xmlResponse = [TBXML newTBXMLWithXMLData:responseObject error:&errorXmlParser];
        if (!errorXmlParser) {
            NSMutableArray *allSeries   = [seriesObject proccessXMLFromAllSerieceRequest:xmlResponse];
            NSMutableArray *allYears    = [yearObject proccessXMLFromAllYearsRequest:xmlResponse];
            NSMutableArray *allCategorie= [categoryObject proccessXMLFromAllCategoriesRequest:xmlResponse];
            NSMutableArray *allLecturers= [lecturerObject proccessXMLFromAlllecturersRequest:xmlResponse];
            if (compleation) {
                compleation(YES,allSeries,allCategorie,allYears,allLecturers);
            }
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        compleation(NO,Nil,Nil,Nil,Nil);
    }];
    
}
-(void)getAllSeriesWithCompleation:(void(^)(NSMutableArray *result))compleation{
    // prepare request link
    NSString *link = linkWebSiteDomain;
    
    // send it
    [self GET:link parameters:Nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSError *errorXmlParser;
        TBXML *xmlResponse = [TBXML newTBXMLWithXMLData:responseObject error:&errorXmlParser];
        if (!errorXmlParser) {
            if (compleation) {
                compleation([seriesObject proccessXMLFromAllSerieceRequest:xmlResponse]);
            }
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (compleation) {
            compleation(Nil);
        }
    }];
}
-(void)getAllYearsWithCompleation:(void(^)(NSMutableArray *resultOfYears))compleation{
    // prepare request link
    NSString *link = linkWebSiteDomain;
    
    // send it
    [self GET:link parameters:Nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSError *errorXmlParser;
        TBXML *xmlResponse = [TBXML newTBXMLWithXMLData:responseObject error:&errorXmlParser];
        if (!errorXmlParser) {
            if (compleation) {
                compleation([yearObject proccessXMLFromAllYearsRequest:xmlResponse]);
            }
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (compleation) {
            compleation(Nil);
        }
    }];
}
-(void)getAllCategoriesWithCompleation:(void(^)(NSMutableArray *resultOfCategories))compleation{
    // prepare request link
    NSString *link = linkWebSiteDomain;
    
    // send it
    [self GET:link parameters:Nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSError *errorXmlParser;
        TBXML *xmlResponse = [TBXML newTBXMLWithXMLData:responseObject error:&errorXmlParser];
        if (!errorXmlParser) {
            if (compleation) {
                compleation([categoryObject proccessXMLFromAllCategoriesRequest:xmlResponse]);
            }
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (compleation) {
            compleation(Nil);
        }
    }];
}
-(void)getAllLecturersWithCompleation:(void(^)(NSMutableArray *resultOfLecturers))compleation{
    // prepare request link
    NSString *link = linkWebSiteDomain;
    
    // send it
    [self GET:link parameters:Nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSError *errorXmlParser;
        TBXML *xmlResponse = [TBXML newTBXMLWithXMLData:responseObject error:&errorXmlParser];
        if (!errorXmlParser) {
            if (compleation) {
                compleation([lecturerObject proccessXMLFromAlllecturersRequest:xmlResponse]);
            }
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (compleation) {
            compleation(Nil);
        }
    }];
    
}
-(void)getAllEpisodesOfSeries:(seriesObject *)seriesObj WithCompleation:(void(^)(seriesObject *result))compleation{

    // prepare request link
    NSString *link = [NSString stringWithFormat:@"%@series/%d",linkWebSiteDomain,seriesObj.seriesID];

    // send it
    [self GET:link parameters:Nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSError *errorXmlParser;
        TBXML *xmlResponse = [TBXML newTBXMLWithXMLData:responseObject error:&errorXmlParser];
        if (!errorXmlParser) {
            if (compleation) {
                compleation([seriesObj processXML:xmlResponse]);
            }
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (compleation) {
            compleation(Nil);
        }
    }];
}
-(void)getAllSeriesOfLecturer:(lecturerObject *)lecturerObj WithCompleation:(void(^)(lecturerObject *result))compleation{
    // prepare request link
    NSString *link = [NSString stringWithFormat:@"%@lecturer/%d",linkWebSiteDomain,lecturerObj.lecturerID];
    
    // send it
    [self GET:link parameters:Nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSError *errorXmlParser;
        TBXML *xmlResponse = [TBXML newTBXMLWithXMLData:responseObject error:&errorXmlParser];
        if (!errorXmlParser) {
            if (compleation) {
                compleation([lecturerObject processXML:xmlResponse]);
            }
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (compleation) {
            compleation(Nil);
        }
    }];
}

-(void)getAllSeriesOfCategory:(categoryObject *)categoryObj WithCompleation:(void(^)(categoryObject *result))compleation{
    // prepare request link
    NSString *link = [NSString stringWithFormat:@"%@category/%d",linkWebSiteDomain,categoryObj.categoryID];
    
    // send it
    [self GET:link parameters:Nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSError *errorXmlParser;
        TBXML *xmlResponse = [TBXML newTBXMLWithXMLData:responseObject error:&errorXmlParser];
        if (!errorXmlParser) {
            if (compleation) {
                compleation([categoryObject processXML:xmlResponse]);
            }
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (compleation) {
            compleation(Nil);
        }
    }];
}
-(void)getAllSeriesOfYear:(yearObject *)yearObj WithCompleation:(void(^)(yearObject *result))compleation{
    // prepare request link
    NSString *link = [NSString stringWithFormat:@"%@year/%d",linkWebSiteDomain,yearObj.yearID];
    
    // send it
    [self GET:link parameters:Nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSError *errorXmlParser;
        TBXML *xmlResponse = [TBXML newTBXMLWithXMLData:responseObject error:&errorXmlParser];
        if (!errorXmlParser) {
            if (compleation) {
                compleation([yearObject processXML:xmlResponse]);
            }
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (compleation) {
            compleation(Nil);
        }
    }];
}
@end
