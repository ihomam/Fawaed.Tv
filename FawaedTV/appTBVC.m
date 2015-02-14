//
//  appTBVC.m
//  FawaedTV
//
//  Created by Homam on 2015-02-10.
//  Copyright (c) 2015 Homam. All rights reserved.
//

#import "appTBVC.h"
#import "PBYouTubeVideoViewController.h"

@interface appTBVC ()

@end

@implementation appTBVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)setPlayerTabWithVc:(UIViewController *)vc{
    if (![self.viewControllers containsObject:vc]) {
        NSMutableArray *controllers = self.viewControllers.mutableCopy;
        if (self.viewControllers.count > 3) {
            [controllers removeObjectAtIndex:3];
        }
        [controllers addObject:vc];
        [self setViewControllers:controllers animated:YES];
        NSMutableArray *array = self.tabBar.items.mutableCopy;
        UITabBarItem *newItem = [array objectAtIndex:3];
        [newItem setImage:[UIImage imageNamed:@"user"]];
    }
    [self setSelectedViewController:vc];
}

@end