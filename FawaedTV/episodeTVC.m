//
//  episodeVC.m
//  FawaedTV
//
//  Created by Homam on 2015-02-09.
//  Copyright (c) 2015 Homam. All rights reserved.
//

#import "episodeTVC.h"
#import "serverManager.h"
#import "UIImageView+activity.h"
#import "browseNavC.h"

#import "episodeObject.h"
#import "AFSoundManager.h"
#import "PBYouTubeVideoViewController.h"
#import "appTBVC.h"
#import "bookmarkObj.h"
#import "downloadManager.h"
#import "ddProgressBtn.h"

#import "episodsManager.h"
#import "UIImage+BlurredFrame.h"

@interface episodeTVC (){
    CGFloat cellImgSize;
}

    @property (weak, nonatomic) IBOutlet UIButton           *btnYoutube;
    @property (weak, nonatomic) IBOutlet UIButton           *btnAvi;
    @property (weak, nonatomic) IBOutlet UIButton           *btnListen;
    @property (weak, nonatomic) IBOutlet UIButton           *btnMp3;
    @property (weak, nonatomic) IBOutlet ddProgressBtn      *btnVBPMp3;
    @property (weak, nonatomic) IBOutlet ddProgressBtn      *btnVBPAvi;
    @property (weak, nonatomic) IBOutlet UILabel            *laEpsoideTitle;
    @property (nonatomic,strong) bookmarkObj                *bookmarkObject;
@end

@implementation episodeTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.btnListen addTarget:self action:@selector(listenOnline) forControlEvents:UIControlEventTouchUpInside];
    [self.btnYoutube addTarget:self action:@selector(watchYoutube) forControlEvents:UIControlEventTouchUpInside];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self updateVCWithObj:self.selEpiObj];
    [self prepareUI];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - actions 
-(void)listenOnline{
    if (self.selEpiObj.episodeLinkListen.length > 0) {
        [((appTBVC *)self.tabBarController) buildFilePlayerForObject:self.selEpiObj forType:playerTypeAudioOnline];
    }
}
-(void)watchYoutube{
    if (self.selEpiObj.episodeLinkWatch.length > 0){
        NSRange vRange = [self.selEpiObj.episodeLinkWatch rangeOfString:@"?v="];
        NSString *viID = [self.selEpiObj.episodeLinkWatch substringFromIndex:vRange.location+vRange.length];
        [((appTBVC *)self.tabBarController) buildFilePlayerForObject:viID forType:playerTypeVideoOnline];
    }
}
- (IBAction)downloadAVI:(id)sender {
    return;
//    ////
//    if (self.btnVBPAvi.currentButtonType == buttonRightTriangleType) {
//        // means we should play the file not download
//        NSLog(@"playing the video... hehe");
//        return;
//    }
//    if (self.selEpiObj.episodeLinkAvi.length > 0) {
//        __weak __block episodeDownloadObject *epDownObj;
//        epDownObj  = [[downloadManager sharedDownloadObj]downloadThisEpisode:self.selEpiObj soundFile:NO];
//        if(epDownObj){
//            [self.btnVBPAvi handelEpDownObj:epDownObj];
//            epDownObj.episodeDownloadBlock = ^(){[self handleBtnDownloadProgress:self.btnVBPAvi andEpDownObja:epDownObj];};
//        }
//    }
}
- (IBAction)downloadMp3:(id)sender {
    // @TODO check this code
    if (self.btnVBPMp3.currentButtonType == buttonRightTriangleType ) {
        // means we should play the file not download
        [((appTBVC *)self.tabBarController) buildFilePlayerForObject:self.selEpiObj forType:playerTypeAudioLocal];
        [self.btnVBPMp3 animateToType:buttonSquareType];
        return;
    }
    
    if (self.selEpiObj.episodeLinkMp3.length > 0){
        __weak __block episodeDownloadObject *epDownObj;
        epDownObj  = [[downloadManager sharedDownloadObj]downloadThisEpisode:self.selEpiObj soundFile:YES];
        if(epDownObj){
            [self.btnVBPMp3 handelEpDownObj:epDownObj];
            epDownObj.episodeDownloadBlock = ^(){[self handleBtnDownloadProgress:self.btnVBPMp3 andEpDownObja:epDownObj];};
        } 
    }
}
#pragma mark - prepareVC
-(void)updateVCWithObj:(episodeObject *)epObj{
    [self buildBookmarkObj];
    if (!((UIImageView *)self.tableView.backgroundView).image) {
        __block UIImageView *bg         = [UIImageView new];
        bg.backgroundColor              = [UIColor darkGrayColor];
        __weak UIImageView *weakbg      = bg;
        bg.contentMode                  = UIViewContentModeScaleAspectFill;
        self.tableView.backgroundView   = bg;
        [bg setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:epObj.episodeLinkImage]]
             withActivityIndicator:YES
                           success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                               dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                                   UIImage *imgBlured = [image applyBlurWithRadius:1.7
                                                                         tintColor:[UIColor colorWithWhite:.1 alpha:.6]
                                                             saturationDeltaFactor:1
                                                                         maskImage:Nil
                                                                           atFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       weakbg.alpha = 0;
                                       weakbg.image = imgBlured;
                                       [UIView animateWithDuration:.5 animations:^{
                                           weakbg.alpha = 1;
                                       }];
                                   });
                               });
                           } failure:Nil];
    }
}
#pragma mark - prepareUI
-(void)prepareUI{
    self.tableView.backgroundColor = [UIColor darkGrayColor];
    [self updateNavigationBar];
    [self buildBookmarkBtnBar];
    [self checkForBtnDownloadProgress];
    [self prepareBtns];
}

