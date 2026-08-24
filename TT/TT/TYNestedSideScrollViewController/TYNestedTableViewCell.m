//
//  TYNestedTableViewCell.m
//  TT
//
//  Created by MJ2009 on 2021/10/12.
//

#import "TYNestedTableViewCell.h"
#import <Masonry/Masonry.h>

@interface TYNestedTableViewCell ()
<UICollectionViewDataSource,
UICollectionViewDelegate,
UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *collectionLayout;

@end

@implementation TYNestedTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self initViews];
    }
    return self;
}

- (void)initViews {
    [self.contentView addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
}

- (void)reloadContentVC {
    [self.collectionView reloadData];
}

- (void)scrollToIndex:(NSUInteger)index animated:(BOOL)animated {
    NSInteger totalContents = [self.collectionView numberOfItemsInSection:0];
    if (totalContents > 0 && totalContents > index) {
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]
                                    atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:animated];
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if ([self.dataSource respondsToSelector:@selector(numberOfContentViewControllers)]) {
        return [self.dataSource numberOfContentViewControllers];
    }
    return 0;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"========cellForItemAtIndexPath %ld", indexPath.item);
    TYNestedCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([TYNestedCollectionViewCell class]) forIndexPath:indexPath];
    cell.parentVC = self.parentVC;
    cell.index = indexPath.item;
    // 这里的重用机制后续还可以优化
    if (!cell.contentVC) {
        if ([self.dataSource respondsToSelector:@selector(contentViewControllerForIndex:)]) {
            UIViewController<TYNestedSideScrollContentVC> *contentVC = [self.dataSource contentViewControllerForIndex:indexPath.item];
            [cell bindContentVC:contentVC];
        }
    } else {
        if ([self.dataSource respondsToSelector:@selector(updateContentVC:withIndex:)]) {
            [self.dataSource updateContentVC:cell.contentVC withIndex:indexPath.item];
        }
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(willDisplayContentVC:)]) {
        TYNestedCollectionViewCell *showCell = (TYNestedCollectionViewCell *)cell;
        [self.delegate willDisplayContentVC:showCell.contentVC];
    }
    NSLog(@"========willDisplayCell %ld", indexPath.item);
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    TYNestedCollectionViewCell *showCell = (TYNestedCollectionViewCell *)cell;
    [showCell.contentVC.contentScrollView setContentOffset:CGPointZero animated:YES];
}

#pragma mark - UICollectionViewDelegate

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return collectionView.bounds.size;
}

#pragma mark - Getter

- (UICollectionViewFlowLayout *)collectionLayout {
    if (!_collectionLayout) {
        _collectionLayout = [UICollectionViewFlowLayout new];
        _collectionLayout.sectionInset = UIEdgeInsetsZero;
        _collectionLayout.minimumLineSpacing = 0;
        _collectionLayout.minimumInteritemSpacing = 0;
        _collectionLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    }
    return _collectionLayout;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.collectionLayout];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.pagingEnabled = YES;
        [_collectionView registerClass:[TYNestedCollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([TYNestedCollectionViewCell class])];
    }
    return _collectionView;
}

- (TYNestedCollectionViewCell *)currentContentCell {
    return [self.collectionView visibleCells].firstObject;;
}

- (UIViewController<TYNestedSideScrollContentVC> *)currentContentVC {
    return self.currentContentCell.contentVC;
}

@end
