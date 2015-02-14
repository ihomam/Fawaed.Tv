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
} cellName;
typedef void(^cellClicked)(cellName);

@interface browseMenuTVC : UITableViewController

@property (nonatomic, copy) void (^cellClickedCompletion)(cellName cellType, UIImage *imgTypeIcon) ;
@property (nonatomic, copy) void (^tapClick)();

-(void)addSelfToVCAndAnimate:(UIViewController *)vc;
-(void)hideCellsForRemovingVC;
@end
