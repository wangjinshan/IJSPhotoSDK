
Pod::Spec.new do |s|

 
  s.name         = "IJSPhotoSDK"
  s.version      = "0.1.0"

  s.summary      = "IJSPhotoSDK from PhotoKit."
  s.license          = 'MIT'
  s.author           = { "wangjinshan" => "1096452045@qq.com" }
  s.homepage         = 'http://www.mob.com'
  s.platform         = :ios
  s.ios.deployment_target = "8.0"
  s.requires_arc = true
  s.description  = 'IJSPhotoSDK from PhotoKit ,you can select more image'
                
  s.source       = { :git => "https://github.com/wangjinshan/IJSPhotoSDK.git", :tag => "#{s.version}" ,:submodules => true}

  s.dependency 'IJSFoundation'
  s.dependency 'IJSUExtension'
  
  s.resource = "SDK/IJSPhotoSDK/Support/JSPhotoSDK.bundle"
  # ShareSDK提供的UI
  s.subspec 'IJSPhotoSDKFiles' do |sp|
    sp.source_files = 'SDK/IJSPhotoSDK/IJSPhotoSDKFiles/*.{h,m}'
  end
    

end
