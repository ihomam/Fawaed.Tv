//
//  seriesObject.h
//  FawaedTV
//
//  Created by Homam on 2014-12-13.
//  Copyright (c) 2014 Homam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBXML.h"

@interface seriesObject : NSObject

    @property (nonatomic)        int            seriesID;
    @property (nonatomic,strong) NSString       *seriesTitle;
    @property (nonatomic,strong) NSString       *seriesImageLink;
    @property (nonatomic,strong) NSMutableArray *seriesLectures;
    @property (nonatomic,strong) NSString       *seriesLecturer;

+(NSMutableArray *)proccessXMLFromAllSerieceRequest:(TBXML *)xmlObject;
-(instancetype)processXML:(TBXML *)xmlObject;
@end