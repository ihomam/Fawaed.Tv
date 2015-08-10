//
//  browseCVC.m
//  FawaedTV
//
//  Created by Homam on 2015-02-08.
//  Copyright (c) 2015 Homam. All rights reserved.
//

#import "browseCVC.h"
#import "serverManager.h"
#import "generalCVCCell.h"
#import "UIImageView+activity.h"

// model objects
#import "seriesObject.h"
#import "categoryObject.h"
#import "yearObject.h"
#import "lecturerObject.h"


// VCs
#import "episodesCVC.h"
#import "categoriesCVC.h"
#import "lecturersCVC.h"
#import "yearsCVC.h"
#import "browseMenuTVC.h"
#import "browseNavC.h"

@interface browseCVC ()<UISearchBarDelegate>
    @property (nonatomic,strong) NSMutableArray     *dataSource;
    @property (nonatomic,strong) NSDictionary       *dataSourceDictionary;
    @property (nonatomic,strong) UIRefreshControl   *refreshControl;
    @property (nonatomic,strong) NSArray            *dataSourceForSearchResult;
    @property (nonatomic,strong) UISearchBar        *searchBar;
    @property (nonatomic)        BOOL               searchBarActive;
    @property (nonatomic)        float              searchBarBoundsY;
    @property (nonatomic,strong) browseMenuTVC      *vcBrowseMenu;
    @property (nonatomic,strong) UITapGestureRecognizer *tapGesture;
    @property (nonatomic,weak)   IBOutlet UIBarButtonItem *btnFilter;
@end

@implementation browseCVC


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
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    // add KVO observer.. so we will be informed when user scroll colllectionView
    [self addObservers];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self removeObserverOfOrientation];
}
-(void)dealloc{
    // remove Our KVO observer
    [self removeObservers];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)deviceOrientationDidChange:(NSNotification *)notification {
    [self.collectionView.collectionViewLayout invalidateLayout];
}

#pragma mark - preoperties
-(void)setDataSourceType:(sourcetype)dataSourceType{
    // if user tapped same value don nothing
    if (_dataSourceType == dataSourceType)
        return;
    
    // set the new value and reload the data
    _dataSourceType = dataSourceType;
    [self dataSourceTypeChanged];
}

