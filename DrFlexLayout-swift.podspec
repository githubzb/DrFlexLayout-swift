Pod::Spec.new do |spec|
  spec.name         = "DrFlexLayout-swift"
  spec.version      = "1.1.0"
  spec.summary      = "This is a layout framework based on yoga package."
  spec.description  = <<-DESC
                      This is a layout framework based on yoga package, it is easy to use flex layout, and implements some encapsulation of UITableView, UIScrollView. You can also customize the appearance of UIView, including: shadows, rounded corners, gradients, and borders.
                   DESC

  spec.homepage     = "https://github.com/githubzb/DrFlexLayout-swift"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author             = { "zhangbao" => "1126976340@qq.com" }
  spec.platform     = :ios, "10.0"
  spec.swift_version = "5.0"
# spec.source       = { :git => "https://github.com/githubzb/DrFlexLayout-swift.git", :tag => "#{spec.version}" }
  spec.source       = { :git => "https://github.com/githubzb/DrFlexLayout-swift.git", :commit => "3fe902f" }
  # spec.exclude_files = "Classes/Exclude"

  spec.frameworks = "UIKit", "CoreGraphics"
  spec.library   = "c++"

  spec.requires_arc = true
  spec.default_subspecs = 'Core'
  # spec.dependency "JSONKit", "~> 1.4"
  
  spec.subspec 'Core' do |ss|
      ss.ios.deployment_target = '10.0'
      ss.source_files  = "DrFlexLayout/src/core/**/*.{h,m,swift,cpp}"
      ss.public_header_files = "DrFlexLayout/src/core/yoga/{Yoga,YGEnums,YGMacros,YGValue}.h", "DrFlexLayout/src/core/oc/{UIView+Yoga,YGLayout+Private,YGLayout}.h", "DrFlexLayout/DrFlexLayout.h"
  end
  
  spec.subspec 'rx' do |ss|
      ss.ios.deployment_target = '10.0'
      ss.source_files  = "DrFlexLayout/src/rx/**/*.{swift}"
      ss.dependency "RxSwift", "~> 6.5.0"
      ss.dependency "RxCocoa", "~> 6.5.0"
      ss.dependency "#{spec.name}/Core", "#{spec.version}"
  end

end
