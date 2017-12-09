
Pod::Spec.new do |s|

 
  s.name         = "IJSPhotoSDK"
  s.version      = "1.0.0"

  s.summary      = "基于PhotoKit实现多图选择"
  s.license= { :type => "MIT", :file => "LICENSE" }
  s.author           = { "wangjinshan" => "1096452045@qq.com" }
  s.homepage         = 'https://github.com/wangjinshan/IJSPhotoSDK'
  s.platform         = :ios
  s.ios.deployment_target = "8.0"
  s.requires_arc = true
  s.description  = 'IJSPhotoSDK from PhotoKit ,you can select more image'
                
  s.source       = { :git => "https://github.com/wangjinshan/IJSPhotoSDK.git", :tag => "#{s.version}" ,:submodules => true}


  s.frameworks       = 'UIKit','Photos'
  
  # 依赖的公共库, Core 的所有文件都将依赖这两个库
  s.dependency 'IJSFoundation'
  s.dependency 'IJSUExtension'

  # 依赖的资源 
  s.resource = "SDK/Resources/JSPhotoSDK.bundle"
  

  # IJSPhotoSDK 文件层级结构 Core是SDK的核心库文件
    
  s.subspec 'IJSVideoDrawTool' do |sp|
    sp.source_files = 'SDK/IJSPhotoSDK/IJSVideoDrawTool/*.{h,m}'
  
    end
    
  s.subspec 'IJSMapView' do |sp|
      sp.source_files = 'SDK/IJSPhotoSDK/IJSMapView/*.{h,m}' 

    end

  s.subspec 'TOCropViewController' do |sp|
      sp.source_files = 'SDK/IJSPhotoSDK/TOCropViewController/*.{h,m}' 
    
    end
    
  # IJSPhoto 核心代码库    

  s.subspec 'Core' do |sp|

      sp.source_files = 'SDK/IJSPhotoSDK/ConstantFile/*.{h,m}','SDK/IJSPhotoSDK/Controllers/*.{h,m}','SDK/IJSPhotoSDK/Model/*.{h,m}','SDK/IJSPhotoSDK/View/*.{h,m}' 

      sp.dependency 'IJSPhotoSDK/IJSVideoDrawTool'
      sp.dependency 'IJSPhotoSDK/TOCropViewController'
      sp.dependency 'IJSPhotoSDK/IJSMapView'
    end 

end






























