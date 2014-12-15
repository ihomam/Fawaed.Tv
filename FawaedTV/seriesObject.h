//
//  seriesObject.h
//  FawaedTV
//
//  Created by Homam on 2014-12-13.
//  Copyright (c) 2014 Homam. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface seriesObject : NSObject
    @property (nonatomic)        int      seriesID;
    @property (nonatomic,strong) NSString *serviceTitle;
    @property (nonatomic,strong) NSString *serviceImageLink;
@end
