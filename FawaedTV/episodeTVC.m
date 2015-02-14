//
//  episodeVC.m
//  FawaedTV
//
//  Created by Homam on 2015-02-09.
//  Copyright (c) 2015 Homam. All rights reserved.
//

#import "episodeTVC.h"
#import "serverObject.h"
#import "UIImageView+activity.h"
#import "browseNavC.h"

#import "episodeObject.h"
#import "AFSoundManager.h"
#import "PBYouTubeVideoViewController.h"
#import "appTBVC.h"
#import "bookmarkObj.h"

@interface episodeTVC (){
    CGFloat cellImgSize;
    AFHTTPRequestOperation *op;
    AFHTTPRequestOperationManager *manager;
}
    @property (nonatomic,weak) IBOutlet UIImageView *viImgEpiPic;
    @property (weak, nonatomic) IBOutlet UIButton *btnYoutube;
    @property (weak, nonatomic) IBOutlet UIImageView *viImgYoutube;
    @property (weak, nonatomic) IBOutlet UIButton *btnAvi;
    @property (weak, nonatomic) IBOutlet UIImageView *viImgAvi;
    @property (weak, nonatomic) IBOutlet UIButton *btnListen;
    @property (weak, nonatomic) IBOutlet UIImageView *viImgListen;
    @property (weak, nonatomic) IBOutlet UIButton *btnMp3;
    @property (weak, nonatomic) IBOutlet UIImageView *viImgMp3;
@end

@implementation episodeTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.btnListen addTarget:self action:@selector(listenOnline) forControlEvents:UIControlEventTouchUpInside];
    [self.btnYoutube addTarget:self action:@selector(watchYoutube) forControlEvents:UIControlEventTouchUpInside];
    [self.btnMp3 addTarget:self action:@selector(downloadMp3) forControlEvents:UIControlEventTouchUpInside];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self updateVCWithObj:self.selEpiObj];
    [self prepareUI];
    [self addObserverOfOrientation];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self removeObserverOfOrientation];
}
- (void)deviceOrientationDidChange:(NSNotification *)notification {
    [self prepareCellImgSize];
    [self.tableView reloadData];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark - 
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        return cellImgSize;
    }
    return 44;
}
#pragma mark - actions 
-(void)listenOnline{
    if (self.selEpiObj.episodeListenLink.length > 0) {
        UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"soudePlayerVC"];
        [((appTBVC *)self.tabBarController) setPlayerTabWithVc:vc];
        [[AFSoundManager sharedManager]startStreamingRemoteAudioFromURL:self.selEpiObj.episodeListenLink
                                                               andBlock:^(int percentage, CGFloat elapsedTime, CGFloat timeRemaining, NSError *error, BOOL finished) {
            NSLog(@"%d %f %f %@ %d",percentage,elapsedTime,timeRemaining,error,finished);
        }];
    }
}
-(void)watchYoutube{
    if (self.selEpiObj.episodeWatchLink.length > 0){
        NSRange vRange = [self.selEpiObj.episodeWatchLink rangeOfString:@"?v="];
        NSString *viID = [self.selEpiObj.episodeWatchLink substringFromIndex:vRange.location+vRange.length];
        PBYouTubeVideoViewController *vc = [[PBYouTubeVideoViewController alloc] initWithVideoId:viID];
        [((appTBVC *)self.tabBarController) setPlayerTabWithVc:vc];
    }
}
-(void)downloadMp3{
    if (self.selEpiObj.episodeMp3Link.length > 0){
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%d",self.selEpiObj.episodeID]];
        
        manager = [AFHTTPRequestOperationManager manager];
        op = [manager GET:self.selEpiObj.episodeMp3Link
                                       parameters:nil
                                          success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                              NSLog(@"successful download to %@", path);
                                          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                              NSLog(@"Error: %@", error);
                                          }];

        op.outputStream = [NSOutputStream outputStreamToFileAtPath:path append:NO];
        [op setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
            NSLog(@"%lu %lld %lld",(unsigned long)bytesRead,totalBytesRead,totalBytesExpectedToRead);
        }];
        [op start];
    }
    
}
#pragma mark - prepareVC
-(void)updateVCWithObj:(episodeObject *)epObj{
    [self buildBookmarkObj];
   __weak episodeTVC *weakSelf  = self;
    [self.viImgEpiPic setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:epObj.episodeImageLink]]
                    withActivityIndicator:YES
                                  success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                          
                                          weakSelf.viImgEpiPic.alpha = 0;
                                          weakSelf.viImgEpiPic.image = image;
                                          [self prepareCellImgSize];
                                          [self.tableView reloadData];
                                          [UIView animateWithDuration:.3 animations:^{
                                              [self.view updateConstraintsIfNeeded];
                                              weakSelf.viImgEpiPic.alpha = 1;
                                          }];
                                      });
                                  } failure:Nil];
    
    if (epObj.episodeMp3Link.length == 0){
        self.btnMp3.alpha = .3;
        self.viImgMp3.alpha = .3;
    }
    if (epObj.episodeAviLink.length == 0){
        self.btnAvi.alpha = .3;
        self.viImgAvi.alpha = .3;
    }
    if (self.selEpiObj.episodeListenLink.length == 0){
        self.btnListen.alpha = .3;
        self.viImgListen.alpha = .3;
    }
    if (self.selEpiObj.episodeWatchLink.length == 0){
        self.btnYoutube.alpha = .3;
        self.viImgYoutube.alpha = .3;
    }
}
-(void)buildBookmarkObj{
    self.bookmarkObject                     = [bookmarkObj new];
    self.bookmarkObject.bookmarkContentID   = self.selEpiObj.episodeID;
    self.bookmarkObject.bookmarkTitle       = self.selEpiObj.episodeTitle;
    self.bookmarkObject.bookmarkImageLink   = self.selEpiObj.episodeImageLink;
    self.bookmarkObject.bookmarkType        = bookmarkTypeEpisode;
}

#pragma mark - prepareUI
-(void)prepareCellImgSize{
    cellImgSize = ((self.view.frame.size.width *self.viImgEpiPic.image.size.height)/self.viImgEpiPic.image.size.width);
}
-(void)prepareUI{
    [self updateNavigationBar];
}
-(void)updateNavigationBar{
    [((browseNavC *)self.navigationController)updateNavigationBarWithTitle:self.selEpiObj.episodeTitle
                                                                 andDetail:self.selEpiObj.episodeLecturer];
}

#pragma mark - orientations
-(void)addObserverOfOrientation{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
}
-(void)removeObserverOfOrientation{
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

@end
