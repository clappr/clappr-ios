Pod::Spec.new do |s|
  s.name             = "Clappr"
  s.version          = "0.3.13"
  s.summary          = "An extensible media player for iOS"
  s.homepage         = "http://clappr.io"
  s.license          = 'MIT'
  s.authors          = {
    "Diego Marcon" => "dm.marcon@gmail.com",
    "Thiago Pontes" => "thiagopnts@gmail.com",
    "Gustavo Barbosa" => "gustavocsb@gmail.com",
    "Bruno Torres" => "me@brunotorr.es",
    "Fernando Pinho" => "fpinho@gmail.com"
  }

  s.source           = { :git => "https://github.com/clappr/clappr-ios.git", :tag => s.version.to_s }
  s.requires_arc = true
  s.source_files = 'Pod/Classes/**/*'
  s.dependency 'Kingfisher', '~> 2.4'

  s.ios.deployment_target = "8.0"
  s.tvos.deployment_target = '9.0'

  s.ios.resources = 'Pod/Resources/*.{xib,ttf,png,xcassets}'
  s.tvos.resources = 'Pod/Resources/*.{ttf,png,xcassets}'
end
