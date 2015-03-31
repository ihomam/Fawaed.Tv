//
//  episodesCVC.h
//  FawaedTV
//
//  Created by Homam on 2015-02-09.
//  Copyright (c) 2015 Homam. All rights reserved.
//

#import <UIKit/UIKit.h>

@class seriesObject;
@class bookmarkObj;
@interface episodesCVC : UICollectionViewController
    @property (nonatomic,strong) seriesObject *selObjSeries;
    @property (nonatomic,strong) bookmarkObj  *bookmarkObject;
@end
