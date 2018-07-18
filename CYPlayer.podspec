
Pod::Spec.new do |s|

s.name         = "CYPlayer"
s.version      = "1.3.2"
s.summary      = 'A video player.'
s.description  = 'https://github.com/yellowei/CYPlayer'
s.homepage     = 'https://github.com/yellowei/CYPlayer'
s.license      = { :type => "MIT", :file => "FILE_LICENSE" }
s.author             = { "yellowei" => "hw0521@vip.qq.com" }
s.platform     = :ios, "8.0"
s.source       = { :git => 'https://github.com/yellowei/CYPlayer.git', :tag => "#{s.version}" }
s.resource     = 'CYPlayer/CYVideoPlayer/Resource/CYVideoPlayer.bundle'
s.frameworks  = "UIKit", "AVFoundation"
#s.vendored_frameworks = "CYPlayer/CYVideoPlayer/framework/*.framework"
#s.libraries = 'libbz2.1.0', 'libc++.1', 'libz.1.1.3'
s.requires_arc = true
s.dependency 'Masonry'


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
end

ss.subspec 'Resource' do |sss|
sss.source_files = 'CYPlayer/CYVideoPlayer/Resource/*.{h,m}'
end

ss.subspec 'Base' do |sss|
sss.source_files = 'CYPlayer/CYVideoPlayer/Base/*.{h,m}'
sss.dependency 'CYPlayer/CYVideoPlayer/Header'
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
