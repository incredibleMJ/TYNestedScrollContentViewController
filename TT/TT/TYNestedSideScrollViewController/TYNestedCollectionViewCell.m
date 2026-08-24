//
//  TYNestedCollectionViewCell.m
//  TT
//
//  Created by JiaNa on 2021/9/28.
//

#import "TYNestedCollectionViewCell.h"
#import <Masonry/Masonry.h>

@interface TYNestedCollectionViewCell ()

@property (nonatomic, strong) UIViewController<TYNestedSideScrollContentVC> *contentVC;

@end

@implementation TYNestedCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
    }
    return self;
}

- (void)bindContentVC:(UIViewController<TYNestedSideScrollContentVC> *)contentVC {
    NSString *currentContentClassName = NSStringFromClass([self.contentVC class]);
    NSString *newContentClassName = NSStringFromClass([contentVC class]);
    // 类名不一致才重新绑定，减少不必要的图层操作
    if (![currentContentClassName isEqualToString:newContentClassName]) {
        [self.contentVC.contentScrollView removeObserver:self forKeyPath:@"contentOffset" context:nil];
        [self.contentVC.view removeFromSuperview];
        
        [contentVC.contentScrollView addObserver:self
                                      forKeyPath:@"contentOffset"
                                         options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
                                         context:nil];
        self.contentVC = contentVC;
        [self.contentView addSubview:contentVC.view];
        [contentVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(0);
        }];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([object isKindOfClass:[UIScrollView class]] && [keyPath isEqualToString:@"contentOffset"]) {
        CGPoint oldOffset = [change[NSKeyValueChangeOldKey] CGPointValue];
        CGPoint newOffset = [change[NSKeyValueChangeNewKey] CGPointValue];
        if (oldOffset.y == newOffset.y) {
            return;
        }
        if ([self.parentVC respondsToSelector:@selector(scrollViewDidScroll:)]) {
            [self.parentVC performSelector:@selector(scrollViewDidScroll:) withObject:object];
        }
    }
}

@end
