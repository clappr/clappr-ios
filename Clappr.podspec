Pod::Spec.new do |s|
  s.name             = "Clappr"
  s.version          = "0.1.2"
  s.summary          = "An extensible media player for iOS"
  s.homepage         = "http://clappr.io"
  s.license          = 'MIT'
  s.author           = { "Diego Marcon" => "diego.marcon@corp.globo.com" }
  s.source           = { :git => "https://github.com/clappr/clappr-ios.git", :branch => 'migration-to-swift', :tag => s.version.to_s }

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resources = 'Pod/Resources/*.{xib,ttf,png}'
end
