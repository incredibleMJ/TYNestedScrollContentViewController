//
//  TYNestedSideScrollViewController.h
//  TT
//
//  Created by JiaNa on 2020/12/11.
//

#import <UIKit/UIKit.h>

@class TYNestedSideScrollViewController;

#pragma mark - Child View Controller

/// 子页面接口协议
@protocol TYNestedSideScrollContentVC <NSObject>

/// 滚动的内容视图
- (UIScrollView *)contentScrollView;

/// 刷新子页面
- (void)reloadData;

@optional
/// 只刷新页面，不执行数据源组装逻辑
- (void)refreshUI;

@end

/// 子页面数据源
@protocol TYNestedSideScrollContentVCDataSource <NSObject>

/// 子页面个数
- (NSUInteger)numberOfContentViewControllers;

/// 根据 index 返回子页面
/// @param index 页面索引， 0 开始
- (UIViewController<TYNestedSideScrollContentVC> *)contentViewControllerForIndex:(NSUInteger)index;

/// 更新某个 index 的子页面
/// @param contentVC 子页面
/// @param index 索引
- (void)updateContentVC:(UIViewController<TYNestedSideScrollContentVC> *)contentVC withIndex:(NSUInteger)index;

@end

/// 子页面事件代理
@protocol TYNestedSideScrollContentVCDelegate <NSObject>

@optional
- (void)willDisplayContentVC:(UIViewController<TYNestedSideScrollContentVC> *)contentVC;

@end

#pragma mark - Parent View Container

/// 父页面数据源
@protocol TYNestedSideScrollDataSource <TYNestedSideScrollContentVCDataSource>

/// 内容试图（滑动可视区域）
- (UIView *)mainContentView;

/// 头部视图
- (UIView *)dashboardView;

/// 悬浮菜单栏
- (UIView *)menuView;

@end

/// 父页面事件代理
@protocol TYNestedSideScrollDelegate <TYNestedSideScrollContentVCDelegate>

/// 父页面刷新头部视图代理
/// @param vc 容器视图
- (void)nestedVCNeedReloadDashboard:(TYNestedSideScrollViewController *)vc;

/// 父页面刷新菜单栏代理
/// @param vc 容器视图
- (void)nestedVCNeedReloadMenu:(TYNestedSideScrollViewController *)vc;

@end

/// 容器控制器
@interface TYNestedSideScrollViewController : UIViewController

/// dataSource、delegate 需要在子类调用 [super viewDidLoad] 之前赋值
@property (nonatomic, weak) id<TYNestedSideScrollDataSource> dataSource;

/// delegate、dataSource 需要在子类调用 [super viewDidLoad] 之前赋值
@property (nonatomic, weak) id<TYNestedSideScrollDelegate> delegate;

/// 当前菜单栏选中索引
@property (nonatomic, assign, readonly) NSInteger currentMenuIndex;

/// 主滚动视图，用于添加下拉刷新头等操作
@property (nonatomic, weak, readonly) UIScrollView *mainScrollView;

/// 侧滑滚动视图
@property (nonatomic, weak, readonly) UIScrollView *sideScrollView;

/// 更新头部视图高度
/// @param height 高度
- (void)updateDashboardHeight:(CGFloat)height;

/// 更新菜单栏高度
/// @param height 高度
- (void)updateMenuHeight:(CGFloat)height;

/// 全页面刷新，包含头部、菜单栏、子页面个数及当前子页面
- (void)reloadData;

/// 刷新头部视图
- (void)reloadDashboard;

/// 刷新菜单栏
- (void)reloadMenu;

/// 刷新子页面,包含数据源重新组装
- (void)reloadContentVC;

/// 刷新子页面 UI, 只是触发页面刷新，不涉及数据源重新组装
- (void)refreshContentVC;

/// 滚动到指定页面
/// @param index 索引
/// @param animated 是否动画滚动
- (void)scrollToIndex:(NSUInteger)index animated:(BOOL)animated;

@end

