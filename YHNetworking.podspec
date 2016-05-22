
Pod::Spec.new do |s|

  s.name         = "YHNetworking"
  s.version      = "0.0.2"
  s.summary      = "YHNetworking is a network request tool based on AFNetworking."
  s.homepage     = "https://github.com/yehot/YHNetworking"
  s.license      = "MIT"
  s.author             = {"yehot" => "yehot2013@gmail.com"}
  s.source       = { :git => "https://github.com/yehot/YHNetworking.git", :tag => s.version.to_s }
  s.source_files  = "YHNetwork/*.{h,m}"
  s.platform     = :ios, "7.0"
  s.requires_arc = true
  s.dependency "AFNetworking", "~> 2.0"
  s.dependency "AFDownloadRequestOperation", "~> 2.0"


end
