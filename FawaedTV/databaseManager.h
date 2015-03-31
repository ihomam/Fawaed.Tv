//
//  databaseObject.h
//  FawaedTV
//
//  Created by Homam on 2015-02-14.
//  Copyright (c) 2015 Homam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMResultSet.h"
@interface databaseManager : NSObject
+(instancetype)sharedDatabaseObj;

-(void)excuteUpdate:(NSString *)sql onCompletion:(void(^)(BOOL updated))isUpdated;
-(void)excuteQuery:(NSString *)sql onCompletion:(void(^)(FMResultSet *result))completion;
@end
