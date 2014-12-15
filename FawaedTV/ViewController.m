//
//  ViewController.m
//  FawaedTV
//
//  Created by Homam on 2014-12-12.
//  Copyright (c) 2014 Homam. All rights reserved.
//

#import "ViewController.h"
#import "serverObject.h"
#import "seriesObject.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}
-(void)viewDidAppear:(BOOL)animated{
    seriesObject *newSeries = [seriesObject new];
    newSeries.seriesID = 97;
    [[serverObject sharedServerObj]getAllLecturerOfSeries:newSeries WithCompleation:^(NSMutableArray *result) {
        
    }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
