#
#  Be sure to run `pod spec lint IJSPhotoSDK.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  These will help people to find your library, and whilst it
  #  can feel like a chore to fill in it's definitely to your advantage. The
  #  summary should be tweet-length, and the description more in depth.
  #

  s.name         = "IJSPhotoSDK"
  s.version      = "0.0.1"

  s.summary      = "IJSPhotoSDK from PhotoKit."
  s.license          = 'MIT'
  s.author           = { "wangjinshan" => "1096452045@qq.com" }
  s.homepage         = 'http://www.mob.com'
  s.platform         = :ios
  s.ios.deployment_target = "8.0"
  s.requires_arc = true
  s.description  = 'IJSPhotoSDK from PhotoKit ,you can select more image'
                

  s.source       = { :git => "https://github.com/wangjinshan/IJSPhotoSDK.git", :tag => "#{s.version}" ,:submodules => true}

  s.source_files = 'SDK/IJSPhotoSDK/IJSPhotoSDKFiles/**/*'
  s.resource_bundles = {
    'JSPhotoSDK' => ['SDK/IJSPhotoSDK/Support/JSPhotoSDK.bundle']
  }

    # IJSPhotoSDKFiles 核心文件
    # s.subspec 'IJSPhotoSDK' do |sp|
    #   sp.source_files = 'SDK/IJSPhotoSDK/IJSPhotoSDKFiles/*.*'
    #   # sp.resource_bundles = 'JSPhotoSDK' => ['SDK/IJSPhotoSDK/Support/JSPhotoSDK.bundle']
    # end


   # 依赖的公共库
    s.subspec 'IJSFoundation' do |sp|
        sp.vendored_frameworks = 'SDK/Required/IJSFoundation.framework'
    end

   # IJSPhoto扩展模块
    s.subspec 'IJSPhotoSDKExtension' do |sp|
      sp.source_files = 'SDK/Required/IJSUExtension/*.*'

    end
 
  

end