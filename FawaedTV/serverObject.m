//
//  serverObject.m
//  FawaedTV
//
//  Created by Homam on 2014-12-12.
//  Copyright (c) 2014 Homam. All rights reserved.
//

#import "serverObject.h"
#import "globalVars.h"

@implementation serverObject
+(instancetype)sharedServerObj{
    static serverObject *_sharedServerObj = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedServerObj = [[self alloc]initWithBaseURL:[NSURL URLWithString:linkWebSiteDomain]];

        _sharedServerObj.responseSerializer = [AFXMLParserResponseSerializer serializer];
        _sharedServerObj.responseSerializer.acceptableContentTypes = [_sharedServerObj.responseSerializer.acceptableContentTypes setByAddingObject:@"application/rss+xml"];
        _sharedServerObj.responseSerializer.acceptableContentTypes = [_sharedServerObj.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];

        

    });
    
    return _sharedServerObj;
}
#pragma mark - categories & products
-(void)getAllLecturerOfSeries:(seriesObject *)seriesObj WithCompleation:(void(^)(NSMutableArray *result))compleation{

    NSString *link = [NSString stringWithFormat:@"%@series/%d",linkWebSiteDomain,seriesObj.seriesID];

    [self GET:link parameters:Nil success:^(NSURLSessionDataTask *task, id responseObject) {
//        [responseObject enumerateObjectsUsingBlock:^(NSDictionary *dict, NSUInteger idx, BOOL *stop) {
//
//            
//        }];
        NSLog(@"%@",task.response);
        NSLog(@"%@",task.originalRequest);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {

    }];
}
@end
