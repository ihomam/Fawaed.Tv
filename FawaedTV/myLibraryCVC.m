//
//  myLibraryCVC.m
//  FawaedTV
//
//  Created by Homam on 2015-02-15.
//  Copyright (c) 2015 Homam. All rights reserved.
//

#import "myLibraryCVC.h"
#import "bookmarkObj.h"
#import "generalCVCCell.h"
#import "UIImageView+activity.h"
#import "browseMenuTVC.h"
#import "browseNavC.h"
#import "appTBVC.h"

#import "episodesCVC.h"
#import "categoriesCVC.h"
#import "lecturersCVC.h"
#import "episodeTVC.h"
#import "yearsCVC.h"

// model objects
#import "seriesObject.h"
#import "categoryObject.h"
#import "yearObject.h"
#import "lecturerObject.h"
#import "FCFileManager.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "fileObject.h"
#import "episodeObject.h"
#import "episodsManager.h"
typedef NS_ENUM(NSUInteger, libraryFilterType) {
    libraryFilterTypeSeries,
    libraryFilterTypeCategory,
    libraryFilterTypeLecturer,
    libraryFilterTypeYear,
    libraryFilterTypeEpisode,
    libraryFilterTypeLocalFiles,
};

@interface myLibraryCVC ()
@property (nonatomic,strong)            NSMutableArray          *dataSource;
@property (nonatomic,strong)            NSArray                 *dataSourceFileObjs;
@property (nonatomic,strong)            NSDictionary            *dataSourceDictionary;
@property (nonatomic,strong)            UITapGestureRecognizer  *tapGesture;
@property (nonatomic,weak)   IBOutlet   UIBarButtonItem         *btnFilter;
@property (nonatomic,strong)            browseMenuTVC           *vcBrowseMenu;
@property (nonatomic)                   libraryFilterType       filterType;
@end

@implementation myLibraryCVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.filterType = libraryFilterTypeLocalFiles;
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self prepareDataSourece];
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

#pragma mark - preoperties
-(void)setFilterType:(libraryFilterType)filterType{
    // if user tapped same value don nothing
    if (_filterType == filterType) return;
    
    // set the new value and reload the data
    _filterType = filterType;
    [self reloadDataSource];
}

#pragma mark - actions
-(void)refershControlAction{
    [self prepareDataSourece];
}
- (IBAction)filterBtnTapped:(UIBarButtonItem *)sender {
    [self displayFilterMenu];
}
- (IBAction)deleteFile:(UIButton *)btn{
    generalCVCCell *cell = (generalCVCCell *)btn.superview;
    while (![cell isKindOfClass:[generalCVCCell class]]) {
        cell = (generalCVCCell *)cell.superview;
    }
    
    NSIndexPath *indexPath  = [self.collectionView indexPathForCell:cell];
    NSString *fileName      = [self.dataSource objectAtIndex:indexPath.row];
    fileObject *fObj        = [fileObject getFileObjForFileName:fileName fromList:self.dataSourceFileObjs];
    episodeDownloadedFileType fType = episodeDownloadedFileAudio;
    if (fObj.fileType == fileTypeVideo) fType = episodeDownloadedFileVideo;
    
    [episodsManager episodeDeleted:[self episodeForFileName:fileName] type:fType];
    
    [self reloadDataSource];
}
-(void)collectionViewTappedWhileMenuIsVisible{
    [self hideFilterMenu];
}


