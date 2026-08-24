//
//  TYNestedTableView.h
//  TT
//
//  Created by JiaNa on 2021/10/14.
//

#import <UIKit/UIKit.h>
#import "TYNestedTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface TYNestedTableView : UITableView

/// 当前显示的内容子VC
@property (nonatomic, weak, readonly) UIViewController<TYNestedSideScrollContentVC> *currentContentVC;
@property (nonatomic, weak, readonly) TYNestedTableViewCell *currentTableCell;

@end

NS_ASSUME_NONNULL_END
