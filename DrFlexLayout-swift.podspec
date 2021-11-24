Pod::Spec.new do |spec|
  spec.name         = "DrFlexLayout-swift"
  spec.version      = "1.0.0"
  spec.summary      = "This is a layout framework based on yoga package."
  spec.description  = <<-DESC
                      This is a layout framework based on yoga package, it is easy to use flex layout, and implements some encapsulation of UITableView, UIScrollView. You can also customize the appearance of UIView, including: shadows, rounded corners, gradients, and borders.
                   DESC

  spec.homepage     = "https://github.com/githubzb/DrFlexLayout-swift"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author             = { "zhangbao" => "1126976340@qq.com" }
  spec.platform     = :ios, "10.0"
  spec.swift_version = "5.0"
  spec.source       = { :git => "https://github.com/githubzb/DrFlexLayout-swift.git", :tag => "#{spec.version}" }
  spec.source_files  = "DrFlexLayout/**/*.{h,m,swift,cpp}"
  spec.public_header_files = "DrFlexLayout/src/yoga/{Yoga,YGEnums,YGMacros,YGValue}.h", "DrFlexLayout/src/oc/{UIView+Yoga,YGLayout+Private,YGLayout}.h", "DrFlexLayout/DrFlexLayout.h"
  # spec.exclude_files = "Classes/Exclude"

  spec.frameworks = "UIKit", "CoreGraphics"
  spec.library   = "c++"

  spec.requires_arc = true
  # Should match yoga_defs.bzl + BUCK configuration
#  spec.compiler_flags = [
#        '-fno-omit-frame-pointer',
#        '-fexceptions',
#        '-Wall',
#        '-Werror',
#        '-std=c++1y',
#        '-fPIC'
#    ]
  # spec.dependency "JSONKit", "~> 1.4"

end