#pragma mark - actions
-(IBAction)refershBtnTapped:(id)sender{
    [self cancelSearching];
    CGFloat heightStatusBar = [UIApplication sharedApplication].statusBarFrame.size.height;
    CGFloat heightNaviBar   = self.navigationController.navigationBar.frame.size.height;
    CGFloat heightRefView   = self.refreshControl.frame.size.height;
    [self.collectionView setContentOffset:CGPointMake(0, -heightNaviBar-heightStatusBar-heightRefView) animated:YES];
    [self prepareDataSourece];
}
-(void)refershControlAction{
    [self cancelSearching];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // stop refreshing after 2 seconds
        [self prepareDataSourece];
    });
}
-(void)dataSourceTypeChanged{
    [self updateNavigationBar];
    self.dataSource = self.dataSourceDictionary[[NSString stringWithFormat:@"%d",(int)self.dataSourceType]];
    [self.collectionView reloadData];
}
- (IBAction)filterBtnTapped:(UIBarButtonItem *)sender {
    [self displayFilterMenu];
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
    if (self.searchBarActive) {
        return self.dataSourceForSearchResult.count;
    }
    return self.dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    generalCVCCell *cell;
    // Configure the cell
    NSArray *theDataSource = self.dataSource;
    if (self.searchBarActive) theDataSource = self.dataSourceForSearchResult;
    
    switch (self.dataSourceType) {
        case dataSourceTypePrograms:
            cell = [self cellForProgramsForCV:collectionView AtIndexPath:indexPath dataSource:theDataSource];
            break;
        case dataSourceTypeCategories:
            cell = [self cellForCategoriesForCV:collectionView AtIndexPath:indexPath dataSource:theDataSource];
            break;
        case dataSourceTypeYears:
            cell = [self cellForYearsForCV:collectionView AtIndexPath:indexPath dataSource:theDataSource];
            break;
        case dataSourceTypeLecturers:
            cell = [self cellForLecturersForCV:collectionView AtIndexPath:indexPath dataSource:theDataSource];
            break;
        default:
            cell = [self cellForProgramsForCV:collectionView AtIndexPath:indexPath dataSource:theDataSource];
            break;
    }
    return cell;
}
-(generalCVCCell *)cellForProgramsForCV:(UICollectionView *)cv AtIndexPath:(NSIndexPath *)indexPath dataSource:(NSArray *)dataSource {
    static NSString *reuseIdentifier = @"cellImgTxt";
    generalCVCCell *cell    = [cv dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    seriesObject *serObj    = [dataSource objectAtIndex:indexPath.row];
    cell.laTitle.text       = serObj.seriesTitle;
    
    // setting image
    cell.viImgPic.image     = Nil;
    __weak generalCVCCell *weakCell  = cell;
    [cell.viImgPic setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:serObj.seriesImageLink]]
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
-(generalCVCCell *)cellForCategoriesForCV:(UICollectionView *)cv AtIndexPath:(NSIndexPath *)indexPath dataSource:(NSArray *)dataSource {
    static NSString *reuseIdentifier = @"cellImg";
    generalCVCCell *cell    = [cv dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    categoryObject *catObj  = [dataSource objectAtIndex:indexPath.row];
    
    // setting image
    cell.viImgPic.image     = Nil;
    __weak generalCVCCell *weakCell  = cell;
    [cell.viImgPic setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:catObj.categoryImgLink]]
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

-(generalCVCCell *)cellForYearsForCV:(UICollectionView *)cv AtIndexPath:(NSIndexPath *)indexPath dataSource:(NSArray *)dataSource {
    static NSString *reuseIdentifier = @"cellTxt";
    generalCVCCell *cell= [cv dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    yearObject *yeaObj  = [dataSource objectAtIndex:indexPath.row];
    cell.laTitle.text   = yeaObj.yearTitle;
    return cell;
}

-(generalCVCCell *)cellForLecturersForCV:(UICollectionView *)cv AtIndexPath:(NSIndexPath *)indexPath dataSource:(NSArray *)dataSource {
    static NSString *reuseIdentifier = @"cellImgTxt";
    generalCVCCell *cell    = [cv dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    lecturerObject *lecObj  = [dataSource objectAtIndex:indexPath.row];
    cell.laTitle.text       = lecObj.lecturerTitle;
    
    // setting image
    cell.viImgPic.image     = Nil;
    __weak generalCVCCell *weakCell  = cell;
    [cell.viImgPic setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:lecObj.lecturerImgLink]]
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
    NSInteger cloumnYearType    = 3;
    if ([UIApplication sharedApplication].statusBarOrientation != UIInterfaceOrientationPortrait){
        cloumnGeneral = 3;
        cloumnYearType = 4;
    }
    
    switch (self.dataSourceType) {
        case dataSourceTypePrograms:
            cellSize = CGSizeMake((CVWidth /cloumnGeneral) -10, (CVWidth /cloumnGeneral) -10);
            break;
        case dataSourceTypeCategories:
            cellSize = CGSizeMake((CVWidth /cloumnGeneral) -10, (CVWidth /cloumnGeneral) -40);
            break;
        case dataSourceTypeYears:
            cellSize = CGSizeMake((CVWidth /cloumnYearType) -10, (CVWidth /cloumnYearType) -10);
            break;
        case dataSourceTypeLecturers:
            cellSize = CGSizeMake((CVWidth /cloumnGeneral) -10, (CVWidth /cloumnGeneral) -10);
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
    return UIEdgeInsetsMake(self.searchBar.frame.size.height + 5, 5, 0, 5);
}

#pragma mark <UICollectionViewDelegate>
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSArray *currentDataSource = self.dataSource;
    if (self.searchBarActive) currentDataSource= self.dataSourceForSearchResult;
    if (self.dataSourceType == dataSourceTypePrograms) {
        episodesCVC *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"episodesCVC"];
        vc.selObjSeries = [currentDataSource objectAtIndex:indexPath.row];
        [self searchBarCancelButtonClicked:Nil];
        [self.navigationController pushViewController:vc animated:YES];
    }else if (self.dataSourceType == dataSourceTypeCategories){
        categoriesCVC *vc   = [self.storyboard instantiateViewControllerWithIdentifier:@"categoriesCVC"];
        vc.selCatObj        = [currentDataSource objectAtIndex:indexPath.row];
        [self searchBarCancelButtonClicked:Nil];
        [self.navigationController pushViewController:vc animated:YES];
    }else if (self.dataSourceType == dataSourceTypeLecturers){
        lecturersCVC *vc    = [self.storyboard instantiateViewControllerWithIdentifier:@"lecturersCVC"];
        vc.selLecObj        = [currentDataSource objectAtIndex:indexPath.row];
        [self searchBarCancelButtonClicked:Nil];
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        yearsCVC *vc        = [self.storyboard instantiateViewControllerWithIdentifier:@"yearsCVC"];
        vc.selYeObj         = [currentDataSource objectAtIndex:indexPath.row];
        [self searchBarCancelButtonClicked:Nil];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - prepareVC
-(void)prepareDataSourece{
    [self addRefreshControl];
    [self startRefreshControl];
    self.dataSourceForSearchResult = [NSArray new];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [[serverManager sharedServerObj]getWholeSchemaObjectWithCompleation:^(BOOL finishedSuccessfully,
                                                                             NSMutableArray *resultOfSeries,
                                                                             NSMutableArray *resultOfCategories,
                                                                             NSMutableArray *resultOfYears,
                                                                             NSMutableArray *resultOfLecturers) {
            
            if (finishedSuccessfully) {
                switch (self.dataSourceType) {
                    case dataSourceTypePrograms:
                        self.dataSource = resultOfSeries;
                        break;
                    case dataSourceTypeCategories:
                        self.dataSource = resultOfCategories;
                        break;
                    case dataSourceTypeYears:
                        self.dataSource = resultOfYears;
                        break;
                    case dataSourceTypeLecturers:
                        self.dataSource = resultOfLecturers;
                        break;
                    default:
                        self.dataSource = resultOfSeries;
                        break;
                }
                self.dataSourceDictionary = @{[NSString stringWithFormat:@"%ld",(long)dataSourceTypeCategories]:resultOfCategories,
                                              [NSString stringWithFormat:@"%ld",(long)dataSourceTypeLecturers]:resultOfLecturers,
                                              [NSString stringWithFormat:@"%ld",(long)dataSourceTypePrograms]:resultOfSeries,
                                              [NSString stringWithFormat:@"%ld",(long)dataSourceTypeYears]:resultOfYears};
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.dataSource)self.btnFilter.enabled = YES;
                if (self.dataSource.count>0) self.searchBar.hidden = NO;
                [self.refreshControl endRefreshing];
                [self.collectionView reloadData];
            });
        }];
    });
}
#pragma mark - prepareUI
-(void)prepareUI{
    [self addSearchBar];
    if (!self.dataSource)
        self.btnFilter.enabled = NO;
    
    [self updateNavigationBar];
}
-(void)updateNavigationBar{
    NSString *currentSubtitle = @"";
    switch (self.dataSourceType) {
        case dataSourceTypePrograms:
            currentSubtitle = NSLocalizedString(@"Programs", Nil);
            break;
        case dataSourceTypeCategories:
            currentSubtitle = NSLocalizedString(@"Categories", Nil);
            break;
        case dataSourceTypeYears:
            currentSubtitle = NSLocalizedString(@"Years", Nil);
            break;
        case dataSourceTypeLecturers:
            currentSubtitle = NSLocalizedString(@"Lecturers", Nil);
            break;
        default:
            currentSubtitle = NSLocalizedString(@"Programs", Nil);
            break;
    }
    [((browseNavC *)self.navigationController)updateNavigationBarWithTitle:NSLocalizedString(@"FawaedTv", Nil)
                                                                 andDetail:currentSubtitle];
}
-(void)addSearchBar{
    if (!self.searchBar) {
        self.searchBarBoundsY = self.navigationController.navigationBar.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height;
        self.searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0,self.searchBarBoundsY, [UIScreen mainScreen].bounds.size.width, 44)];
        self.searchBar.searchBarStyle       = UISearchBarStyleMinimal;
        self.searchBar.delegate             = self;
        self.searchBar.placeholder          = NSLocalizedString(@"search here", Nil) ;
        self.searchBar.hidden               = YES;
        self.searchBar.tintColor            = [UIColor grayColor];
        self.searchBar.barTintColor         = [UIColor grayColor];
        self.searchBar.autoresizingMask     = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth| UIViewAutoresizingFlexibleRightMargin;
    }
    
    if (![self.searchBar isDescendantOfView:self.view]) {
        [self.view addSubview:self.searchBar];
    }
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
#pragma mark - search
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope{
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        BOOL result = NO;
        switch (self.dataSourceType) {
            case dataSourceTypePrograms:
                result = [self string:((seriesObject *)evaluatedObject).seriesTitle containsString:searchText];
                break;
            case dataSourceTypeCategories:
                result = [self string:((categoryObject *)evaluatedObject).categoryTitle containsString:searchText];
                break;
            case dataSourceTypeLecturers:
                result = [self string:((lecturerObject *)evaluatedObject).lecturerTitle containsString:searchText];
                break;
            case dataSourceTypeYears:
                result = [self string:((yearObject *)evaluatedObject).yearTitle containsString:searchText];
                break;
            default:
                break;
        }
        return result;
    }];

    self.dataSourceForSearchResult  = [self.dataSource.copy filteredArrayUsingPredicate:predicate];
}
- (BOOL)string:(NSString *)string1 containsString:(NSString *)string2{
    BOOL result = NO;
    if ([string1 rangeOfString:string2].location != NSNotFound)
        result = YES;
    
    return result;
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    // user did type something, check our datasource for text that looks the same
    if (searchText.length>0) {
        // search and reload data source
        self.searchBarActive = YES;
        [self filterContentForSearchText:searchText
                                   scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                          objectAtIndex:[self.searchDisplayController.searchBar
                                                         selectedScopeButtonIndex]]];
        [self.collectionView reloadData];
    }else{
        // if text lenght == 0
        // we will consider the searchbar is not active
        self.searchBarActive = NO;
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [self cancelSearching];
    [self.collectionView reloadData];
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    /// end editing so keyboard get disappeared
    [self.view endEditing:YES];
    /// calling the above method will set searchBarActive to no, so we should set it back again
    /// user didn't finish yet
    self.searchBarActive = YES;
}
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    // we used here to set self.searchBarActive = YES
    // but we'll not do that any more... it made problems
    // it's better to set self.searchBarActive = YES when user typed something
    [self.searchBar setShowsCancelButton:YES animated:YES];
    self.collectionView.contentInset = UIEdgeInsetsMake(self.collectionView.contentInset.top,
                                                        self.collectionView.contentInset.left,
                                                        self.collectionView.contentInset.bottom + 210,
                                                        self.collectionView.contentInset.right);
}
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
    // this method is being called when search btn in the keyboard tapped
    // we set searchBarActive = NO
    // but no need to reloadCollectionView
    self.searchBarActive = NO;
    [self.searchBar setShowsCancelButton:NO animated:YES];
        self.collectionView.contentInset = UIEdgeInsetsMake(self.collectionView.contentInset.top,
                                                            self.collectionView.contentInset.left,
                                                            self.collectionView.contentInset.bottom - 210,
                                                            self.collectionView.contentInset.right);
}
-(void)cancelSearching{
    self.searchBarActive = NO;
    [self.searchBar resignFirstResponder];
    self.searchBar.text  = @"";
}
#pragma mark - observer
- (void)addObservers{
    [self.collectionView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
}
- (void)removeObservers{
    [self.collectionView removeObserver:self forKeyPath:@"contentOffset" context:Nil];
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(UICollectionView *)object change:(NSDictionary *)change context:(void *)context{
    if ([keyPath isEqualToString:@"contentOffset"] && object == self.collectionView ) {
        self.searchBar.frame = CGRectMake(self.searchBar.frame.origin.x,
                                          self.searchBarBoundsY + ((-1* object.contentOffset.y)-self.searchBarBoundsY),
                                          self.searchBar.frame.size.width,
                                          self.searchBar.frame.size.height);
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
        __weak browseCVC *weakSelf = self;
        self.vcBrowseMenu.cellClickedCompletion = ^(cellName cellType, UIImage *imgTypeIcon){
            [weakSelf searchBarCancelButtonClicked:Nil];
            
            // change the datasource
            switch (cellType) {
                case cellProgram:
                    weakSelf.dataSourceType = dataSourceTypePrograms;
                    break;
                case cellCategory:
                    weakSelf.dataSourceType = dataSourceTypeCategories;
                    break;
                case cellLecturer:
                    weakSelf.dataSourceType = dataSourceTypeLecturers;
                    break;
                case cellYear:
                    weakSelf.dataSourceType = dataSourceTypeYears;
                    break;
                default:
                    weakSelf.dataSourceType = dataSourceTypePrograms;
                    break;
            }
            
            // animate menu icon changing
            [weakSelf.btnFilter setImage:imgTypeIcon];
            
            // hide filter menu
            [weakSelf hideFilterMenu];
        };
        
    }
    if (![self.vcBrowseMenu.view isDescendantOfView:self.view]) {
        [self.vcBrowseMenu addSelfToVCAndAnimate:self withCellNumber:4];
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
@end
