//
//  browseCVC.h
//  FawaedTV
//
//  Created by Homam on 2015-02-08.
//  Copyright (c) 2015 Homam. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, sourcetype) {
    dataSourceTypePrograms,
    dataSourceTypeCategories,
    dataSourceTypeLecturers,
    dataSourceTypeYears
};

@interface browseCVC : UICollectionViewController
    @property (nonatomic) sourcetype dataSourceType;
@end
