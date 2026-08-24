//
//  TYNestedSideScrollViewController.m
//  TT
//
//  Created by JiaNa on 2020/12/11.
//

#import "TYNestedSideScrollViewController.h"
#import "TYNestedTableViewCell.h"
#import <Masonry/Masonry.h>
#import "TYNestedTableView.h"

@interface TYNestedSideScrollViewController ()
<UITableViewDataSource,
UITableViewDelegate,
UIGestureRecognizerDelegate>

@property (nonatomic, weak) UIView *canvasView;
@property (nonatomic, strong) UIView *dashboardContainerView;
@property (nonatomic, strong) UIView *menuContainerView;
@property (nonatomic, strong) TYNestedTableView *tableView;

@property (nonatomic, assign, readonly) CGFloat dashboardHeight;
@property (nonatomic, assign, readonly) CGFloat menuHeight;
@property (nonatomic, assign, readonly) CGFloat contentVCHeight;

@property (nonatomic, assign) BOOL canParentViewScroll;
@property (nonatomic, assign) BOOL canChildViewScroll;

/// 当前显示的内容子VC
@property (nonatomic, weak, readonly) UIViewController<TYNestedSideScrollContentVC> *currentContentVC;
@property (nonatomic, weak, readonly) TYNestedTableViewCell *currentTableCell;

@end

@implementation TYNestedSideScrollViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initViews];
}

- (void)initViews {
    if (!self.canvasView) {
        return;
    }
    
    [self.canvasView addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    self.tableView.tableHeaderView = self.dashboardContainerView;
    
    self.canParentViewScroll = YES;
    self.canChildViewScroll = NO;
    
    [self reloadDashboard];
    [self reloadMenu];
}

- (void)updateDashboardHeight:(CGFloat)height {
    NSAssert(height >= 0, @"dashboard height must greater or equal to zero");
    
    if (height == 0) {
        self.tableView.tableHeaderView = nil;
    } else {
        self.dashboardContainerView.frame = CGRectMake(0, 0, 0, height);
        self.tableView.tableHeaderView = self.dashboardContainerView;
    }
    [self.tableView reloadData];
}

- (void)updateMenuHeight:(CGFloat)height {
    NSAssert(height >= 0, @"menu height must greater or equal to zero");
    
    if (height == 0) {
        height = 0.01;// 解决部分系统用0还是会有间距的问题
    }
    self.menuContainerView.frame = CGRectMake(0, 0, 0, height);
    [self.tableView reloadData];
}

- (void)reloadData {
    [self reloadDashboard];
    [self reloadMenu];
    [self reloadContentVC];
    [self.tableView reloadData];
}

- (void)reloadDashboard {
    UIView *dashboard = nil;
    if ([self.dataSource respondsToSelector:@selector(dashboardView)]) {
        dashboard = [self.dataSource dashboardView];
    }
    
    if (dashboard) {
        if (![self.dashboardContainerView.subviews containsObject:dashboard]) {
            for (UIView *subView in self.dashboardContainerView.subviews) {
                [subView removeFromSuperview];
            }
            [self.dashboardContainerView addSubview:dashboard];
            [dashboard mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.mas_equalTo(0);
            }];
        }
        
        if ([self.delegate respondsToSelector:@selector(nestedVCNeedReloadDashboard:)]) {
            [self.delegate nestedVCNeedReloadDashboard:self];
        }
    } else {
        for (UIView *subView in self.dashboardContainerView.subviews) {
            [subView removeFromSuperview];
        }
        [self updateDashboardHeight:0];
    }
}

- (void)reloadMenu {
    UIView *menu = nil;
    if ([self.dataSource respondsToSelector:@selector(menuView)]) {
        menu = [self.dataSource menuView];
    }
    
    if (menu) {
        if (![self.menuContainerView.subviews containsObject:menu]) {
            for (UIView *subView in self.menuContainerView.subviews) {
                [subView removeFromSuperview];
            }
            [self.menuContainerView addSubview:menu];
            [menu mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.mas_equalTo(0);
            }];
        }
        
        if ([self.delegate respondsToSelector:@selector(nestedVCNeedReloadMenu:)]) {
            [self.delegate nestedVCNeedReloadMenu:self];
        }
    } else {
        for (UIView *subView in self.menuContainerView.subviews) {
            [subView removeFromSuperview];
        }
        [self updateMenuHeight:0];
    }
}

- (void)reloadContentVC {
    // reload vc count
    [self.currentTableCell reloadContentVC];
    // scroll to current index
    [self scrollToIndex:self.currentMenuIndex animated:NO];
    // update content vc data source
    if ([self.dataSource respondsToSelector:@selector(updateContentVC:withIndex:)]) {
        [self.dataSource updateContentVC:self.currentContentVC withIndex:self.currentMenuIndex];
    }
    // reload current content vc
    [self.currentContentVC reloadData];
}

