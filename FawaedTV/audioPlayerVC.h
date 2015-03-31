//
//  soudePlayerVC.h
//  FawaedTV
//
//  Created by Homam on 2015-02-11.
//  Copyright (c) 2015 Homam. All rights reserved.
//

#import <UIKit/UIKit.h>
@class episodeObject;
@interface audioPlayerVC : UIViewController
    @property (nonatomic,strong) episodeObject *epObj;
    @property BOOL isGoingToLocalFile;
@end