#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    if (self.dataSource == Nil) {
        return 0;
    }
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataSource.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    generalCVCCell *cell;
    
    // Configure the cell
    switch (self.filterType) {
        case libraryFilterTypeYear:
            cell = [self cellWithTxtForCV:collectionView AtIndexPath:indexPath];
            break;
        case libraryFilterTypeLocalFiles:
            cell = [self cellWithImgAndTxtAndDetailsForCV:collectionView AtIndexPath:indexPath];
            break;
        default:
            cell = [self cellWithImgAndTxtForCV:collectionView AtIndexPath:indexPath];
            break;
    }
    
    return cell;
}
-(generalCVCCell *)cellWithImgAndTxtForCV:(UICollectionView *)cv AtIndexPath:(NSIndexPath *)indexPath {
    static NSString *reuseIdentifier = @"cellImgTxt";
    generalCVCCell *cell    = [cv dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    bookmarkObj *boObj      = [self.dataSource objectAtIndex:indexPath.row];
    cell.laTitle.text       = boObj.bookmarkTitle;
    
    // setting image
    cell.viImgPic.image     = Nil;
    __weak generalCVCCell *weakCell  = cell;
    [cell.viImgPic setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:boObj.bookmarkImageLink]]
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
-(generalCVCCell *)cellWithImgForCV:(UICollectionView *)cv AtIndexPath:(NSIndexPath *)indexPath {
    static NSString *reuseIdentifier = @"cellImg";
    generalCVCCell *cell    = [cv dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    bookmarkObj *boObj      = [self.dataSource objectAtIndex:indexPath.row];
    
    // setting image
    cell.viImgPic.image     = Nil;
    __weak generalCVCCell *weakCell  = cell;
    [cell.viImgPic setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:boObj.bookmarkImageLink]]
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
-(generalCVCCell *)cellWithTxtForCV:(UICollectionView *)cv AtIndexPath:(NSIndexPath *)indexPath {
    static NSString *reuseIdentifier = @"cellTxt";
    generalCVCCell *cell= [cv dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    bookmarkObj *boObj  = [self.dataSource objectAtIndex:indexPath.row];
    cell.laTitle.text   = boObj.bookmarkTitle;
    return cell;
}
-(generalCVCCell *)cellWithImgAndTxtAndDetailsForCV:(UICollectionView *)cv AtIndexPath:(NSIndexPath *)indexPath {
    static NSString *reuseIdentifier = @"cellLocalFile";
    generalCVCCell *cell    = [cv dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    NSString *fileName      = [self.dataSource objectAtIndex:indexPath.row];
    cell.laTitle.text       = fileName;
    cell.viImgPic.image     = [UIImage imageNamed:@"file"];
    cell.laDescription.text = @" ";
    fileObject *fObj        = [fileObject getFileObjForFileName:fileName fromList:self.dataSourceFileObjs];
    if (fObj) {
        cell.laTitle.text       = fObj.fileEpisodeTitle;
        cell.laDescription.text = [fObj getDescription];
        if (fObj.fileType == fileTypeVideo) [UIImage imageNamed:@"episode"];
    }

    // setting image
    return cell;
}


#pragma mark <UICollectionViewDelegateFlowLayout>
- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGSize cellSize = CGSizeZero;
    CGFloat CVWidth = self.collectionView.frame.size.width;
    NSInteger cloumnGeneral     = 2;
    NSInteger cloumnYearType    = 3;
    if ([UIApplication sharedApplication].statusBarOrientation != UIInterfaceOrientationPortrait){
        cloumnGeneral = 3;
        cloumnYearType = 4;
    }
    
    switch (self.filterType) {
        case libraryFilterTypeCategory:
            cellSize = CGSizeMake((CVWidth /cloumnGeneral) -10, (CVWidth /cloumnGeneral) -40);
            break;
        case libraryFilterTypeLocalFiles:
            cellSize = CGSizeMake(CVWidth - 10, 80);
            break;
        default:
            cellSize = CGSizeMake((CVWidth /cloumnGeneral) -10, (CVWidth /cloumnGeneral) -10);
            break;
    }
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
    switch (self.filterType) {
        case libraryFilterTypeLocalFiles:
            [self tappedFileOnIndexPath:indexPath];
            break;
        case libraryFilterTypeCategory:
            [self tappedCategoryOnIndexPath:indexPath];
            break;
        case libraryFilterTypeSeries:
            [self tappedSeriesOnIndexPath:indexPath];
            break;
        case libraryFilterTypeYear:
            [self tappedYearOnIndexPath:indexPath];
            break;
        case libraryFilterTypeLecturer:
            [self tappedLecturerOnIndexPath:indexPath];
            break;
        case libraryFilterTypeEpisode:
            [self tappedEpisodeOnIndexPath:indexPath];
            break;
        default:
            break;
    }
   
}
-(void)tappedSeriesOnIndexPath:(NSIndexPath *)indexPath{
    bookmarkObj *bObj   = [self.dataSource objectAtIndex:indexPath.row];
    seriesObject *sObj  = [seriesObject new];
    sObj.seriesID       = bObj.bookmarkContentID;
    sObj.seriesTitle    = bObj.bookmarkTitle;
    episodesCVC *vc     = [self.storyboard instantiateViewControllerWithIdentifier:@"episodesCVC"];
    vc.selObjSeries     = sObj;
    [self.navigationController pushViewController:vc animated:YES];
}
-(void)tappedCategoryOnIndexPath:(NSIndexPath *)indexPath{
    bookmarkObj *bObj       = [self.dataSource objectAtIndex:indexPath.row];
    categoryObject *cObj    = [categoryObject new];
    cObj.categoryID         = bObj.bookmarkContentID;
    cObj.categoryTitle      = bObj.bookmarkTitle;
    categoriesCVC *vc       = [self.storyboard instantiateViewControllerWithIdentifier:@"categoriesCVC"];
    vc.selCatObj            = cObj;
    [self.navigationController pushViewController:vc animated:YES];
}
-(void)tappedLecturerOnIndexPath:(NSIndexPath *)indexPath{
    bookmarkObj *bObj       = [self.dataSource objectAtIndex:indexPath.row];
    lecturerObject *lObj    = [lecturerObject new];
    lObj.lecturerID         = bObj.bookmarkContentID;
    lObj.lecturerTitle      = bObj.bookmarkTitle;
    lecturersCVC *vc        = [self.storyboard instantiateViewControllerWithIdentifier:@"lecturersCVC"];
    vc.selLecObj            = lObj;
    [self.navigationController pushViewController:vc animated:YES];
}
-(void)tappedYearOnIndexPath:(NSIndexPath *)indexPath{
    bookmarkObj *bObj       = [self.dataSource objectAtIndex:indexPath.row];
    yearObject *yObj        = [yearObject new];
    yObj.yearID             = bObj.bookmarkContentID;
    yObj.yearTitle          = bObj.bookmarkTitle;
    yearsCVC *vc            = [self.storyboard instantiateViewControllerWithIdentifier:@"yearsCVC"];
    vc.selYeObj             = yObj;
    [self.navigationController pushViewController:vc animated:YES];
}
-(void)tappedEpisodeOnIndexPath:(NSIndexPath *)indexPath{
    bookmarkObj *bObj       = [self.dataSource objectAtIndex:indexPath.row];
    episodeObject *eObj     = [episodeObject episodeObjectForBookmark:bObj];
    episodeTVC *vc          = [self.storyboard instantiateViewControllerWithIdentifier:@"episodeTVC"];
    vc.selEpiObj            = eObj;
    [self.navigationController pushViewController:vc animated:YES];
}
-(void)tappedFileOnIndexPath:(NSIndexPath *)indexPath{
    NSString *fileName  = [self.dataSource objectAtIndex:indexPath.row];
    fileObject *fObject = [fileObject getFileObjForFileName:fileName fromList:self.dataSourceFileObjs];
    episodeObject *epObj= [episodeObject episodeObjectForFile:fObject];
    playerType pType    = playerTypeAudioLocal;
    
    if (fObject.fileType == fileTypeVideo) pType = playerTypeVideoLocal;
    
    [((appTBVC *)self.tabBarController) buildFilePlayerForObject:epObj forType:pType];
}
#pragma mark - prepareVC
-(void)prepareDataSourece{
    self.dataSourceDictionary = [bookmarkObj getBookmarksFromDatabase];
    [self reloadDataSource];
}
-(void)reloadDataSource{
    [self updateNavigationBar];
    self.dataSource = self.dataSourceDictionary[@(self.filterType)];
    if (self.filterType == libraryFilterTypeLocalFiles) {
        self.dataSource             = [FCFileManager listMediaFilesInDocumentsDirectory].mutableCopy;
        self.dataSourceFileObjs     = [fileObject getFilesFromDatabase];
    }
    [self.collectionView reloadData];
}
#pragma mark - prepareUI
-(void)prepareUI{
    if (!self.dataSource)
        self.btnFilter.enabled = NO;
    
    [self updateNavigationBar];
    [self.btnFilter setImage:[browseMenuTVC menuIconForID:self.filterType]];
}
-(void)updateNavigationBar{
    // update navigation title name
    NSString *currentSubtitle = @"";
    switch (self.filterType) {
        case libraryFilterTypeSeries:
            currentSubtitle = NSLocalizedString(@"Programs", Nil);
            break;
        case libraryFilterTypeCategory:
            currentSubtitle = NSLocalizedString(@"Categories", Nil);
            break;
        case libraryFilterTypeYear:
            currentSubtitle = NSLocalizedString(@"Years", Nil);
            break;
        case libraryFilterTypeLecturer:
            currentSubtitle = NSLocalizedString(@"Lecturers", Nil);
            break;
        case libraryFilterTypeEpisode:
            currentSubtitle = NSLocalizedString(@"Episodes", Nil);
            break;
        case libraryFilterTypeLocalFiles:
            currentSubtitle = NSLocalizedString(@"Local Files", Nil);
            break;
        default:
            currentSubtitle = NSLocalizedString(@"Programs", Nil);
            break;
    }
    if([self.navigationController respondsToSelector:@selector(updateNavigationBarWithTitle:andDetail:)]){
        [((browseNavC *)self.navigationController) updateNavigationBarWithTitle:NSLocalizedString(@"My Library", Nil)
                                                                      andDetail:currentSubtitle];
    }
}
#pragma mark - filter menu
-(void)hideFilterMenu{
    [self.vcBrowseMenu hideCellsForRemovingVC];
    [UIView animateWithDuration:.6 animations:^{
        self.vcBrowseMenu.view.alpha = 0;
    } completion:^(BOOL finished) {
        [self.vcBrowseMenu willMoveToParentViewController:nil];
        [self.vcBrowseMenu.view removeFromSuperview];
        [self.vcBrowseMenu removeFromParentViewController];
        [self.collectionView removeGestureRecognizer:self.tapGesture];
        
        self.vcBrowseMenu   = Nil;
        self.tapGesture     = Nil;
    }];
}
-(void)displayFilterMenu{
    if (!self.vcBrowseMenu) {
        self.vcBrowseMenu = [self.storyboard instantiateViewControllerWithIdentifier:@"browseOptionsTVC"];
        
        // handel btn touch
        __weak myLibraryCVC *weakSelf = self;
        self.vcBrowseMenu.cellClickedCompletion = ^(cellName cellType, UIImage *imgTypeIcon){
            // change the datasource
            switch (cellType) {
                case cellProgram:
                    weakSelf.filterType = libraryFilterTypeSeries;
                    break;
                case cellCategory:
                    weakSelf.filterType = libraryFilterTypeCategory;
                    break;
                case cellLecturer:
                    weakSelf.filterType = libraryFilterTypeLecturer;
                    break;
                case cellYear:
                    weakSelf.filterType = libraryFilterTypeYear;
                    break;
                case cellEpisode:
                    weakSelf.filterType = libraryFilterTypeEpisode;
                    break;
                case cellLocalFile:
                    weakSelf.filterType = libraryFilterTypeLocalFiles;
                    break;
                default:
                    weakSelf.filterType = libraryFilterTypeSeries;
                    break;
            }
            
            // animate menu icon changing
            [weakSelf.btnFilter setImage:imgTypeIcon];
            
            // hide filter menu
            [weakSelf hideFilterMenu];
        };
        
    }
    if (![self.vcBrowseMenu.view isDescendantOfView:self.view]) {
        [self.vcBrowseMenu addSelfToVCAndAnimate:self withCellNumber:6];
        self.tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(collectionViewTappedWhileMenuIsVisible)];
        [self.collectionView addGestureRecognizer:self.tapGesture];
    }else{
        [self hideFilterMenu];
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
#pragma mark -
-(episodeObject *)episodeForFileName:(NSString *)fileName{
    fileObject *fObject = [fileObject getFileObjForFileName:fileName fromList:self.dataSourceFileObjs];
    bookmarkObj *bObj   = [bookmarkObj getBookmarkForContentID:fObject.fileEpisodeID];
    episodeObject *epObj= [episodeObject new];
    epObj.episodeID     = bObj.bookmarkContentID;
    epObj.episodeTitle  = bObj.bookmarkTitle;
    epObj.episodeLinkImage = bObj.bookmarkImageLink;
    
    NSString *filePath  = [NSString stringWithFormat:@"%@/%@",[FCFileManager pathForLibraryDirectory],fileName];
    epObj.episodeLinkMp3Local = filePath;
    playerType pType    = playerTypeAudioLocal;
    if (fObject.fileType == fileTypeVideo) {
        pType    = playerTypeVideoLocal;
        epObj.episodeLinkAviLocal = filePath;
        epObj.episodeLinkMp3Local = Nil;
    }
    return epObj;
}
@end
