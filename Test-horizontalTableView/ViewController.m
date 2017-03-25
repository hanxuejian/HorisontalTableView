//
//  ViewController.m
//  Test-horizontalTableView
//
//  Created by han on 2017/3/22.
//  Copyright © 2017年 han. All rights reserved.
//

#import "ViewController.h"
#import "HorizontalTableView.h"

@interface ViewController ()<HorizontalTableViewDataSource>

@property (nonatomic, strong) HorizontalTableView *horizontalTableView;

@property (nonatomic, strong) NSArray *array;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.array = @[@"1",@"2",@"3",@"4"];
    self.horizontalTableView = [[HorizontalTableView alloc]initWithFrame:CGRectMake(20, 50, 300, 50)];
    self.horizontalTableView.backgroundColor = [UIColor grayColor];
    self.horizontalTableView.layer.borderWidth = 2;
    self.horizontalTableView.delegate = self;
    self.horizontalTableView.width = 100;
    [self.view addSubview:self.horizontalTableView];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (IBAction)btnClicked:(id)sender {
    NSArray *array = self.horizontalTableView.subviews.firstObject.subviews.firstObject.subviews;
    NSLog(@"%@",array);
}

#pragma mark - HorizontalTableViewDataSource
- (NSInteger)numberOfColumnsInTableView:(HorizontalTableView *)tableView {
    return self.array.count;
}

- (HorizontalTableViewCell *)tableView:(HorizontalTableView *)tableView cellForColumnAtIndex:(NSInteger)index {
    static NSString *identifier = @"horizontalTableViewCell";
    HorizontalTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[HorizontalTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.textLabel.text = self.array[index];
    return cell;
}

- (CGFloat)tableView:(HorizontalTableView *)tableView widthForColumnAtIndex:(NSInteger)index {
    return 100 * ++index;
}

@end
