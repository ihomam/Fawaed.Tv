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
#import "lecturerObject.h"
#import "categoryObject.h"
#import "yearObject.h"

@interface serverObject : AFHTTPSessionManager
+(instancetype)sharedServerObj;
-(void)getWholeSchemaObjectWithCompleation:(void(^)(BOOL finishedSuccessfully, NSMutableArray *resultOfSeries,NSMutableArray *resultOfCategories,NSMutableArray *resultOfYears,NSMutableArray *resultOfLecturers))compleation;
-(void)getAllSeriesWithCompleation:(void(^)(NSMutableArray *resultOfSeries))compleation;
-(void)getAllYearsWithCompleation:(void(^)(NSMutableArray *resultOfYears))compleation;
-(void)getAllCategoriesWithCompleation:(void(^)(NSMutableArray *resultOfCategories))compleation;
-(void)getAllLecturersWithCompleation:(void(^)(NSMutableArray *resultOfLecturers))compleation;

-(void)getAllEpisodesOfSeries:(seriesObject *)seriesObj WithCompleation:(void(^)(seriesObject *result))compleation;
-(void)getAllSeriesOfLecturer:(lecturerObject *)lecturerObj WithCompleation:(void(^)(lecturerObject *result))compleation;
-(void)getAllSeriesOfCategory:(categoryObject *)categoryObj WithCompleation:(void(^)(categoryObject *result))compleation;
-(void)getAllSeriesOfYear:(yearObject *)categoryObj WithCompleation:(void(^)(yearObject *result))compleation;
@end
