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
    @property (nonatomic)        int      episodeSeriesID;
    @property (nonatomic,strong) NSString *episodeTitle;
    @property (nonatomic,strong) NSString *episodeLecturer;
    @property (nonatomic,strong) NSString *episodeLink;
    @property (nonatomic,strong) NSString *episodeImageLink;
    @property (nonatomic,strong) NSString *episodeWatchLink;
    @property (nonatomic,strong) NSString *episodeListenLink;
    @property (nonatomic,strong) NSString *episodeAviLink;
    @property (nonatomic,strong) NSString *episodeMp3Link;
@end