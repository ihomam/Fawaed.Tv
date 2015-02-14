//
//  browseNavC.m
//  FawaedTV
//
//  Created by Homam on 2015-02-07.
//  Copyright (c) 2015 Homam. All rights reserved.
//

#import "browseNavC.h"
#import "browseMenuTVC.h"

#import "browseCVC.h"
#import "viNavigiationBarContent.h"

#import "episodesCVC.h"

@interface browseNavC ()<UINavigationControllerDelegate>
@property (nonatomic,strong) viNavigiationBarContent *viNavBar;
@property (nonatomic,strong) UIBarButtonItem         *btnBookmark;
@end

@implementation browseNavC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.delegate = self;
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self prepareUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - properties
-(UIView *)viNavBar{
    if (!_viNavBar)
        _viNavBar = [[[NSBundle mainBundle]loadNibNamed:@"viBrowseTopMenu" owner:self options:Nil]objectAtIndex:0];
    return _viNavBar;
}
-(UIBarButtonItem *)btnBookmark{
    if (!_btnBookmark) {
        UIButton *btnBookMark   = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *imgBtnBmark    = [UIImage imageNamed:@"btnBookmark"];
        [btnBookMark setTitle:@"menu" forState:UIControlStateNormal];
        [btnBookMark setFrame:CGRectMake(0, 0, imgBtnBmark.size.width, imgBtnBmark.size.height)];
        [btnBookMark setImage:imgBtnBmark forState:UIControlStateNormal];
        [btnBookMark addTarget:self action:@selector(addToBookmarks) forControlEvents:UIControlEventTouchUpInside];
        _btnBookmark = [[UIBarButtonItem alloc]initWithCustomView:btnBookMark];
    }
    return _btnBookmark;
}
#pragma mark - actions 
-(void)updateNavigationBarWithTitle:(NSString *)title andDetail:(NSString *)detail{
    self.viNavBar.laTitle.text      = title;
    self.viNavBar.laDetails.text    = detail;
}
-(void)addToBookmarks{
    NSLog(@"%@",((episodesCVC *)self.topViewController).bookmarkObject);
}
#pragma mark - prepareVC
-(void)prepareUI{

    // add vi Bar
    if (![self.viNavBar isDescendantOfView:self.view]) {
        [self.view addSubview:self.viNavBar];
        self.viNavBar.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.viNavBar
                                                                       attribute:NSLayoutAttributeTop
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.navigationBar
                                                                       attribute:NSLayoutAttributeTop
                                                                      multiplier:1
                                                                        constant:0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.viNavBar
                                                                       attribute:NSLayoutAttributeBottom
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.navigationBar
                                                                       attribute:NSLayoutAttributeBottom
                                                                      multiplier:1
                                                                        constant:0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.viNavBar
                                                                       attribute:NSLayoutAttributeWidth
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.navigationBar
                                                                       attribute:NSLayoutAttributeWidth
                                                                      multiplier:.55
                                                                        constant:0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.viNavBar
                                                                       attribute:NSLayoutAttributeCenterX
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.view
                                                                       attribute:NSLayoutAttributeCenterX
                                                                      multiplier:1.0
                                                                        constant:0]];
        
    }

    self.viNavBar.laTitle.text      = NSLocalizedString(@"FawaedTv", Nil);
    self.viNavBar.laDetails.text    = NSLocalizedString(@"Programs", Nil);
}
-(UIBarButtonItem *)BookmarkBtnForVC:(UIViewController *)vc{
    UIButton *btnBookMark   = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *imgBtnBmark    = [UIImage imageNamed:@"btnBookmark"];
    [btnBookMark setTitle:@"menu" forState:UIControlStateNormal];
    [btnBookMark setFrame:CGRectMake(0, 0, imgBtnBmark.size.width, imgBtnBmark.size.height)];
    [btnBookMark setImage:imgBtnBmark forState:UIControlStateNormal];
    [btnBookMark addTarget:vc action:@selector(addToBookmarks) forControlEvents:UIControlEventTouchUpInside];

    return [[UIBarButtonItem alloc]initWithCustomView:btnBookMark];
}
#pragma mark - navigation delegate
- (void)navigationController:(UINavigationController *)navigationController
       willShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated{

    if (![viewController isKindOfClass:[browseCVC class]]) {
        viewController.navigationItem.rightBarButtonItem = self.btnBookmark;
    }
}
//- (id <UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController
//                          interactionControllerForAnimationController:(id <UIViewControllerAnimatedTransitioning>) animationController{
//    
//}
//
//- (id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
//                                   animationControllerForOperation:(UINavigationControllerOperation)operation
//                                                fromViewController:(UIViewController *)fromVC
//                                                  toViewController:(UIViewController *)toVC{
//    
//}
@end
