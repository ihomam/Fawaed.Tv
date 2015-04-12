//
//  appTBVC.m
//  FawaedTV
//
//  Created by Homam on 2015-02-10.
//  Copyright (c) 2015 Homam. All rights reserved.
//

#import "appTBVC.h"
#import "PBYouTubeVideoViewController.h"
#import "episodeObject.h"
#import "audioPlayerVC.h"
#import "downloadManager.h"
#import "AFSoundManager.h"

@interface appTBVC ()

@end

@implementation appTBVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(updateProgressTab)
                                                name:@"updateProgressTab"
                                              object:Nil];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
#pragma mark - player
-(void)buildFilePlayerForObject:(id)mediaObj forType:(playerType)type{
    [[AFSoundManager sharedManager]stop];
    UIViewController *playerVC;
    switch (type) {
        case playerTypeAudioLocal:{
            playerVC = [self.storyboard instantiateViewControllerWithIdentifier:@"soudePlayerVC"];
            ((audioPlayerVC *)playerVC).isGoingToLocalFile = YES;
            ((audioPlayerVC *)playerVC).epObj = (episodeObject *)mediaObj;
        }
            break;
        case playerTypeAudioOnline:{
            playerVC = [self.storyboard instantiateViewControllerWithIdentifier:@"soudePlayerVC"];
            ((audioPlayerVC *)playerVC).epObj = (episodeObject *)mediaObj;
        }
            break;
        case playerTypeVideoOnline:{
            playerVC = [[PBYouTubeVideoViewController alloc] initWithVideoId:(NSString *)mediaObj];
        }
        default:
            break;
    }
    [self setPlayerTabWithVc:playerVC];
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
        newItem.image = [UIImage imageNamed:@"tabs-player"];
        newItem.title = NSLocalizedString(@"Player", Nil);
    }
    [self setSelectedViewController:vc];
}
#pragma mark - download object
/// called by notification center when downloadObject get new data from interenet.
-(void)updateProgressTab{
    __block float totalProgress = 0;
    [[downloadManager sharedDownloadObj].listOfDownloadedObjs enumerateKeysAndObjectsUsingBlock:^(id key, episodeDownloadObject *obj, BOOL *stop) {
        totalProgress +=obj.episodeDownloadProgress.fractionCompleted;
    }];
    totalProgress = totalProgress/[downloadManager sharedDownloadObj].listOfDownloadedObjs.count;
    [self updateDownloadTabProgressWith:totalProgress currentDownloads:[downloadManager sharedDownloadObj].listOfDownloadedObjs.count];
}
-(void)updateDownloadTabProgressWith:(float)progress currentDownloads:(NSUInteger)numDownloads{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setDownloadTabBadge:numDownloads];
        [self setDownloadTabImgProgress:progress];
    });
}
-(void)setDownloadTabBadge:(NSUInteger)badgeValue{
    UITabBarItem *item  = self.tabBar.items[2];
    [item setBadgeValue:[NSString stringWithFormat:@"%d",(int)badgeValue]];
    if (badgeValue <= 0)
        [item setBadgeValue:Nil];
}
-(void)setDownloadTabImgProgress:(float)progress{
    // if progress var is undefiened it equles to 0
    if(isnan(progress)) progress = 0;
    
    UITabBarItem *item  = self.tabBar.items[2];
    NSString *imgName   = [NSString stringWithFormat:@"tab-downloads-%.0f.png",progress*100];
    item.image          = [[UIImage imageNamed:imgName]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    item.selectedImage  = [[UIImage imageNamed:imgName]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}
@end