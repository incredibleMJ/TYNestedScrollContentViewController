//
//  ViewController.m
//  TT
//
//  Created by JiaNa on 2021/10/15.
//

#import "ViewController.h"
#import "ContentViewController.h"

@interface ViewController () <TYNestedSideScrollDataSource, TYNestedSideScrollDelegate>

@property (nonatomic, weak) IBOutlet UIView *contentView;
@property (nonatomic, strong) UIView *dashView;
@property (nonatomic, strong) UIView *menu;

@end

@implementation ViewController

- (void)viewDidLoad {
    self.dataSource = self;
    self.delegate = self;
    [super viewDidLoad];
}

#pragma mark - TYNestedSideScrollDataSource

- (UIView *)mainContentView {
    return self.contentView;
}

- (UIView *)dashboardView {
    return self.dashView;
}

- (UIView *)menuView {
    return self.menu;
}

- (NSUInteger)numberOfContentViewControllers {
    return 6;
}

- (UIViewController<TYNestedSideScrollContentVC> *)contentViewControllerForIndex:(NSUInteger)index {
    UIViewController<TYNestedSideScrollContentVC> *contentVC = [ContentViewController new];
    return contentVC;
}

- (void)updateContentVC:(UIViewController<TYNestedSideScrollContentVC> *)contentVC withIndex:(NSUInteger)inedx {
    
}

#pragma mark - TYNestedSideScrollDelegate

- (void)nestedVCNeedReloadDashboard:(TYNestedSideScrollViewController *)vc {
    self.dashView.frame = CGRectMake(0, 0, 0, 220);
    [self updateDashboardHeight:CGRectGetHeight(self.dashView.frame)];
}

- (void)nestedVCNeedReloadMenu:(TYNestedSideScrollViewController *)vc {
    self.menu.frame = CGRectMake(0, 0, 0, 44);
    [self updateMenuHeight:CGRectGetHeight(self.menu.frame)];
}

- (void)willDisplayContentVC:(UIViewController<TYNestedSideScrollContentVC> *)contentVC {
    
}

#pragma mark - Getter

- (UIView *)dashView {
    if (!_dashView) {
        _dashView = [UIView new];
        _dashView.backgroundColor = [UIColor grayColor];
    }
    return _dashView;
}

- (UIView *)menu {
    if (!_menu) {
        _menu = [UIView new];
        _menu.backgroundColor = [UIColor cyanColor];
    }
    return _menu;
}

@end
