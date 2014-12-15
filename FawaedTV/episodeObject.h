//
//  episodeObject.h
//  FawaedTV
//
//  Created by Homam on 2014-12-13.
//  Copyright (c) 2014 Homam. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface episodeObject : NSObject
    @property (nonatomic)        int      episodeID;
    @property (nonatomic)        int      seriesID;
    @property (nonatomic,strong) NSString *episodeTitle;
    @property (nonatomic,strong) NSString *serviceImageLink;
@end