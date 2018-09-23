#pod lib lint --verbose --allow-warnings --use-libraries
Pod::Spec.new do |s|

s.name         = "CYPlayer"
s.version      = "1.6.0"
s.summary      = 'A iOS video player, using AVPlayer&FFmpeg. Libraries: CYSMBClient, CYfdkAAC, CYx264, CYFFmpeg'
s.description  = 'A iOS video player, using AVFoundation&FFmpeg. Libraries: CYSMBClient, CYfdkAAC, CYx264, CYFFmpeg. https://github.com/yellowei/CYPlayer'
s.homepage     = 'https://github.com/yellowei/CYPlayer'
s.license      = { :type => "MIT", :file => "LICENSE" }
s.author             = { "yellowei" => "hw0521@vip.qq.com" }
s.platform     = :ios, "8.0"
s.source       = { :git => 'https://github.com/yellowei/CYPlayer.git', :tag => "#{s.version}" }
s.resources = ['CYPlayer/CYVideoPlayer/Resource/CYVideoPlayer.bundle', 'CYPlayer/CYVideoPlayer/Player/FFMpegDecoder/cyplayer.bundle']
s.frameworks  = "UIKit", "Foundation"
s.requires_arc = true

#s.dependency 'Masonry'
# s.pod_target_xcconfig = { 'FRAMEWORK_SEARCH_PATHS' => '"$(PODS_ROOT)/CYPlayer/CYFrameworks"', 'ENABLE_BITCODE' => 'YES', 'OTHER_LDFLAGS' => '$(inherited) -read_only_relocs suppress '}
# s.pod_target_xcconfig = { 'OTHER_LDFLAGS' => '$(inherited) -read_only_relocs suppress '}

s.user_target_xcconfig = { 'FRAMEWORK_SEARCH_PATHS' => '"${PODS_ROOT}/CYPlayer"', 'HEADER_SEARCH_PATHS' => '"${PODS_ROOT}/CYPlayer"' }
s.pod_target_xcconfig = { 'FRAMEWORK_SEARCH_PATHS' => '"${PODS_ROOT}/CYPlayer"', 'HEADER_SEARCH_PATHS' => '"${PODS_ROOT}/CYPlayer"' }

# s.subspec 'CYTest' do |ss|
# ss.source_files = 'CYPlayer/CYTest/*.{h}'
# ss.dependency 'CYPlayer/CYSMBClient'
# ss.dependency 'CYPlayer/CYfdkAAC'
# ss.dependency 'CYPlayer/CYx264'
# end

s.subspec 'CYSMBClient' do |ss|
ss.source_files = 'CYPlayer/CYFrameworks/Smbclient/*.{h}'
ss.vendored_libraries = "CYPlayer/CYFrameworks/Smbclient/*.a"
ss.public_header_files = 'CYPlayer/CYFrameworks/Smbclient/*.{h}'
ss.libraries = 'resolv', 'z', 'iconv', 'bz2'
end

s.subspec 'CYfdkAAC' do |ss|
ss.source_files = 'CYPlayer/CYFrameworks/fdk-aac-ios/include/fdk-aac/*.{h}'
ss.vendored_libraries = 'CYPlayer/CYFrameworks/fdk-aac-ios/lib/*.a'
ss.public_header_files = 'CYPlayer/CYFrameworks/fdk-aac-ios/include/fdk-aac/*.{h}'
ss.libraries = 'resolv', 'z', 'iconv', 'bz2'
end

s.subspec 'CYx264' do |ss|
ss.source_files = 'CYPlayer/CYFrameworks/x264-iOS/include/*.{h}'
ss.vendored_libraries = 'CYPlayer/CYFrameworks/x264-iOS/lib/*.a'
ss.public_header_files = 'CYPlayer/CYFrameworks/x264-iOS/include/*.{h}'
ss.libraries = 'resolv', 'z', 'iconv', 'bz2'
end