-(void)updateNavigationBar{
    [((browseNavC *)self.navigationController)updateNavigationBarWithTitle:self.selEpiObj.episodeSeriesTitle
                                                                 andDetail:self.selEpiObj.episodeLecturer];
    self.laEpsoideTitle.text = self.selEpiObj.episodeTitle;
}
-(void)prepareBtns{
    self.btnVBPMp3.tintColor = [UIColor whiteColor];
    self.btnVBPAvi.tintColor = [UIColor whiteColor];
    
    if (self.selEpiObj.episodeLinkMp3.length == 0){
        self.btnMp3.alpha       = .3;
        self.btnVBPMp3.alpha    = .3;
    }
//    if (self.selEpiObj.episodeLinkAvi.length == 0){
        self.btnAvi.alpha       = .3;
        self.btnVBPAvi.alpha    = .3;
//    }
    if (self.selEpiObj.episodeLinkListen.length == 0){
        self.btnListen.alpha    = .3;
    }
    if (self.selEpiObj.episodeLinkWatch.length == 0){
        self.btnYoutube.alpha   = .3;
    }
    
    if ([self.selEpiObj checkIfMp3FileInLocalFolder]){
        [self.btnMp3 setTitle:NSLocalizedString(@" Play audio", Nil) forState:UIControlStateNormal];
    }
    
    if ([self.selEpiObj checkIfAviFileInLocalFolder]){
        [self.btnAvi setTitle:NSLocalizedString(@" Play video", Nil) forState:UIControlStateNormal];
    }
    
    self.btnAvi.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.btnMp3.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.btnAvi.titleLabel.minimumScaleFactor = .8;
    self.btnMp3.titleLabel.minimumScaleFactor = .8;
}

