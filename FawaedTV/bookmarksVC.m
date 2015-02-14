//
//  bookmarksVC.m
//  FawaedTV
//
//  Created by Homam on 2015-02-08.
//  Copyright (c) 2015 Homam. All rights reserved.
//

#import "bookmarksVC.h"

@interface bookmarksVC ()
@property (weak, nonatomic) IBOutlet UIView *viContentContainer;

@end

@implementation bookmarksVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
