//
//  episodesCVC.m
//  FawaedTV
//
//  Created by Homam on 2015-02-09.
//  Copyright (c) 2015 Homam. All rights reserved.
//

#import "episodesCVC.h"
#import "serverObject.h"
#import "generalCVCCell.h"
#import "UIImageView+activity.h"
#import "browseNavC.h"

#import "episodeObject.h"
#import "bookmarkObj.h"
#import "episodeTVC.h"

@interface episodesCVC ()
    @property (nonatomic,strong) NSMutableArray     *dataSource;
    @property (nonatomic,strong) UIRefreshControl   *refreshControl;
@end

@implementation episodesCVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    [self prepareDataSourece];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self prepareUI];
    [self addObserverOfOrientation];
    [self.collectionViewLayout invalidateLayout];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self removeObserverOfOrientation];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)deviceOrientationDidChange:(NSNotification *)notification {
    [self.collectionView.collectionViewLayout invalidateLayout];
}
#pragma mark - actions
-(void)refershControlAction{
    [self prepareDataSourece];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *reuseIdentifier = @"cellImgTxt";
    generalCVCCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    // Configure the cell
    episodeObject *epObj    = [self.dataSource objectAtIndex:indexPath.row];
    cell.laTitle.text       = epObj.episodeTitle;
    
    // setting image
    cell.viImgPic.image     = Nil;
    __weak generalCVCCell *weakCell  = cell;
    [cell.viImgPic setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:epObj.episodeImageLink]]
                    withActivityIndicator:YES
                                  success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                          
                                          weakCell.viImgPic.alpha = 0;
                                          weakCell.viImgPic.image = image;
                                          
                                          [UIView animateWithDuration:.3 animations:^{
                                              weakCell.viImgPic.alpha = 1;
                                          }];
                                      });
                                  } failure:Nil];
    return cell;
}
#pragma mark <UICollectionViewDelegateFlowLayout>
- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGSize cellSize = CGSizeZero;
    CGFloat CVWidth = self.collectionView.frame.size.width;
    NSInteger cloumnGeneral     = 2;
    if ([UIApplication sharedApplication].statusBarOrientation != UIInterfaceOrientationPortrait){cloumnGeneral = 3;}
    cellSize = CGSizeMake((CVWidth /cloumnGeneral) -10, (CVWidth /cloumnGeneral) -10);

    return cellSize;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout *)collectionViewLayout
minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 10;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout *)collectionViewLayout
minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 5;
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout*)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(5, 5, 0, 5);
}
#pragma mark <UICollectionViewDelegate>
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    episodeTVC *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"episodeTVC"];
    vc.selEpiObj = [self.dataSource objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:vc animated:YES];    
}
#pragma mark - prepareVC
-(void)prepareDataSourece{
    [self buildBookmarkObj];
    [self addRefreshControl];
    [self startRefreshControl];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [[serverObject sharedServerObj]getAllEpisodesOfSeries:self.selObjSeries WithCompleation:^(seriesObject *result) {
            self.dataSource = result.seriesLectures;
            self.selObjSeries.seriesLecturer = result.seriesLecturer;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self updateNavigationBar];
                [self.refreshControl endRefreshing];
                [self.collectionView reloadData];
            });
        }];
    });
}
-(void)buildBookmarkObj{
    self.bookmarkObject                     = [bookmarkObj new];
    self.bookmarkObject.bookmarkContentID   = self.selObjSeries.seriesID;
    self.bookmarkObject.bookmarkTitle       = self.selObjSeries.seriesTitle;
    self.bookmarkObject.bookmarkImageLink   = self.selObjSeries.seriesImageLink;
    self.bookmarkObject.bookmarkType        = bookmarkTypeSeries;
}
#pragma mark - prepareUI
-(void)prepareUI{
    [self updateNavigationBar];
}
-(void)updateNavigationBar{
    [((browseNavC *)self.navigationController)updateNavigationBarWithTitle:self.selObjSeries.seriesTitle
                                                                 andDetail:self.selObjSeries.seriesLecturer];
}
-(void)addRefreshControl{
    if (!self.refreshControl) {
        self.refreshControl                  = [UIRefreshControl new];
        self.refreshControl.tintColor        = [UIColor lightGrayColor];
        [self.refreshControl addTarget:self
                                action:@selector(refershControlAction)
                      forControlEvents:UIControlEventValueChanged];
    }
    if (![self.refreshControl isDescendantOfView:self.collectionView]) {
        [self.collectionView addSubview:self.refreshControl];
    }
}
-(void)startRefreshControl{
    if (!self.refreshControl.refreshing) {
        [self.refreshControl beginRefreshing];
    }
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
#pragma mark - bookmarks 
-(void)addToBookmarks{
    NSLog(@"%d %@ %@",self.selObjSeries.seriesID,self.selObjSeries.seriesTitle,self.selObjSeries.seriesImageLink);
}
@end