#pragma mark - bookmarks
-(void)buildBookmarkObj{
    self.bookmarkObject                     = [bookmarkObj new];
    self.bookmarkObject.bookmarkContentID   = self.selEpiObj.episodeID;
    self.bookmarkObject.bookmarkTitle       = self.selEpiObj.episodeTitle;
    self.bookmarkObject.bookmarkImageLink   = self.selEpiObj.episodeLinkImage;
    self.bookmarkObject.bookmarkType        = bookmarkTypeEpisode;
}
-(void)buildBookmarkBtnBar{
    [self.bookmarkObject isAlreadyAvailableInDBWithCompletion:^(bookmarkObj *obj) {
        if (obj) {
            self.bookmarkObject = obj;
            [self buildBookmarkBtnWithEmptyState:NO];
        }else{
            [self buildBookmarkBtnWithEmptyState:YES];
        }
    }];
}
-(void)buildBookmarkBtnWithEmptyState:(BOOL)empty{
    UIImage *imgBtnBmark;
    if (empty) {
        imgBtnBmark    = [UIImage imageNamed:@"btnBookmark"];
    }else{
        imgBtnBmark    = [UIImage imageNamed:@"btnBookmarked"];
    }
    UIButton *btnBookMark   = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnBookMark setFrame:CGRectMake(0, 0, imgBtnBmark.size.width, imgBtnBmark.size.height)];
    [btnBookMark setImage:imgBtnBmark forState:UIControlStateNormal];
    [btnBookMark addTarget:self action:@selector(toggleBookmark) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:btnBookMark];
}
#pragma mark - download button
-(void)checkForBtnDownloadProgress{
    //    @TODO apply for videos
    
    
    // .0 check if file is  already available in user folder
    if ([self.selEpiObj checkIfMp3FileInLocalFolder]){
        [episodsManager episodeDownloaded:self.selEpiObj type:episodeDownloadedFileAudio];
        [self buildBookmarkBtnWithEmptyState:NO];
        [self.btnVBPMp3 setCurrentButtonType:buttonRightTriangleType];
    }else{
        // @TODO document here
        // @TODO change btn name to play sound instead of download sound
        __weak __block episodeDownloadObject *epDownObj;
        epDownObj = [downloadManager sharedDownloadObj].listOfDownloadedObjs[self.selEpiObj.episodeLinkMp3];
        if (epDownObj){
            [self handleBtnDownloadProgress:self.btnVBPMp3 andEpDownObja:epDownObj];
            epDownObj.episodeDownloadBlock  = ^(){
                [self handleBtnDownloadProgress:self.btnVBPMp3 andEpDownObja:epDownObj];
            };
        }else{
            [self handleBtnDownloadProgress:self.btnVBPMp3 andEpDownObja:Nil];
        }
    }
    
    if ([self.selEpiObj checkIfAviFileInLocalFolder]) {
        [episodsManager episodeDownloaded:self.selEpiObj type:episodeDownloadedFileVideo];
        [self buildBookmarkBtnWithEmptyState:NO];
        [self.btnVBPAvi setCurrentButtonType:buttonRightTriangleType];
    }else{
        __weak __block episodeDownloadObject *epDownObj;
        epDownObj = [downloadManager sharedDownloadObj].listOfDownloadedObjs[self.selEpiObj.episodeLinkAvi];
        if (epDownObj){
            [self handleBtnDownloadProgress:self.btnVBPAvi andEpDownObja:epDownObj];
            epDownObj.episodeDownloadBlock  = ^(){
                [self handleBtnDownloadProgress:self.btnVBPAvi andEpDownObja:epDownObj];
            };
        }else{
            [self handleBtnDownloadProgress:self.btnVBPAvi andEpDownObja:Nil];
        }
    }
}
-(void)handleBtnDownloadProgress:(ddProgressBtn *)btn andEpDownObja:(episodeDownloadObject *)epDownObja{
    [btn handelEpDownObj:epDownObja];
    if (epDownObja.episodeDownloadCurrentStatus == downloadStatusFinished) {
        [self buildBookmarkBtnWithEmptyState:NO];
    }
}
#pragma mark - bookmarks
-(void)toggleBookmark{
    if (self.bookmarkObject.bookmarkID > 0){
        // .1 this object is already in db and the usr wants to delete it
        [self.bookmarkObject removeFromDataBase];

        // .2 re prepare the new bookmark obj
        [self buildBookmarkObj];
        
        // .3 update  bookmarrk barbuttonitem
        [self buildBookmarkBtnWithEmptyState:YES];
    }else{
        // .1 user wants to add this page to bookmarks
        __weak episodeTVC *weakself = self;
        
        // .2 re prepare the new bookmark obj
        [self.bookmarkObject addToDataBaseWithCompletion:^(bookmarkObj *newObj) {
            weakself.bookmarkObject = newObj;
        }];
        
        // .2.1 add the episode object to db
        [self.selEpiObj addToDatabase];
        
        // .3 update  bookmark barbuttonitem
        [self buildBookmarkBtnWithEmptyState:NO];
    }
}
@end
