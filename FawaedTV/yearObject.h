//
//  yearObject.h
//  FawaedTV
//
//  Created by Homam on 2014-12-13.
//  Copyright (c) 2014 Homam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBXML.h"

@interface yearObject : NSObject
    @property (nonatomic)        int            yearID;
    @property (nonatomic,strong) NSString       *yearTitle;
    @property (nonatomic,strong) NSMutableArray *yearSeriesArray;

+(instancetype)processXML:(TBXML *)xmlObject;
+(NSMutableArray *)proccessXMLFromAllYearsRequest:(TBXML *)xmlObject;
@end
