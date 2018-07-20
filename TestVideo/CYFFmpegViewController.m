//
//  CYFFmpegViewController.m
//  CYPlayer
//
//  Created by 黄威 on 2018/7/19.
//  Copyright © 2018年 Sutan. All rights reserved.
//

#import "CYFFmpegViewController.h"
#import "CYFFmpegPlayer.h"
#import <Masonry.h>

@interface CYFFmpegViewController ()
{
    NSArray *_localMovies;
    NSArray *_remoteMovies;
    CYFFmpegPlayer *vc;
}

@end

@implementation CYFFmpegViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    _remoteMovies = @[
                      
                      //            @"http://eric.cast.ro/stream2.flv",
                      //            @"http://liveipad.wasu.cn/cctv2_ipad/z.m3u8",
                      @"http://www.wowza.com/_h264/BigBuckBunny_175k.mov",
                      // @"http://www.wowza.com/_h264/BigBuckBunny_115k.mov",
                      @"rtsp://184.72.239.149/vod/mp4:BigBuckBunny_115k.mov",
                      @"http://santai.tv/vod/test/test_format_1.3gp",
                      @"http://santai.tv/vod/test/test_format_1.mp4",
                      @"rtsp://wowzaec2demo.streamlock.net/vod/mp4:BigBuckBunny_115k.mov",
                      @"http://static.tripbe.com/videofiles/20121214/9533522808.f4v.mp4",
                      //@"rtsp://184.72.239.149/vod/mp4://BigBuckBunny_175k.mov",
                      //@"http://santai.tv/vod/test/BigBuckBunny_175k.mov",
                      
                      //            @"rtmp://aragontvlivefs.fplive.net/aragontvlive-live/stream_normal_abt",
                      //            @"rtmp://ucaster.eu:1935/live/_definst_/discoverylacajatv",
                      //            @"rtmp://edge01.fms.dutchview.nl/botr/bunny.flv"
                      ];
    
    NSString *path;
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    path = @"http://static.tripbe.com/videofiles/20121214/9533522808.f4v.mp4";
    
    // increase buffering for .wmv, it solves problem with delaying audio frames
    if ([path.pathExtension isEqualToString:@"wmv"])
        parameters[CYMovieParameterMinBufferedDuration] = @(5.0);
    
    // disable deinterlacing for iPhone, because it's complex operation can cause stuttering
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        parameters[CYMovieParameterDisableDeinterlacing] = @(YES);
    
    vc = [CYFFmpegPlayer movieViewWithContentPath:path parameters:parameters];
    vc.autoplay = YES;
    [self.view addSubview:vc.view];
    
    [vc.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@375);
        make.height.equalTo(@250);
        make.center.equalTo(@0);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [vc viewWillDisappear];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
