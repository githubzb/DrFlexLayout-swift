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
  spec.source       = { :git => "https://github.com/githubzb/DrFlexLayout-swift.git", :tag => "#{spec.version}" }
  spec.source_files  = "DrFlexLayout/**/*.{h,m,swift,cpp}"
  # spec.exclude_files = "Classes/Exclude"
  # spec.public_header_files = "Classes/**/*.h"

  # spec.framework  = "SomeFramework"
  # spec.frameworks = "SomeFramework", "AnotherFramework"

  # spec.library   = "iconv"
  # spec.libraries = "iconv", "xml2"

  spec.requires_arc = true
  
  # spec.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
  # spec.dependency "JSONKit", "~> 1.4"

end
