//
//  HorizontalTableView.h
//  Test-horizontalTableView
//
//  Created by han on 2017/3/22.
//  Copyright © 2017年 han. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HorizontalTableViewCell;

@protocol HorizontalTableViewDataSource;

@interface HorizontalTableView : UIView

@property (nonatomic, weak) id <HorizontalTableViewDataSource> delegate;

/** 
 the default width of columns,value is 50.0
 
 if the delegate don't implement the method tableView:widthForColumnAtIndex:
 the value is used as the width of columns,you can change the default value.
 */
@property (nonatomic, assign) CGFloat width;

- (id)dequeueReusableCellWithIdentifier:(NSString *)identifier;

- (void)selectColumnAtIndex:(NSInteger)index animated:(BOOL)animated scrollPosition:(UITableViewScrollPosition)scrollPosition;

- (void)reloadData;

- (HorizontalTableViewCell *)cellForColumn:(NSInteger)column;

@end

@protocol HorizontalTableViewDataSource <NSObject>

@required

- (NSInteger)numberOfColumnsInTableView:(HorizontalTableView *)tableView;

- (HorizontalTableViewCell *)tableView:(HorizontalTableView *)tableView cellForColumnAtIndex:(NSInteger)index;

@optional

- (CGFloat)tableView:(HorizontalTableView *)tableView widthForColumnAtIndex:(NSInteger)index;

- (void)tableView:(HorizontalTableView *)tableView didSelectColumn:(NSInteger)index;

@end

@interface HorizontalTableViewCell : UITableViewCell

@end
