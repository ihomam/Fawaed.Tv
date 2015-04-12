//
//  browseMenuTVC.m
//  FawaedTV
//
//  Created by Homam on 2015-02-07.
//  Copyright (c) 2015 Homam. All rights reserved.
//

#import "browseMenuTVC.h"
#import "browseMenuTVCCell.h"

@interface browseMenuTVC ()
    @property (nonatomic,strong) UITapGestureRecognizer *tap;
    @property                    int                    numberOfRows;
@end

@implementation browseMenuTVC
static int rowHeight = 44;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.view.layer.shadowColor = [UIColor blackColor].CGColor;
    self.view.layer.shadowRadius= 2;
    self.view.layer.shadowOffset= CGSizeMake(3, 0);
    self.view.layer.shadowOpacity = 0.5;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)addSelfToVCAndAnimate:(UIViewController *)vc withCellNumber:(int)number{
    self.numberOfRows = number;
    CGFloat vcHeight = rowHeight*number;
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
                                                                             attribute:NSLayoutAttributeLeft
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:vc.navigationController.view
                                                                             attribute:NSLayoutAttributeLeft
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
    browseMenuTVCCell *cell = (browseMenuTVCCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    if (self.cellClickedCompletion) {
        self.cellClickedCompletion(indexPath.row,cell.img.image);
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.numberOfRows;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return rowHeight;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    browseMenuTVCCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    cell.img.image =  [browseMenuTVC menuIconForID:(int)indexPath.row];
    return cell;
}
+(UIImage *)menuIconForID:(int)iconID{
    UIImage *icon;
    switch (iconID) {
        case 0:
            icon = [UIImage imageNamed:@"menu-tv"];
            break;
        case 1:
            icon = [UIImage imageNamed:@"menu-folder"];
            break;
        case 2:
            icon = [UIImage imageNamed:@"menu-user"];
            break;
        case 3:
            icon = [UIImage imageNamed:@"menu-calendar"];
            break;
        case 4:
            icon = [UIImage imageNamed:@"menu-episode"];
            break;
        case 5:
            icon = [UIImage imageNamed:@"menu-file"];
            break;
        default:
            icon = [UIImage imageNamed:@"menu-tv"];
            break;
    }
    return icon;
}
@end
