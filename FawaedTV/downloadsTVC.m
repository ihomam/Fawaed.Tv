//
//  downloadsTVC.m
//  FawaedTV
//
//  Created by Homam on 2015-03-10.
//  Copyright (c) 2015 Homam. All rights reserved.
//

#import "downloadsTVC.h"
#import "downloadsTVCCell.h"
#import "episodeObject.h"
#import "downloadManager.h"
#import "ddProgressBtn.h"
#import "appTBVC.h"

@interface downloadsTVC ()
@property (nonatomic,strong) NSMutableDictionary *dataSource;
    @property (nonatomic,weak)  IBOutlet UIBarButtonItem *btnCancel;
@end

@implementation downloadsTVC

- (void)viewDidLoad {
    [super viewDidLoad];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.dataSource = [downloadManager sharedDownloadObj].listOfDownloadedObjs.mutableCopy;
    if (self.dataSource.count == 0)  self.btnCancel.enabled = NO;
    [self.tableView reloadData];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - actions
- (IBAction)cancelAllDownloads:(id)sender {
    NSMutableArray *indexPathes = [NSMutableArray new];
    __block NSInteger i = 0;
    [self.dataSource enumerateKeysAndObjectsUsingBlock:^(id key, episodeDownloadObject *epDObj, BOOL *stop) {
        // send download this episode to downloadManager so we can cancel
        [[downloadManager sharedDownloadObj]downloadThisEpisode:epDObj.episodeObj soundFile:YES];
        // build cell indexspaths
        [indexPathes addObject:[NSIndexPath indexPathForItem:i inSection:0]];
        i++;
    }];
    self.dataSource = Nil;
    [self.tableView deleteRowsAtIndexPaths:indexPathes withRowAnimation:UITableViewRowAnimationFade];
}
- (IBAction)dPBtnTapped:(ddProgressBtn *)sender {
    if(sender.currentButtonType == buttonOkType)
        return;
    
    // 1. get cell object
    downloadsTVCCell *cell = (downloadsTVCCell *)sender.superview;
    while (![cell isKindOfClass:[downloadsTVCCell class]]) {
            cell = (downloadsTVCCell *)cell.superview;
    }
    // 2. get episodeDownloadObject
    NSIndexPath *indexpath          = [self.tableView indexPathForCell:cell];
    NSString *key                   = [[self.dataSource allKeys]objectAtIndex:indexpath.row];
    episodeDownloadObject *epDObj   = [[self.dataSource allValues]objectAtIndex:indexpath.row];
    
    // 3 remove objet from datasource
    [self.dataSource removeObjectForKey:key];
    [self.tableView deleteRowsAtIndexPaths:@[indexpath] withRowAnimation:UITableViewRowAnimationLeft];
    
    // 4. send download this episode to downloadManager so we can cancel
    [[downloadManager sharedDownloadObj]downloadThisEpisode:epDObj.episodeObj soundFile:epDObj.episodeDownloadType];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.dataSource.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    downloadsTVCCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    // Configure the cell...
    __weak episodeDownloadObject *epDObj= [[self.dataSource allValues]objectAtIndex:indexPath.row];
    cell.laTitle.text                   = epDObj.episodeObj.episodeTitle;
    cell.laDownloadDetails.text         = Nil;
    // handel btn
    [self handleBtn:cell.btnDownloadControl withEDObj:epDObj];

    return cell;
}
-(void)tableView:(UITableView *)tableView willDisplayCell:(downloadsTVCCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    __weak episodeDownloadObject *epDObj= [[self.dataSource allValues]objectAtIndex:indexPath.row];
    cell.laDownloadDetails.text         = Nil;
    [self handleBtn:cell.btnDownloadControl withEDObj:epDObj];
    epDObj.episodeDownloadBlock = ^{
        cell.laDownloadDetails.text = [epDObj downloadDetails];
        [self handleBtn:cell.btnDownloadControl withEDObj:epDObj];
    };
}
-(void)handleBtn:(ddProgressBtn *)btn withEDObj:(episodeDownloadObject *)epDObj{
    [btn handelEpDownObj:epDObj];
    if (epDObj.episodeDownloadCurrentStatus == downloadStatusFinished) {

        dispatch_async(dispatch_get_main_queue(), ^{
            [btn setCheckmark];
        });
    }
}
@end
