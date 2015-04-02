//
//  browseMenuTVC.h
//  FawaedTV
//
//  Created by Homam on 2015-02-07.
//  Copyright (c) 2015 Homam. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    cellProgram,
    cellCategory,
    cellLecturer,
    cellYear,
    cellEpisode,
    cellLocalFile
} cellName;

@interface browseMenuTVC : UITableViewController

@property (nonatomic, copy) void (^cellClickedCompletion)(cellName cellType, UIImage *imgTypeIcon) ;
@property (nonatomic, copy) void (^tapClick)();

-(void)addSelfToVCAndAnimate:(UIViewController *)vc withCellNumber:(int)number;
-(void)hideCellsForRemovingVC;
+(UIImage *)menuIconForID:(int)iconID;
@end
