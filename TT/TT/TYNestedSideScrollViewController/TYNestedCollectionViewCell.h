//
//  TYNestedCollectionViewCell.h
//  TT
//
//  Created by JiaNa on 2021/9/28.
//

#import <UIKit/UIKit.h>
#import "TYNestedSideScrollViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface TYNestedCollectionViewCell : UICollectionViewCell

@property (nonatomic, weak) TYNestedSideScrollViewController *parentVC;
@property (nonatomic, strong, readonly) UIViewController<TYNestedSideScrollContentVC> *contentVC;
@property (nonatomic, assign) NSInteger index;

- (void)bindContentVC:(UIViewController<TYNestedSideScrollContentVC> *)contentVC;

@end

NS_ASSUME_NONNULL_END
