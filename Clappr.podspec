Pod::Spec.new do |s|
  s.name             = "Clappr"
  s.version          = "0.12.0"
  s.summary          = "An extensible media player for iOS and tvOS"
  s.homepage         = "http://clappr.io"
  s.license          = 'MIT'
  s.authors          = {
    "Diego Marcon" => "dm.marcon@gmail.com",
    "Thiago Pontes" => "thiagopnts@gmail.com",
    "Gustavo Barbosa" => "gustavocsb@gmail.com",
    "Bruno Torres" => "me@brunotorr.es",
    "Fernando Pinho" => "fpinho@gmail.com",
    "Uéliton Freitas" => "freitas.ueliton@gmail.com",
    "Augusto Boranga" => "guto.boranga@gmail.com",
    "Cristian Madrid" => "cristianmadridd@gmail.com",
  }

  s.source           = { :git => "https://github.com/clappr/clappr-ios.git", :tag => s.version.to_s }

  s.requires_arc = true
  s.ios.resources = 'Sources/Clappr_iOS/Resources/*.{xib,ttf,png,xcassets}'

  s.ios.deployment_target = "9.0"
  s.ios.source_files = ['Sources/Clappr/Classes/**/*', 'Sources/Clappr_iOS/Classes/**/*']
  s.ios.dependency 'Kingfisher', '~> 4.6.3'

  s.tvos.deployment_target = "10.0"
  s.tvos.source_files = ['Sources/Clappr/Classes/**/*', 'Sources/Clappr_tvOS/Classes/**/*']
end
