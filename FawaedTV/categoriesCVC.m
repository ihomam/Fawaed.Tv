//
//  categoriesCVC.m
//  FawaedTV
//
//  Created by Homam on 2015-03-31.
//  Copyright (c) 2015 Homam. All rights reserved.
//

#import "categoriesCVC.h"
#import "serverManager.h"
#import "generalCVCCell.h"
#import "UIImageView+activity.h"
#import "browseNavC.h"

#import "categoryObject.h"
#import "bookmarkObj.h"
#import "episodesCVC.h"

@interface categoriesCVC ()
    @property (nonatomic,strong) NSMutableArray     *dataSource;
    @property (nonatomic,strong) UIRefreshControl   *refreshControl;
    @property (nonatomic,strong) bookmarkObj        *bookmarkObject;
@end

@implementation categoriesCVC
- (void)viewDidLoad {
    [super viewDidLoad];
    
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
    seriesObject *sObj      = [self.dataSource objectAtIndex:indexPath.row];
    cell.laTitle.text       = sObj.seriesTitle;
    
    // setting image
    cell.viImgPic.image     = Nil;
    __weak generalCVCCell *weakCell  = cell;
    [cell.viImgPic setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:sObj.seriesImageLink]]
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
    episodesCVC *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"episodesCVC"];
    vc.selObjSeries = [self.dataSource objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:vc animated:YES];
}
#pragma mark - prepareVC
-(void)prepareDataSourece{
    [self buildBookmarkObj];
    [self addRefreshControl];
    [self startRefreshControl];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [[serverManager sharedServerObj]getAllSeriesOfCategory:self.selCatObj WithCompleation:^(categoryObject *result) {
            self.dataSource = result.categorySeriesArray;
            self.selCatObj.categorySeriesArray = result.categorySeriesArray;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self updateNavigationBar];
                [self.refreshControl endRefreshing];
                [self.collectionView reloadData];
            });
        }];
    });
}

#pragma mark - prepareUI
-(void)prepareUI{
    [self updateNavigationBar];
    [self buildBookmarkBtnBar];
}
-(void)updateNavigationBar{
    NSString *subTitle = [NSString stringWithFormat:@"%d %@",(int)self.selCatObj.categorySeriesArray.count,NSLocalizedString(@"Series", Nil)];
    [((browseNavC *)self.navigationController)updateNavigationBarWithTitle:self.selCatObj.categoryTitle
                                                                 andDetail:subTitle];
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
-(void)buildBookmarkObj{
    self.bookmarkObject                     = [bookmarkObj new];
    self.bookmarkObject.bookmarkContentID   = self.selCatObj.categoryID;
    self.bookmarkObject.bookmarkTitle       = self.selCatObj.categoryTitle;
    self.bookmarkObject.bookmarkImageLink   = self.selCatObj.categoryImgLink;
    self.bookmarkObject.bookmarkType        = bookmarkTypeCategory;
}
-(void)buildBookmarkBtnBar{
    [self.bookmarkObject isAlreadyAvailableInDBWithCompletion:^(bookmarkObj *obj) {
        if (obj) {
            self.bookmarkObject = obj;
            [self buildForRightNavigationItemAnEmptyBtnBookmark:NO];
        }else{
            [self buildForRightNavigationItemAnEmptyBtnBookmark:YES];
        }
        
    }];
}
-(void)buildForRightNavigationItemAnEmptyBtnBookmark:(BOOL)empty{
    UIImage *imgBtnBmark;
    if (empty) {
        imgBtnBmark    = [UIImage imageNamed:@"btnBookmark"];
    }else{
        imgBtnBmark    = [UIImage imageNamed:@"btnBookmarked"];
    }
    UIButton *btnBookMark   = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnBookMark setTitle:@"menu" forState:UIControlStateNormal];
    [btnBookMark setFrame:CGRectMake(0, 0, imgBtnBmark.size.width, imgBtnBmark.size.height)];
    [btnBookMark setImage:imgBtnBmark forState:UIControlStateNormal];
    [btnBookMark addTarget:self action:@selector(toggleBookmark) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:btnBookMark];
}

-(void)toggleBookmark{
    if (self.bookmarkObject.bookmarkID > 0){
        // .1 this object is already in db and the usr wants to delete it
        [self.bookmarkObject removeFromDataBase];
        
        // .2 re prepare the new bookmark obj
        [self buildBookmarkObj];
        
        // .3 update  bookmarrk barbuttonitem
        [self buildForRightNavigationItemAnEmptyBtnBookmark:YES];
    }else{
        // .1 user wants to add this page to bookmarks
        __weak categoriesCVC *weakself = self;
        
        // .2 re prepare the new bookmark obj
        [self.bookmarkObject addToDataBaseWithCompletion:^(bookmarkObj *newObj) {
            weakself.bookmarkObject = newObj;
        }];
        
        // .3 update  bookmark barbuttonitem
        [self buildForRightNavigationItemAnEmptyBtnBookmark:NO];
    }
}
@end
