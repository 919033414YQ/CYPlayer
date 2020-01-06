//
//  CYVideoPlayerSelectTableView.h
//  CYPlayer
//
//  Created by yellowei on 2020/1/6.
//  Copyright © 2020 Sutan. All rights reserved.
//

#import "CYVideoPlayerBaseView.h"

NS_ASSUME_NONNULL_BEGIN

typedef NSInteger(^NumberOfSectionsInTableView)(UITableView * __nonnull tableView);
typedef NSInteger(^NumberOfRowsInSection)(UITableView * __nonnull tableView, NSInteger section);
typedef UITableViewCell *(^CellForRowAtIndexPath)(UITableView * __nonnull tableView, NSIndexPath * __nonnull indexPath);
typedef CGFloat(^HeightForRowAtIndexPath)(UITableView * __nonnull tableView, NSIndexPath * __nonnull indexPath);
typedef CGFloat(^HeightForHeaderInSection)(UITableView * __nonnull tableView, NSInteger section);
typedef CGFloat(^HeightForFooterInSection)(UITableView * __nonnull tableView, NSInteger section);




@interface CYVideoPlayerSelectTableView : CYVideoPlayerBaseView

@property (nonatomic, strong, readonly) UITableView * selectTableView;

//tableView DataSource
@property (nonatomic, copy) NumberOfSectionsInTableView numberOfSectionsInTableView;
@property (nonatomic, copy) NumberOfRowsInSection numberOfRowsInSection;
@property (nonatomic, copy) CellForRowAtIndexPath cellForRowAtIndexPath;
@property (nonatomic, copy) HeightForRowAtIndexPath heightForRowAtIndexPath;
@property (nonatomic, copy) HeightForHeaderInSection heightForHeaderInSection;
@property (nonatomic, copy) HeightForFooterInSection heightForFooterInSection;

@end

NS_ASSUME_NONNULL_END
