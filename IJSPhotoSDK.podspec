
Pod::Spec.new do |s|

 
  s.name         = "IJSPhotoSDK"
  s.version      = "0.1.3"

  s.summary      = "IJSPhotoSDK from PhotoKit."
  s.license          = 'MIT'
  s.author           = { "wangjinshan" => "1096452045@qq.com" }
  s.homepage         = 'http://www.mob.com'
  s.platform         = :ios
  s.ios.deployment_target = "8.0"
  s.requires_arc = true
  s.description  = 'IJSPhotoSDK from PhotoKit ,you can select more image'
                
  s.source       = { :git => "https://github.com/wangjinshan/IJSPhotoSDK.git", :tag => "#{s.version}" ,:submodules => true}


  s.frameworks       = 'UIKit','Photos'
  
  # 依赖的资源 
  s.resource = "SDK/Resources/JSPhotoSDK.bundle"

  s.dependency 'IJSFoundation'
  s.dependency  'IJSUExtension'

  s.source_files = 'SDK/IJSPhotoSDK/ConstantFile/*.{h,m}',
                    'SDK/IJSPhotoSDK/Controllers/*.{h,m}',
                    'SDK/IJSPhotoSDK/IJSMapView/*.{h,m}',
                    'SDK/IJSPhotoSDK/IJSVideoDrawTool/*.{h,m}',
                    'SDK/IJSPhotoSDK/Model/*.{h,m}',
                    'SDK/IJSPhotoSDK/TOCropViewController/*.{h,m}',
                    'SDK/IJSPhotoSDK/View/*.{h,m}'
  
  
end


