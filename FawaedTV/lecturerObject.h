//
//  lecturerObject.h
//  FawaedTV
//
//  Created by Homam on 2014-12-13.
//  Copyright (c) 2014 Homam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBXML.h"

@interface lecturerObject : NSObject
    @property (nonatomic)        int            lecturerID;
    @property (nonatomic,strong) NSString       *lecturerTitle;
    @property (nonatomic,strong) NSString       *lecturerImgLink;
    @property (nonatomic,strong) NSMutableArray *lecturerSeriesArray;

+(NSMutableArray *)proccessXMLFromAlllecturersRequest:(TBXML *)xmlObject;
+(instancetype)processXML:(TBXML *)xmlObject;
@end
