# CYPlayer
```ruby
#podfile添加如下行
pod 'CYPlayer'
```
### Sample

<img src="https://raw.githubusercontent.com/yellowei/CYPlayer/master/TestVideo/shoot_1.png" />

<img src="https://raw.githubusercontent.com/yellowei/CYPlayer/master/TestVideo/shoot_2.png" />

<img src="https://raw.githubusercontent.com/yellowei/CYPlayer/master/TestVideo/shoot_3.png" />

### How To Use
```Objective-C
vc = [CYFFmpegPlayer movieViewWithContentPath:path parameters:parameters];
    [vc settingPlayer:^(CYVideoPlayerSettings *settings) {
        settings.definitionTypes = CYFFmpegPlayerDefinitionLLD | CYFFmpegPlayerDefinitionLHD | CYFFmpegPlayerDefinitionLSD | CYFFmpegPlayerDefinitionLUD;
        settings.enableSelections = YES;
        settings.setCurrentSelectionsIndex = ^NSInteger{
            return 3;//假设上次播放到了第四节
        };
        settings.nextAutoPlaySelectionsPath = ^NSString *{
            return @"http:/xtoai.com/9f76b359339f4bbc919f35e39e55eed4/efa9514952ef5e242a4dfa4ee98765fb-ld.mp4";
        };
        settings.useHWDecompressor = YES;
//        settings.enableProgressControl = NO;
    }];
    vc.delegate = self;
    vc.autoplay = YES;
    vc.generatPreviewImages = YES;
    [contentView addSubview:vc.view];
    
    [vc.view mas_makeConstraints:^(MASConstraintMaker *make) {
        if (kiPad)
        {
            make.center.offset(0);
            make.leading.trailing.offset(0);
            make.height.equalTo(vc.view.mas_width).multipliedBy(9.0 / 16.0);
        }
        else
        {
            make.center.offset(0);
            make.top.bottom.offset(0);
            make.width.equalTo(vc.view.mas_height).multipliedBy(16.0 / 9.0);
        }
    }];
    
    
     __weak __typeof(&*self)weakSelf = self;
    vc.lockscreen = ^(BOOL isLock) {
        if (isLock)
        {
            [weakSelf lockRotation];
        }
        else
        {
            [weakSelf unlockRotation];
        }
    };
```

##注意:

```tex
pod安装CYPlayer后,如果遇到xcode无法调试的问题，请到xocde工程Pod目录下CYPlayer找到"Support Files/CYPlayer.xcconfig"文件, 删除OTHER_LDFLAGS中的-read_only_relocs suppress, 尝试真机能否运行
```

