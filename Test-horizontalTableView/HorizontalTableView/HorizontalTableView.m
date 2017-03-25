//
//  HorizontalTableView.m
//  Test-horizontalTableView
//
//  Created by han on 2017/3/22.
//  Copyright © 2017年 han. All rights reserved.
//

#import "HorizontalTableView.h"

@interface HorizontalTableView ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation HorizontalTableView

#pragma mark - initial methods
- (instancetype)init {
    self = [super init];
    if (self) {
        self = [self initWithFrame:CGRectMake(0, 0, 320, 50)];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.tableView.transform = CGAffineTransformMakeRotation(- M_PI_2);
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.tableView.frame = self.bounds;
        self.tableView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.tableView];
        
        self.width = 50;
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    self.tableView.frame = self.bounds;
}

#pragma mark - accessor methods
- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc]init];
    }
    return _tableView;
}

#pragma mark - inside methods

#pragma mark - interface methods
- (id)dequeueReusableCellWithIdentifier:(NSString *)identifier {
    id cell = [self.tableView dequeueReusableCellWithIdentifier:identifier];
    return cell;
}

- (void)selectColumnAtIndex:(NSInteger)index animated:(BOOL)animated scrollPosition:(UITableViewScrollPosition)scrollPosition {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [self.tableView selectRowAtIndexPath:indexPath animated:animated scrollPosition:scrollPosition];
}

- (void)reloadData {
    [self.tableView reloadData];
}

- (HorizontalTableViewCell *)cellForColumn:(NSInteger)index {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    HorizontalTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    return cell;
}

#pragma mark - UITableViewDelegate,UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger columns = 0;
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(numberOfColumnsInTableView:)]) {
        columns = [self.delegate numberOfColumnsInTableView:self];
    }
    return columns;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HorizontalTableViewCell *cell = nil;
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(tableView:cellForColumnAtIndex:)]) {
        cell = [self.delegate tableView:self cellForColumnAtIndex:indexPath.row];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat cellHeight = self.width;
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(tableView:widthForColumnAtIndex:)]) {
        cellHeight = [self.delegate tableView:self widthForColumnAtIndex:indexPath.row];
    }
    return cellHeight;
}

@end


@implementation HorizontalTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.contentView.transform = CGAffineTransformMakeRotation(M_PI_2);
        self.contentView.backgroundColor = [UIColor clearColor];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    /*
     对于UITableViewCell的contentView中的一些默认的视图不会随着frame的改变而自动改变，
     所以需要进行位置的调整，这里只对textLabel的位置进行了调整，其他若使用，也许调整，
     但是不建议使用。
     */
    for (UIView *subView in [self.contentView subviews]) {
        if ([subView class] == NSClassFromString(@"UITableViewLabel")) {
            subView.frame = CGRectMake(0, 0, self.bounds.size.height, self.bounds.size.width);
            subView.backgroundColor = [UIColor clearColor];
        }
    }
}

@end
