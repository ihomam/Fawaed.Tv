//
//  browseMenuTVC.m
//  FawaedTV
//
//  Created by Homam on 2015-02-07.
//  Copyright (c) 2015 Homam. All rights reserved.
//

#import "browseMenuTVC.h"

@interface browseMenuTVC ()
    @property (nonatomic,strong) UITapGestureRecognizer *tap;
@end

@implementation browseMenuTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)addSelfToVCAndAnimate:(UIViewController *)vc{
    CGFloat vcHeight = 44*4;
    CGFloat vcWidth  = 55;
    self.view.bounds = CGRectMake(0, 0, vcWidth, vcHeight);
    self.view.alpha  = 0;
    [vc addChildViewController:self];
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    [vc.view addSubview:self.view];
    
    [vc.navigationController.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view
                                                                             attribute:NSLayoutAttributeWidth
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:nil
                                                                             attribute:NSLayoutAttributeNotAnAttribute
                                                                            multiplier:1.0
                                                                              constant:vcWidth]];
    
    [vc.navigationController.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view
                                                                             attribute:NSLayoutAttributeHeight
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:nil
                                                                             attribute:NSLayoutAttributeNotAnAttribute
                                                                            multiplier:1.0
                                                                              constant:vcHeight]];
    
    [vc.navigationController.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view
                                                                             attribute:NSLayoutAttributeLeading
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:vc.navigationController.view
                                                                             attribute:NSLayoutAttributeLeading
                                                                            multiplier:1.0
                                                                              constant:0]];
    
    [vc.navigationController.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view
                                                                             attribute:NSLayoutAttributeTop
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:vc.navigationController.navigationBar
                                                                             attribute:NSLayoutAttributeBottom
                                                                            multiplier:1.0
                                                                              constant:0]];

    [UIView animateWithDuration:.2 animations:^{
        self.view.alpha = 1;
    }];
    [vc didMoveToParentViewController:self];

}
#pragma mark - actions
-(void)hideCellsForRemovingVC{
    [self.tableView.visibleCells enumerateObjectsUsingBlock:^(UITableViewCell *cell, NSUInteger idx, BOOL *stop) {
        cell.layer.anchorPoint  = CGPointMake(0, .5);
        cell.layer.transform    = CATransform3DIdentity;
        [UIView animateWithDuration:.1
                              delay:0.1*idx
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             cell.layer.transform = CATransform3DMakeRotation(90 * M_PI / 180, 0, 10, 0);
        } completion:Nil];
    }];
}
#pragma mark - tableview
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    cell.layer.anchorPoint = CGPointMake(0, .5);
    cell.layer.transform = CATransform3DMakeRotation( 90 * M_PI / 180, 0, 10, 0);

    [UIView animateWithDuration:.2 delay:0.1*indexPath.row options:UIViewAnimationOptionCurveEaseInOut animations:^{
        cell.layer.transform = CATransform3DIdentity;
    } completion:Nil];
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.row) {
        case 0:
            if (self.cellClickedCompletion)
                self.cellClickedCompletion(cellProgram,[UIImage imageNamed:@"tv"]);
            break;
        case 1:
            if (self.cellClickedCompletion)
                self.cellClickedCompletion(cellCategory,[UIImage imageNamed:@"folder"]);
            break;
        case 2:
            if (self.cellClickedCompletion)
                self.cellClickedCompletion(cellLecturer,[UIImage imageNamed:@"user"]);
            break;
        case 3:
            if (self.cellClickedCompletion)
                self.cellClickedCompletion(cellYear,[UIImage imageNamed:@"calendar"]);
            break;
        default:
            if (self.cellClickedCompletion)
                self.cellClickedCompletion(cellProgram,[UIImage imageNamed:@"tv"]);
            break;
    }
}
@end