s.subspec 'CYFFmpeg' do |ss|
ss.source_files = 'CYPlayer/CYFrameworks/FFmpeg-iOS/include/**/*.{h}','CYPlayer/CYFrameworks/FFmpeg-iOS/ffmpeg.h'
ss.vendored_libraries = 'CYPlayer/CYFrameworks/FFmpeg-iOS/lib/*.a'
ss.public_header_files = 'CYPlayer/CYFrameworks/FFmpeg-iOS/include/**/*.{h}','CYPlayer/CYFrameworks/FFmpeg-iOS/ffmpeg.h'
ss.dependency 'CYPlayer/CYSMBClient'
ss.dependency 'CYPlayer/CYfdkAAC'
ss.dependency 'CYPlayer/CYx264'
ss.libraries = 'resolv', 'z', 'iconv', 'bz2'
ss.frameworks  = "VideoToolbox", "CoreMedia","AudioToolbox"
ss.pod_target_xcconfig = { 'HEADER_SEARCH_PATHS' => '"${PODS_ROOT}/CYPlayer/CYFrameworks/FFmpeg-iOS/include"' }
end


# s.subspec 'CYTest' do |ss|
# ss.source_files = 'CYPlayer/CYTest/*.{h,m}'
# ss.dependency 'CYPlayer/CYSMBClient'
# ss.vendored_frameworks = "CYPlayer/CYFrameworks/FFmpeg.framework"
# end

s.subspec 'CYAttributesFactory' do |ss|
ss.source_files = 'CYPlayer/CYAttributesFactory/*.{h,m}'
end

s.subspec 'CYLoadingView' do |ss|
ss.source_files = 'CYPlayer/CYLoadingView/*.{h,m}'
end

s.subspec 'CYBorderLineView' do |ss|
ss.source_files = 'CYPlayer/CYBorderLineView/*.{h,m}'
end

s.subspec 'CYObserverHelper' do |ss|
ss.source_files = 'CYPlayer/CYObserverHelper/*.{h,m}'
end

s.subspec 'CYOrentationObserver' do |ss|
ss.source_files = 'CYPlayer/CYOrentationObserver/*.{h,m}'

ss.subspec 'UseNativeOrentation' do |sss|
sss.source_files = 'CYPlayer/CYOrentationObserver/UseNativeOrentation/*.{h,m}'
end

#如果不想用系统自动横屏, 请解开这个注释,并且切换代码的setFullScreen方法
#ss.subspec 'UnuseNativeOrentation' do |sss|
#sss.source_files = 'CYPlayer/CYOrentationObserver/UnuseNativeOrentation/*.{h,m}'
#end

end


s.subspec 'CYPrompt' do |ss|
ss.source_files = 'CYPlayer/CYPrompt/*.{h,m}'
end

s.subspec 'CYSlider' do |ss|
ss.source_files = 'CYPlayer/CYSlider/*.{h,m}'
end

s.subspec 'CYUIFactory' do |ss|
ss.dependency 'CYPlayer/CYAttributesFactory'
ss.source_files = 'CYPlayer/CYUIFactory/*.{h,m}'
ss.subspec 'Category' do |sss|
sss.source_files = 'CYPlayer/CYUIFactory/Category/*.{h,m}'
end

end

s.subspec 'CYVideoPlayerBackGR' do |ss|
ss.source_files = 'CYPlayer/CYVideoPlayerBackGR/*.{h,m}'
ss.dependency 'CYPlayer/CYObserverHelper'
end

s.subspec 'CYVideoPlayer' do |ss|

ss.source_files = 'CYPlayer/CYVideoPlayer/*.{h}'

ss.dependency 'CYPlayer/CYUIFactory/Category'
ss.dependency 'CYPlayer/CYUIFactory'
ss.dependency 'CYPlayer/CYPrompt'
ss.dependency 'CYPlayer/CYAttributesFactory'
ss.dependency 'CYPlayer/CYOrentationObserver'
ss.dependency 'CYPlayer/CYSlider'
ss.dependency 'CYPlayer/CYBorderLineView'
ss.dependency 'CYPlayer/CYObserverHelper'
# ss.dependency 'CYPlayer/CYVideoPlayerBackGR'
ss.dependency 'CYPlayer/CYLoadingView'

# ########
ss.subspec 'Header' do |sss|
sss.source_files = 'CYPlayer/CYVideoPlayer/Header/*.{h}'
end

ss.subspec 'Model' do |sss|
sss.source_files = 'CYPlayer/CYVideoPlayer/Model/*.{h,m}'
sss.dependency 'CYPlayer/CYVideoPlayer/Header'
# sss.vendored_frameworks = "CYPlayer/CYFrameworks/FFmpeg.framework"
sss.dependency 'CYPlayer/CYFFmpeg'
# sss.pod_target_xcconfig = { 'HEADER_SEARCH_PATHS' => '"$(PODS_ROOT)/CYPlayer/CYFrameworks/FFmpeg-iOS/include"' }
end

