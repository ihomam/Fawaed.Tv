//
//  serverObject.h
//  FawaedTV
//
//  Created by Homam on 2014-12-12.
//  Copyright (c) 2014 Homam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "seriesObject.h"


@interface serverObject : AFHTTPSessionManager
+(instancetype)sharedServerObj;
-(void)getAllLecturerOfSeries:(seriesObject *)seriesObj WithCompleation:(void(^)(NSMutableArray *result))compleation;
@end
