# CYPlayer
```ruby
pod 'CYPlayer'
```
### Sample

<img src="https://github.com/yellowei/CYPlayer/blob/master/TestVideo/shoot_1.png" />

<img src="https://github.com/yellowei/CYPlayer/blob/master/TestVideo/shoot_2.png" />

<img src="https://github.com/yellowei/CYPlayer/blob/master/TestVideo/shoot_3.png" />

### Use
```Objective-C
 Player.asset = [[CYVideoPlayerAssetCarrier alloc] initWithAssetURL:[NSURL URLWithString:@"http://....."] beginTime:10];
```

##注意:

pod安装后, 请到CYPlayer找到"Support Files/CYPlayer.xcconfig"文件, 删除OTHER_LDFLAGS中的-read_only_relocs suppress, 方可真机运行