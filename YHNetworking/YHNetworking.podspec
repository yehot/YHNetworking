
Pod::Spec.new do |s|
  s.name         = "YHNetworking"
  s.version      = "0.1.0"
  s.summary      = "YHNetworking is a network request tool based on AFNetworking."
  s.description  = <<-DESC
                    YHNetworking is a network request tool based on AFNetworking，it's modify
                    from YTKNetwork （https://github.com/yuantiku/YTKNetwork）
                   DESC

  s.homepage     = "https://github.com/yehot/YHNetworking"
  s.license      = "MIT"
  s.author             = { "yehot" => "yehot2013@gmail.com" }
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/yehot/YHNetworking.git", :tag => "0.0.1" }

  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #

  s.source_files  = "YHNetworking", "YHNetworking/YHNetworking/*.{h,m}"
  #s.exclude_files = "Classes/Exclude"

  # ――― Resources ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  # s.resource  = "icon.png"
  # s.resources = "Resources/*.png"
  # s.preserve_paths = "FilesToSave", "MoreFilesToSave"

  # ――― Project Linking ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.frameworks = "Foundation", "UIKit"

  # s.library   = "iconv"
  # s.libraries = "iconv", "xml2"


  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  If your library depends on compiler flags you can set them in the xcconfig hash
  #  where they will only apply to your library. If you depend on other Podspecs
  #  you can include multiple dependencies to ensure it works.

  s.requires_arc = true

  # s.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
  s.dependency "AFNetworking", "~> 2.6.3"
  s.dependency "AFDownloadRequestOperation", "~> 2.0.1"


end
