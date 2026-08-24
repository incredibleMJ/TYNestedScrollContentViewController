//
//  TYNestedTableViewCell.h
//  TT
//
//  Created by MJ2009 on 2021/10/12.
//

#import <UIKit/UIKit.h>
#import "TYNestedCollectionViewCell.h"
#import "TYNestedSideScrollViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface TYNestedTableViewCell : UITableViewCell

@property (nonatomic, weak) id<TYNestedSideScrollContentVCDataSource> dataSource;
@property (nonatomic, weak) id<TYNestedSideScrollContentVCDelegate> delegate;

@property (nonatomic, weak) TYNestedSideScrollViewController *parentVC;
@property (nonatomic, strong, readonly) UICollectionView *collectionView;
@property (nonatomic, weak, readonly) TYNestedCollectionViewCell *currentContentCell;
@property (nonatomic, weak, readonly) UIViewController<TYNestedSideScrollContentVC> *currentContentVC;

- (void)reloadContentVC;
- (void)scrollToIndex:(NSUInteger)index animated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
