Pod::Spec.new do |s|
  s.name             = "Clappr"
  s.version          = "0.7.3"
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
  s.resources = 'Clappr/Resources/*.{xib,ttf,png,xcassets}'
  
  s.ios.deployment_target = "9.0"
  s.ios.source_files = 'Clappr/Classes/**/*'
  s.ios.dependency 'Kingfisher', '~> 3.0'

  s.tvos.deployment_target = "10.0"
  s.tvos.source_files = ['Clappr_tvOS/Classes/**/*', 'Clappr/Classes/**/*']
  s.tvos.exclude_files = [
                          "Clappr/Classes/Base/Player.swift",
                          "Clappr/Classes/Base/Playback.swift",
                          "Clappr/Classes/Base/MediaControl.swift",
                          "Clappr/Classes/Base/Options.swift",
                          "Clappr/Classes/Base/EventHandler.swift",
                          "Clappr/Classes/Base/Core.swift",
                          "Clappr/Classes/Base/BaseObject.swift",
                          "Clappr/Classes/Base/UIBaseObject.swift",
                          "Clappr/Classes/Base/FullscreenController.swift",
                          "Clappr/Classes/Base/FullScreenStateHandler.swift",
                          "Clappr/Classes/Plugin/Playback/AVFoundationPlayback.swift",
                          "Clappr/Classes/Plugin/Playback/NoOpPlayback.swift",
                          "Clappr/Classes/Plugin/Container/LoadingContainerPlugin.swift",
                          "Clappr/Classes/Plugin/Container/PosterPlugin.swift",
                          "Clappr/Classes/Protocol/EventProtocol.swift",
                          "Clappr/Classes/Extension/AVURLAssetWithCookiesBuilder.swift",
                          "Clappr/Classes/Helper/AppStateManager.swift",
                          "Classes/Plugin/Core/UICorePlugin.swift",
                          "Clappr/Resources/MediaControlView.xib"
                          ]
end