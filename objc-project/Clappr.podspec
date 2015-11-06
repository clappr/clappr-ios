Pod::Spec.new do |s|
  s.name             = "Clappr"
  s.version          = "0.1.0"
  s.summary          = "An extensible media player for iOS"
  s.homepage         = "http://clappr.io"
  s.license          = 'MIT'
  s.authors          = {
    "Thiago Pontes" => "thiagopnts@gmail.com",
    "Gustavo Barbosa" => "gustavocsb@gmail.com"
  }
  s.source           = { :git => "https://github.com/clappr/clappr-ios.git", :tag => s.version.to_s }

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*.{m,h}'
  s.resources = 'Pod/Resources/**/*.{xib,png,ttf}'

  s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit', 'AVFoundation'
end
