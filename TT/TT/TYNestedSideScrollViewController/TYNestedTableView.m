//
//  TYNestedTableView.m
//  TT
//
//  Created by JiaNa on 2021/10/14.
//

#import "TYNestedTableView.h"

@interface TYNestedTableView () <UIGestureRecognizerDelegate>

/// 竖向滚动的内容视图
@property (nonatomic, weak) UIScrollView *verticalScrollView;

@end

@implementation TYNestedTableView

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    // 只同时响应竖向滚动视图
    return [[self.verticalScrollView gestureRecognizers] containsObject:otherGestureRecognizer];
}

- (UIScrollView *)verticalScrollView {
    return self.currentContentVC.contentScrollView;
}

- (UIViewController<TYNestedSideScrollContentVC> *)currentContentVC {
    UIViewController<TYNestedSideScrollContentVC> *currentContentVC = self.currentTableCell.currentContentVC;
    return currentContentVC;
}

- (TYNestedTableViewCell *)currentTableCell {
    return [[self visibleCells] firstObject];
}

@end
