Pod::Spec.new do |s|
  s.name             = "Clappr"
  s.version          = "0.9.0"
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
  s.resources = 'Sources/Clappr/Resources/*.{xib,ttf,png,xcassets}'

  s.ios.deployment_target = "9.0"
  s.ios.source_files = 'Sources/Clappr/Classes/**/*'
  s.ios.dependency 'Kingfisher', '~> 3.0'

  s.tvos.deployment_target = "10.0"
  s.tvos.source_files = ['Sources/Clappr_tvOS/Classes/**/*', 'Sources/Clappr/Classes/**/*']
  s.tvos.exclude_files = [
                          "Sources/Clappr/Classes/Base/Player.swift",
                          "Sources/Clappr/Classes/Base/Playback.swift",
                          "Sources/Clappr/Classes/Base/MediaControl.swift",
                          "Sources/Clappr/Classes/Base/Options.swift",
                          "Sources/Clappr/Classes/Base/EventHandler.swift",
                          "Sources/Clappr/Classes/Base/Core.swift",
                          "Sources/Clappr/Classes/Base/BaseObject.swift",
                          "Sources/Clappr/Classes/Base/UIBaseObject.swift",
                          "Sources/Clappr/Classes/Base/FullscreenController.swift",
                          "Sources/Clappr/Classes/Base/FullScreenStateHandler.swift",
                          "Sources/Clappr/Classes/Plugin/Playback/AVFoundationPlayback.swift",
                          "Sources/Clappr/Classes/Plugin/Playback/NoOpPlayback.swift",
                          "Sources/Clappr/Classes/Plugin/Container/LoadingContainerPlugin.swift",
                          "Sources/Clappr/Classes/Plugin/Container/PosterPlugin.swift",
                          "Sources/Clappr/Classes/Protocol/EventProtocol.swift",
                          "Sources/Clappr/Classes/Extension/AVURLAssetWithCookiesBuilder.swift",
                          "Sources/Clappr/Classes/Helper/AppStateManager.swift",
                          "Sources/Clappr/Resources/MediaControlView.xib"
                          ]
end
