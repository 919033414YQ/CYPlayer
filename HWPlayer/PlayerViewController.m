//
//  PlayerViewController.m
//  CYVideoPlayerProject
//
//  Created by BlueDancer on 2017/11/29.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "PlayerViewController.h"
#import "CYVideoPlayer.h"
#import <Masonry.h>


#define Player  [CYVideoPlayer sharedPlayer]

@interface PlayerViewController ()

@end

@implementation PlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blueColor];
    
    [self.view addSubview:Player.view];
    [Player.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.offset(0);
        make.leading.trailing.offset(0);
        make.height.equalTo(Player.view.mas_width).multipliedBy(9.0f / 16);
    }];
    
    Player.placeholder = [UIImage imageNamed:@"test"];
//    http://video.cdn.lanwuzhe.com/1493370091000dfb1
//    http://vod.lanwuzhe.com/d09d3a5f9ba4491fa771cd63294ad349%2F0831eae12c51428fa7aed3825c511370-5287d2089db37e62345123a1be272f8b.mp4
//    Player.asset = [[CYVideoPlayerAssetCarrier alloc] initWithAssetURL:[[NSBundle mainBundle] URLForResource:@"sample.mp4" withExtension:nil] beginTime:10];
    
    Player.asset = [[CYVideoPlayerAssetCarrier alloc] initWithAssetURL:[NSURL URLWithString:@"http://vod.lanwuzhe.com/d09d3a5f9ba4491fa771cd63294ad349%2F0831eae12c51428fa7aed3825c511370-5287d2089db37e62345123a1be272f8b.mp4"] beginTime:10];
    __weak typeof(self) _self = self;
    Player.clickedBackEvent = ^(CYVideoPlayer * _Nonnull player) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [Player stop];
        [self.navigationController popViewControllerAnimated:YES];
    };
    
    [self _setPlayerMoreSettingItems];
    
    // Do any additional setup after loading the view.
}

- (void)_setPlayerMoreSettingItems {
    
    CYVideoPlayerMoreSettingSecondary *QQ = [[CYVideoPlayerMoreSettingSecondary alloc] initWithTitle:@"" image:[UIImage imageNamed:@"qq"] clickedExeBlock:^(CYVideoPlayerMoreSetting * _Nonnull model) {
        [Player showTitle:@"分享到QQ"];
    }];
    
    CYVideoPlayerMoreSettingSecondary *wechat = [[CYVideoPlayerMoreSettingSecondary alloc] initWithTitle:@"" image:[UIImage imageNamed:@"wechat"] clickedExeBlock:^(CYVideoPlayerMoreSetting * _Nonnull model) {
        [Player showTitle:@"分享到wechat"];
    }];
    
    CYVideoPlayerMoreSettingSecondary *weibo = [[CYVideoPlayerMoreSettingSecondary alloc] initWithTitle:@"" image:[UIImage imageNamed:@"weibo"] clickedExeBlock:^(CYVideoPlayerMoreSetting * _Nonnull model) {
        [Player showTitle:@"分享到weibo"];
    }];
    
    CYVideoPlayerMoreSetting *share = [[CYVideoPlayerMoreSetting alloc] initWithTitle:@"share" image:[UIImage imageNamed:@"share"] showTowSetting:YES twoSettingTopTitle:@"分享到" twoSettingItems:@[QQ, wechat, weibo] clickedExeBlock:^(CYVideoPlayerMoreSetting * _Nonnull model) {
        [Player showTitle:@"clicked Share"];
    }];
    
    CYVideoPlayerMoreSetting *download = [[CYVideoPlayerMoreSetting alloc] initWithTitle:@"下载" image:[UIImage imageNamed:@"download"] clickedExeBlock:^(CYVideoPlayerMoreSetting * _Nonnull model) {
        [Player showTitle:@"clicked download"];
    }];
    
    CYVideoPlayerMoreSetting *collection = [[CYVideoPlayerMoreSetting alloc] initWithTitle:@"收藏" image:[UIImage imageNamed:@"collection"] clickedExeBlock:^(CYVideoPlayerMoreSetting * _Nonnull model) {
        [Player showTitle:@"clicked collection"];
    }];
    
    CYVideoPlayerMoreSetting.titleFontSize = 10;
    
    Player.moreSettings = @[share, download, collection];
}

- (void)dealloc {
    [Player stop];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}

@end
