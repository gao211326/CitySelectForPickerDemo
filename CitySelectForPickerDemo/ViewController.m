//
//  ViewController.m
//  CitySelectForPickerDemo
//
//  Created by 高磊 on 2017/2/9.
//  Copyright © 2017年 高磊. All rights reserved.
//

#import "ViewController.h"
#import "ShowPickerView.h"

@interface ViewController ()<ShowPickerViewDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(100, 100, 80, 40)];
    [button setTitle:@"选择地区" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    button.backgroundColor = [UIColor grayColor];
    [button addTarget:self action:@selector(chooseArea:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}


#pragma mark == event response
- (void)chooseArea:(UIButton *)sender
{
    ShowPickerView *areaPickerView = [[ShowPickerView alloc] initWithFrame:self.view.bounds];
    areaPickerView.delegate = (id)self;
    [areaPickerView showPicker];
}


#pragma mark == ShowPickerViewDelegate
- (void)showPickerViewDone:(NSString *)chooseTitle chooseId:(NSString *)chooseId
{
        NSLog(@" 打印信息:%@ -- %@",chooseTitle,chooseId);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