- (void)refreshContentVC {
    if ([self.currentContentVC respondsToSelector:@selector(refreshUI)]) {
        [self.currentContentVC refreshUI];
    }
}

- (void)scrollToIndex:(NSUInteger)index animated:(BOOL)animated {
    NSInteger totalContents = 0;
    if ([self.dataSource respondsToSelector:@selector(numberOfContentViewControllers)]) {
        totalContents = [self.dataSource numberOfContentViewControllers];
    }
    if (totalContents > 0 && totalContents > index) {
        [self.currentTableCell scrollToIndex:index animated:animated];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TYNestedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TYNestedTableViewCell class]) forIndexPath:indexPath];
    cell.dataSource = self.dataSource;
    cell.delegate = self.delegate;
    cell.parentVC = self;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.contentVCHeight;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return self.menuHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return self.menuContainerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.tableView) {
        [self handleTableViewScroll:scrollView];
    } else {
        [self handleContentCollectionViewScroll:scrollView];
    }
}

- (void)handleTableViewScroll:(UIScrollView *)scrollView {
    CGFloat offsetY = scrollView.contentOffset.y;
    CGFloat maxOffsetY = self.dashboardHeight;
    if (!self.canParentViewScroll) {
        self.tableView.contentOffset = CGPointMake(0, maxOffsetY);
        self.canChildViewScroll = YES;
    } else if (offsetY >= maxOffsetY) {
        // 只有在内容视图可以滚动的时候才将滚动传递到内容视图去，不然会导致父视图失去滚动能力
        CGFloat contentHeight = self.currentContentVC.contentScrollView.contentSize.height;
        CGFloat contentScrollHeight = self.currentContentVC.contentScrollView.bounds.size.height;
        BOOL canChildScroll = contentHeight > contentScrollHeight;
        if (canChildScroll) {
            // 将父视图定位到吸顶位置，保证子视图可视区域
            self.tableView.contentOffset = CGPointMake(0, maxOffsetY);

            self.canParentViewScroll = NO;
            self.canChildViewScroll = YES;
        }
    } else {
        // 点击状态栏时父视图会滚动到顶部，需要把子视图还原到初始位置
        self.currentContentVC.contentScrollView.contentOffset = CGPointZero;
    }
}

- (void)handleContentCollectionViewScroll:(UIScrollView *)scrollView {
    CGFloat offsetY = scrollView.contentOffset.y;
    if (!self.canChildViewScroll) {
        scrollView.contentOffset = CGPointZero;
    } else if (offsetY <= 0) {
        self.canParentViewScroll = YES;
        self.canChildViewScroll = NO;
    }
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView {
    self.canParentViewScroll = YES;
    self.canChildViewScroll = NO;
    return YES;
}

#pragma mark - Getter

- (UIView *)canvasView {
    if ([self.dataSource respondsToSelector:@selector(mainContentView)]) {
        return [self.dataSource mainContentView];;
    }
    return nil;
}

- (UIView *)dashboardContainerView {
    if (!_dashboardContainerView) {
        _dashboardContainerView = [UIView new];
    }
    return _dashboardContainerView;
}

- (UIView *)menuContainerView {
    if (!_menuContainerView) {
        _menuContainerView = [UIView new];
    }
    return _menuContainerView;
}

- (TYNestedTableView *)tableView {
    if (!_tableView) {
        _tableView = [[TYNestedTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.showsVerticalScrollIndicator = NO;
        [_tableView registerClass:[TYNestedTableViewCell class] forCellReuseIdentifier:NSStringFromClass([TYNestedTableViewCell class])];
        
//        if (@available(iOS 15.0, *)) {
//            _tableView.sectionHeaderTopPadding = 0;
//        }
        
        if (@available(iOS 11.0, *)) {
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
    }
    return _tableView;
}

- (CGFloat)dashboardHeight {
    return self.dashboardContainerView.bounds.size.height;
}

- (CGFloat)menuHeight {
    return self.menuContainerView.bounds.size.height;
}

- (CGFloat)contentVCHeight {
    CGFloat visibleHeight = self.canvasView.bounds.size.height;
    CGFloat height = visibleHeight - self.menuHeight;
    return height;
}

- (UIViewController<TYNestedSideScrollContentVC> *)currentContentVC {
    return self.tableView.currentContentVC;
}

- (TYNestedTableViewCell *)currentTableCell {
    return self.tableView.currentTableCell;
}

- (UIScrollView *)mainScrollView {
    return self.tableView;
}

- (UIScrollView *)sideScrollView {
    return self.currentTableCell.collectionView;
}

- (NSInteger)currentMenuIndex {
    return self.currentTableCell.currentContentCell.index;
}

@end
