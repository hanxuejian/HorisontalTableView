## UITableView 的横向滑动实现

1. ### 概述
	为了实现横向滑动的控件，可以继承类 UIScrollView 或类 UIView 自定义可以横向滑动的控件，这里通过 UITableView 的旋转，实现可以横向滑动的控件。
	
2. ### 概念
	先说明与实现相关的几个概念
	* 坐标系
	
		```
		在 iOS 中，每个视图都有一个坐标系，用来确定其子视图的位置，这个坐标系在视图初始化后
		确定，在这个长方形的视图中，左上角为坐标系原点，水平向右为 x 坐标轴正方向，垂直向下
		为 y 坐标轴正方向，当视图发生旋转时，其坐标系同时旋转（或者说旋转的就是坐标系），但
		这并不会影响父视图的坐标系，但旋转视图的 frame 属性会发生改变，如果旋转后的视图的坐
		标系仍然与父坐标系平行，那么，frame 表示的仍然是这个视图，如果不平行，那么，frame 
		表示的是该旋转视图的外接正方形。
		```
		
	* frame
		
		```
		对于这个 UIView 的属性 frame ，包含四个值（x,y,width,height），（x,y）这个
		点坐标代表的是视图在其父视图坐标系中的某一点，而 width 则是沿着 x 坐标轴的长度，
		height 则是沿着 y 坐标轴的长度，由此得来的矩形即是 frame 表示的视图，这里的坐
		标轴指的都是父坐标系。
		```
	* transform
		
		```
		这个属性实际是提供了一个3*3的矩阵，当修改这个属性时，视图上的点会组成一个1*3的矩
		阵[x,y,1],这个矩阵与 transform 表示的矩阵相乘，计算出新的点。在实际使用过程中
		可以直接使用 CGAffineTransform.h 中提供的函数得到一个 CGAffineTransform 
		变量，然后赋值即可。
		本次就会用到函数 
			CGAffineTransformMakeRotation(CGFloat angle) 
				参数：angle ，弧度值，可以直接使用系统定义的宏 M_PI 等
				该值为正值时，表示坐标系逆时针方向旋转，为负值时，表示坐标系顺时针方向
				旋转（这是在 iOS 中的旋转方向，在 Mac X 中相反，并且这里指的是坐标轴
				的自我旋转方向，而人眼看到的方向是相反的，即正值，你看到的视图是在顺时
				针旋转）
		```
	* 锚点

		```
		视图旋转总是相对于某一点旋转，这个点就是锚点，该点默认是视图的中心点，也可以通过
		UIView 的 layer 的 anchorPoint 属性改变，
		```

3. ### 原理
	自定义一个 UIView 的子类 HorizontalTableView ，在其中添加一个 UITableView 类对象，初始化时，将表格视图逆时针方向旋转90度，此时，其坐标系的 x 坐标轴正方向垂直向上， y 坐标轴正方向水平向右，表格中的子视图的坐标系与其一致，而后，在该自定义的子类中实现 UITableView 的代理方法。
	
	自定义一个类 HorizontalTableViewCell 继承 UITableViewCell ，在初始化该子类时，将属性 contentView 顺时针方向旋转90度，此时其坐标系方向与 HorizontalTableView 的父视图的坐标系一致（一般与屏幕一致）。
	
	自定义一个协议 HorizontalTableViewDataSource 用于获取用户提供的 cell 个数及宽度等信息。

4. ### 代码
	[完整测试代码](https://github.com/hanxuejian/HorizontalTableView.git "github")
	* HorizontalTableView.h
	
	```
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
	```
	* HorizontalTableView.m
	
	```
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
	```