ss.subspec 'Resource' do |sss|
sss.source_files = 'CYPlayer/CYVideoPlayer/Resource/*.{h,m}'
end

ss.subspec 'Base' do |sss|
sss.source_files = 'CYPlayer/CYVideoPlayer/Base/*.{h,m}'
#sss.dependency 'CYPlayer/CYVideoPlayer/Header'
sss.dependency 'CYPlayer/CYVideoPlayer/Model'
sss.dependency 'CYPlayer/CYVideoPlayer/Resource'
# sss.dependency 'CYPlayer/CYUIFactory'
# # sss.dependency 'CYPlayer/CYUIFactory/Category'
# sss.dependency 'CYPlayer/CYPrompt'
# sss.dependency 'CYPlayer/CYSlider'
# sss.dependency 'CYPlayer/CYOrentationObserver'
# sss.dependency 'CYPlayer/CYAttributesFactory'
# sss.dependency 'CYPlayer/CYBorderLineView'
end

ss.subspec 'Other' do |sss|
sss.source_files = 'CYPlayer/CYVideoPlayer/Other/*.{h,m}'
sss.dependency 'CYPlayer/CYVideoPlayer/Base'
end

ss.subspec 'Player' do |sss|
sss.source_files = 'CYPlayer/CYVideoPlayer/Player/*.{h,m}'
sss.dependency 'CYPlayer/CYVideoPlayer/Control'
sss.dependency 'CYPlayer/CYVideoPlayer/MoreSetting'
sss.dependency 'CYPlayer/CYVideoPlayer/VolBrigControl'
sss.dependency 'CYPlayer/CYVideoPlayer/Present'
sss.dependency 'CYPlayer/CYVideoPlayer/Registrar'
sss.dependency 'CYPlayer/CYVideoPlayer/TimerControl'
sss.dependency 'CYPlayer/CYVideoPlayer/GestureControl'
# sss.dependency 'CYPlayer/CYUIFactory/Category'
# sss.dependency 'CYPlayer/CYUIFactory'
# sss.dependency 'CYPlayer/CYPrompt'
# sss.dependency 'CYPlayer/CYSlider'
# sss.dependency 'CYPlayer/CYAttributesFactory'
# sss.dependency 'CYPlayer/CYOrentationObserver'

end



ss.subspec 'Control' do |sss|
sss.source_files = 'CYPlayer/CYVideoPlayer/Control/*.{h,m}'
sss.dependency 'CYPlayer/CYVideoPlayer/Other'
# sss.dependency 'CYPlayer/CYUIFactory/Category'
# sss.dependency 'CYPlayer/CYUIFactory'
# sss.dependency 'CYPlayer/CYSlider'
# sss.dependency 'CYPlayer/CYAttributesFactory'
end

ss.subspec 'GestureControl' do |sss|
sss.source_files = 'CYPlayer/CYVideoPlayer/GestureControl/*.{h,m}'
end

ss.subspec 'MoreSetting' do |sss|

sss.dependency 'CYPlayer/CYVideoPlayer/Other'
# sss.dependency 'CYPlayer/CYSlider'

sss.subspec 'MoreSetting' do |ssss|
ssss.source_files = 'CYPlayer/CYVideoPlayer/MoreSetting/MoreSetting/*.{h,m}'
end

sss.subspec 'Secondary' do |ssss|
ssss.source_files = 'CYPlayer/CYVideoPlayer/MoreSetting/Secondary/*.{h,m}'
end

end

ss.subspec 'VolBrigControl' do |sss|
sss.source_files = 'CYPlayer/CYVideoPlayer/VolBrigControl/*.{h,m}'
sss.dependency 'CYPlayer/CYVideoPlayer/Other'
# sss.dependency 'CYPlayer/CYSlider'
# sss.dependency 'CYPlayer/CYBorderLineView'
end



ss.subspec 'Present' do |sss|
sss.source_files = 'CYPlayer/CYVideoPlayer/Present/*.{h,m}'
sss.dependency 'CYPlayer/CYVideoPlayer/Other'
end

ss.subspec 'Registrar' do |sss|
sss.source_files = 'CYPlayer/CYVideoPlayer/Registrar/*.{h,m}'
end

ss.subspec 'TimerControl' do |sss|
sss.source_files = 'CYPlayer/CYVideoPlayer/TimerControl/*.{h,m}'
end


# ########

end

end
