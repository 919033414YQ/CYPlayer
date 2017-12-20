//
//  ViewController.m
//  CYPlayer
//
//  Created by 黄威 on 2017/12/20.
//  Copyright © 2017年 黄威. All rights reserved.
//

#import "ViewController.h"
#import "PlayerViewController.h"
#import <Masonry.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn addTarget:self action:@selector(onTouch:) forControlEvents:UIControlEventTouchUpInside];
    btn.backgroundColor = [UIColor blackColor];
    [btn setTitle:@"播放" forState:UIControlStateNormal];
    [self.view addSubview:btn];
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@(100));
        make.center.equalTo(@(0));
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onTouch:(UIButton *)sender
{
    [self presentViewController:[[PlayerViewController alloc] init] animated:YES completion:nil];
}



@end
