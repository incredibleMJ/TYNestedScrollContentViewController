# TYNestedScrollContentViewController

一个基于 UIKit 的三层嵌套滚动容器，适用于个人主页、店铺主页、资讯频道等场景：

- 顶部 Dashboard 随页面向上滚动；
- 菜单栏滚动至顶部后吸附；
- 内容区域支持左右分页切换，每个页面保留独立的纵向滚动内容。

项目使用 Objective-C 编写，示例工程最低支持 iOS 15.0，并依赖 [Masonry](https://github.com/SnapKit/Masonry)。

## Demo

<video src="./demo.mov" controls muted loop width="320"></video>

[直接打开 Demo 视频](./demo.mov)

## 效果结构

```text
TYNestedSideScrollViewController
└── UITableView（外层纵向滚动）
    ├── tableHeaderView：Dashboard / 顶部头图
    └── section header：Menu / 吸顶菜单
        └── UITableViewCell：内容可视区域
            └── UICollectionView（横向分页）
                └── ContentViewController
                    └── UIScrollView / UITableView / UICollectionView（子页纵向滚动）
```

## 实现原理

### 1. 外层表格负责头图与吸顶菜单

容器内部使用一个 `UITableView`：

- `tableHeaderView` 放置 `dashboardView`；
- section header 放置 `menuView`，由 `UITableView` 原生行为实现吸顶；
- 唯一的 cell 作为内容页的可视区域，其高度等于容器高度减去菜单高度。

因此，头图向上滚出屏幕时，菜单会自然停留在顶部。

### 2. 横向 Collection View 管理内容页

内容 cell 内部使用开启 `pagingEnabled` 的横向 `UICollectionView`。数据源按索引创建实现 `TYNestedSideScrollContentVC` 协议的子控制器，容器可通过：

```objc
[self scrollToIndex:index animated:YES];
```

切换页面。菜单点击事件由业务方处理，随后调用上面的 API 即可同步内容页。

### 3. 父子滚动通过两个状态交接

组件用 `canParentViewScroll` 和 `canChildViewScroll` 控制滚动归属：

1. 初始时仅外层表格可以滚动，头图和菜单一起向上移动；
2. 外层滚到 Dashboard 高度时，菜单已经吸顶；
3. 若当前子页内容可继续向上滚动，外层表格固定在吸顶位置，滚动权限交给子页；
4. 子页回滚到顶部后，权限再交还外层表格，继续下拉即可显示头图。

子控制器暴露的 `contentScrollView` 会被容器监听 `contentOffset`，从而完成这次交接。横向切页时，离开页面的滚动位置会复位到顶部。

## 快速开始

示例工程位于 `TT` 目录。运行前执行：

```bash
cd TT
pod install
open TT.xcworkspace
```

将以下文件加入你的工程，并确保已集成 Masonry：

```text
TYNestedSideScrollViewController/
├── TYNestedSideScrollViewController.h/.m
├── TYNestedTableView.h/.m
├── TYNestedTableViewCell.h/.m
└── TYNestedCollectionViewCell.h/.m
```

## 使用方法

### 1. 创建容器控制器

让页面控制器继承 `TYNestedSideScrollViewController`，并在调用 `[super viewDidLoad]` **之前**设置 `dataSource` 和 `delegate`。

```objc
#import "TYNestedSideScrollViewController.h"

@interface ProfileViewController : TYNestedSideScrollViewController
@end

@implementation ProfileViewController

- (void)viewDidLoad {
    self.dataSource = self;
    self.delegate = self;
    [super viewDidLoad];
}

@end
```

在 Storyboard 或代码中准备一个占满安全区域的 `contentView`，并通过 `mainContentView` 返回它。容器会把外层滚动视图添加到这个视图中。

### 2. 提供头图、菜单和子页面

实现 `TYNestedSideScrollDataSource`：

```objc
- (UIView *)mainContentView {
    return self.contentView;
}

- (UIView *)dashboardView {
    return self.dashboardView;
}

- (UIView *)menuView {
    return self.menuView;
}

- (NSUInteger)numberOfContentViewControllers {
    return self.titles.count;
}

- (UIViewController<TYNestedSideScrollContentVC> *)contentViewControllerForIndex:(NSUInteger)index {
    ArticleListViewController *vc = [ArticleListViewController new];
    return vc;
}

- (void)updateContentVC:(UIViewController<TYNestedSideScrollContentVC> *)contentVC
              withIndex:(NSUInteger)index {
    ArticleListViewController *vc = (ArticleListViewController *)contentVC;
    [vc updateWithCategory:self.titles[index]];
}
```

`contentViewControllerForIndex:` 用于创建页面；`updateContentVC:withIndex:` 用于在页面复用或数据刷新时按索引更新页面数据。

### 3. 设置头图和菜单高度

当容器请求刷新头图或菜单时，设置对应视图的高度并通知容器：

```objc
- (void)nestedVCNeedReloadDashboard:(TYNestedSideScrollViewController *)vc {
    self.dashboardView.frame = CGRectMake(0, 0, 0, 220);
    [self updateDashboardHeight:CGRectGetHeight(self.dashboardView.frame)];
}

- (void)nestedVCNeedReloadMenu:(TYNestedSideScrollViewController *)vc {
    self.menuView.frame = CGRectMake(0, 0, 0, 44);
    [self updateMenuHeight:CGRectGetHeight(self.menuView.frame)];
}
```

不需要头图或菜单时，分别返回 `nil`。组件会自动移除对应区域。

### 4. 实现子页面协议

每个内容页必须实现 `TYNestedSideScrollContentVC`，并返回实际承载纵向滚动的 `UIScrollView`。它可以是 `UITableView`、`UICollectionView` 或普通 `UIScrollView`。

```objc
@interface ArticleListViewController ()
@property (nonatomic, strong) UITableView *tableView;
@end

@implementation ArticleListViewController

- (UIScrollView *)contentScrollView {
    return self.tableView;
}

- (void)reloadData {
    [self.tableView reloadData];
}

- (void)refreshUI {
    [self.tableView reloadData];
}

@end
```

`reloadData` 是必需方法；如只需刷新页面展示、不重新组装数据源，可选实现 `refreshUI`。

### 5. 响应菜单切换

在菜单的点击回调中调用：

```objc
[self scrollToIndex:index animated:YES];
```

当前展示的索引可通过只读属性 `currentMenuIndex` 获取。子页面即将显示时，可以在代理中同步菜单选中态：

```objc
- (void)willDisplayContentVC:(UIViewController<TYNestedSideScrollContentVC> *)contentVC {
    // 根据 self.currentMenuIndex 更新菜单 UI
}
```

## 刷新接口

| 方法 | 用途 |
| --- | --- |
| `reloadData` | 刷新头图、菜单、子页面数量和当前子页面 |
| `reloadDashboard` | 仅刷新头图 |
| `reloadMenu` | 仅刷新菜单 |
| `reloadContentVC` | 重新组装子页面数据源并刷新当前页 |
| `refreshContentVC` | 仅触发当前页的 `refreshUI` |
| `scrollToIndex:animated:` | 切换到指定内容页 |

容器还暴露 `mainScrollView`，可用于接入下拉刷新等外层滚动操作；`sideScrollView` 可用于监听或控制横向分页。

## 使用注意

- `dataSource` 和 `delegate` 必须在 `[super viewDidLoad]` 前赋值，否则容器无法创建内部视图。
- `mainContentView` 必须返回已完成布局的容器视图，否则内容区域高度无法正确计算。
- `dashboardView` 与 `menuView` 的高度由调用方提供；高度变化后请调用 `updateDashboardHeight:` 或 `updateMenuHeight:`。
- 子页返回的 `contentScrollView` 必须是实际参与纵向滚动的视图，且应有正确的 `contentSize`。
- 若子页内容高度不足一屏，外层会保留滚动能力，不会强制把滚动交给子页。

## License

MJNestedScrollContentViewController is available under the MIT license. See the [LICENSE](LICENSE) file for more info.
