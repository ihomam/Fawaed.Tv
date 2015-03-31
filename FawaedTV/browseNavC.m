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
#import "bookmarkObj.h"
@interface browseNavC ()<UINavigationControllerDelegate>
    @property (nonatomic,strong) viNavigiationBarContent *viNavBar;
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

#pragma mark - actions 
-(void)updateNavigationBarWithTitle:(NSString *)title andDetail:(NSString *)detail{
    dispatch_async(dispatch_get_main_queue(), ^{        
        self.viNavBar.laTitle.text      = title;
        self.viNavBar.laDetails.text    = detail;
    });
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

#pragma mark - navigation delegate
//- (void)navigationController:(UINavigationController *)navigationController
//       willShowViewController:(UIViewController *)viewController
//                    animated:(BOOL)animated{
//
//    if (![viewController isKindOfClass:[browseCVC class]]) {
//        viewController.navigationItem.rightBarButtonItem = self.btnBookmark;
//    }
//}
//- (id <UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController
//                          interactionControllerForAnimationController:(id <UIViewControllerAnimatedTransitioning>) animationController{
//    return self;
//}
//
//- (id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
//                                   animationControllerForOperation:(UINavigationControllerOperation)operation
//                                                fromViewController:(UIViewController *)fromVC
//                                                  toViewController:(UIViewController *)toVC{
//    return self;
//}
//- (void)startInteractiveTransition:(id <UIViewControllerContextTransitioning>)transitionContext{
//    
//}
//- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext{
//    return .3;
//}
//// This method can only  be a nop if the transition is interactive and not a percentDriven interactive transition.
//- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext{
//    
//}
@end
